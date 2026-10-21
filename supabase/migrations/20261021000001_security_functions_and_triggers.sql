-- ==============================================================================
-- Migration 20261021000001: Admin Helper Function & Privileged Field Protection Triggers (CORRECTED & HARDENED)
-- Purpose:
--   1. Establish public.users as the single authoritative source of truth for identity & roles.
--   2. Isolate internal authorization helpers in private schema app_security to prevent
--      unauthorized RPC probing and information exposure over PostgREST.
--   3. Implement probe-resistant public.is_admin(check_user_id) preventing callers from
--      testing whether other arbitrary UUIDs are administrators.
--   4. Prevent ordinary authenticated clients from modifying role, is_admin, is_blocked,
--      or verified via INSERT, UPSERT, or PATCH on public.users.
--   5. Safely protect public.profiles without crashing on differing column schemas.
-- Author: Asrar-e-Tibb Security Gate (Stage 3A Hardening)
-- Date: 2026-10-21
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Create Private Security Schema
-- ------------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS app_security;

-- Revoke public creation on security schema
REVOKE ALL ON SCHEMA app_security FROM PUBLIC;
GRANT USAGE ON SCHEMA app_security TO anon, authenticated, service_role;

-- ------------------------------------------------------------------------------
-- 2. Internal Helper Function: Check Admin Privileges
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION app_security.is_admin(check_user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
STABLE
AS $$
BEGIN
  -- Strict null guard: null ID is never an administrator
  IF check_user_id IS NULL THEN
    RETURN false;
  END IF;

  -- Single authoritative source of truth: public.users ONLY
  RETURN EXISTS (
    SELECT 1 FROM public.users
    WHERE id = check_user_id
      AND (role = 'admin' OR is_admin IS TRUE)
      AND COALESCE(is_blocked, false) IS FALSE
  );
EXCEPTION
  WHEN OTHERS THEN
    -- Fail-closed: any runtime error or missing column strictly returns false
    RETURN false;
END;
$$;

COMMENT ON FUNCTION app_security.is_admin IS 'Internal helper: Returns true only if the user is a verified, non-blocked administrator in public.users.';

REVOKE ALL ON FUNCTION app_security.is_admin(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app_security.is_admin(uuid) TO anon, authenticated, service_role;


-- ------------------------------------------------------------------------------
-- 3. Public Probe-Resistant Wrapper Function: public.is_admin()
-- ------------------------------------------------------------------------------
-- Solves the information-disclosure risk:
-- A non-admin caller cannot probe whether another arbitrary user UUID is an administrator!
CREATE OR REPLACE FUNCTION public.is_admin(check_user_id uuid DEFAULT auth.uid())
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, app_security, public, pg_temp
STABLE
AS $$
BEGIN
  -- If check_user_id is not provided, default to current caller
  IF check_user_id IS NULL THEN
    check_user_id := auth.uid();
  END IF;

  IF check_user_id IS NULL THEN
    RETURN false;
  END IF;

  -- Probe Protection Guard:
  -- An unprivileged user is ONLY allowed to check their own UUID (auth.uid()).
  -- Probing another user's administrative status returns false immediately.
  IF check_user_id IS DISTINCT FROM auth.uid() AND NOT app_security.is_trusted_admin_context() THEN
    RETURN false;
  END IF;

  RETURN app_security.is_admin(check_user_id);
END;
$$;

COMMENT ON FUNCTION public.is_admin IS 'Probe-resistant public wrapper: allows users to verify their own administrative status without exposing other users.';

REVOKE ALL ON FUNCTION public.is_admin(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_admin(uuid) TO anon, authenticated, service_role;


-- ------------------------------------------------------------------------------
-- 4. Internal Helper Function: Evaluate Trusted Admin Execution Context
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION app_security.is_trusted_admin_context()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
STABLE
AS $$
DECLARE
  jwt_claims jsonb;
  jwt_role text;
BEGIN
  -- A. Direct PostgreSQL superuser or dashboard SQL editor session
  -- Note: PostgREST connects as 'authenticator', whereas dashboard SQL editor runs as 'postgres'
  IF session_user IN ('postgres', 'supabase_admin') THEN
    RETURN true;
  END IF;

  -- B. Service role JWT execution (trusted backend scripts or edge functions)
  BEGIN
    jwt_claims := NULLIF(current_setting('request.jwt.claims', true), '')::jsonb;
    jwt_role := jwt_claims ->> 'role';
    IF jwt_role = 'service_role' THEN
      RETURN true;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  -- C. Authenticated administrator session via PostgREST
  IF auth.uid() IS NOT NULL AND app_security.is_admin(auth.uid()) THEN
    RETURN true;
  END IF;

  RETURN false;
END;
$$;

COMMENT ON FUNCTION app_security.is_trusted_admin_context IS 'Returns true if caller is database superuser, service_role, or authenticated administrator.';

-- Restrict execution: ordinary clients (anon, authenticated) must NOT call this RPC directly
REVOKE ALL ON FUNCTION app_security.is_trusted_admin_context() FROM PUBLIC;
REVOKE ALL ON FUNCTION app_security.is_trusted_admin_context() FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION app_security.is_trusted_admin_context() TO service_role;


-- ------------------------------------------------------------------------------
-- 5. Trigger function to protect privileged fields on public.users
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.protect_user_privileged_fields()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, app_security, public, pg_temp
AS $$
DECLARE
  trusted_caller boolean := app_security.is_trusted_admin_context();
  normalized_role text;
BEGIN
  -- ---------------- ON INSERT (Registration / Upsert Insert) ----------------
  IF TG_OP = 'INSERT' THEN
    IF NOT trusted_caller THEN
      -- Normalize requested role
      normalized_role := LOWER(TRIM(COALESCE(NEW.role, '')));
      IF normalized_role = 'shopowner' OR normalized_role = 'shop_owner' THEN
        normalized_role := 'shop owner';
      END IF;
      NEW.role := normalized_role;

      -- Strict role whitelist for public registration
      IF NEW.role NOT IN ('patient', 'doctor', 'pharmacist', 'shop owner') THEN
        IF NEW.role = 'admin' THEN
          RAISE EXCEPTION 'Administrative accounts cannot be created via public registration.'
            USING ERRCODE = '42501';
        ELSE
          RAISE EXCEPTION 'Invalid account role requested: %', NEW.role
            USING ERRCODE = '42501';
        END IF;
      END IF;

      -- Force secure defaults for all client-controlled privileged fields
      NEW.is_admin := false;
      NEW.is_blocked := false;
      NEW.verified := false;
    END IF;
  END IF;

  -- ---------------- ON UPDATE (Profile Edits / Upsert Updates) ----------------
  IF TG_OP = 'UPDATE' THEN
    IF NOT trusted_caller THEN
      -- Forbid role changes
      IF OLD.role IS DISTINCT FROM NEW.role THEN
        RAISE EXCEPTION 'Unauthorized: Modifying user role requires administrator privileges.'
          USING ERRCODE = '42501';
      END IF;

      -- Forbid is_admin changes
      IF OLD.is_admin IS DISTINCT FROM NEW.is_admin THEN
        RAISE EXCEPTION 'Unauthorized: Modifying is_admin flag requires administrator privileges.'
          USING ERRCODE = '42501';
      END IF;

      -- Forbid is_blocked changes (self-unblocking)
      IF OLD.is_blocked IS DISTINCT FROM NEW.is_blocked THEN
        RAISE EXCEPTION 'Unauthorized: Modifying account suspension status requires administrator privileges.'
          USING ERRCODE = '42501';
      END IF;

      -- Forbid verified changes
      IF OLD.verified IS DISTINCT FROM NEW.verified THEN
        RAISE EXCEPTION 'Unauthorized: Modifying verification status requires administrator privileges.'
          USING ERRCODE = '42501';
      END IF;

      -- Forbid modifying account identifier (primary key)
      IF OLD.id IS DISTINCT FROM NEW.id THEN
        RAISE EXCEPTION 'Unauthorized: Modifying account identifier is not permitted.'
          USING ERRCODE = '42501';
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.protect_user_privileged_fields IS 'Enforces non-negotiable authorization rules on public.users modifications.';

REVOKE ALL ON FUNCTION public.protect_user_privileged_fields() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.protect_user_privileged_fields() FROM anon, authenticated;

DROP TRIGGER IF EXISTS trg_protect_user_privileged_fields ON public.users;
CREATE TRIGGER trg_protect_user_privileged_fields
BEFORE INSERT OR UPDATE ON public.users
FOR EACH ROW EXECUTE FUNCTION public.protect_user_privileged_fields();


-- ------------------------------------------------------------------------------
-- 6. Dedicated trigger function to protect public.profiles safely
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.protect_profiles_privileged_fields()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, app_security, public, pg_temp
AS $$
DECLARE
  trusted_caller boolean := app_security.is_trusted_admin_context();
BEGIN
  IF NOT trusted_caller THEN
    IF TG_OP = 'UPDATE' THEN
      -- Protect role on profiles if column exists
      BEGIN
        IF OLD.role IS DISTINCT FROM NEW.role THEN
          RAISE EXCEPTION 'Unauthorized: Modifying role on profiles requires administrator privileges.'
            USING ERRCODE = '42501';
        END IF;
      EXCEPTION
        WHEN undefined_column THEN
          NULL;
      END;

      -- Protect is_verified on profiles if column exists
      BEGIN
        IF OLD.is_verified IS DISTINCT FROM NEW.is_verified THEN
          RAISE EXCEPTION 'Unauthorized: Modifying verification status on profiles requires administrator privileges.'
            USING ERRCODE = '42501';
        END IF;
      EXCEPTION
        WHEN undefined_column THEN
          NULL;
      END;

      -- Forbid changing profile primary key
      IF OLD.id IS DISTINCT FROM NEW.id THEN
        RAISE EXCEPTION 'Unauthorized: Modifying profile identifier is not permitted.'
          USING ERRCODE = '42501';
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.protect_profiles_privileged_fields() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.protect_profiles_privileged_fields() FROM anon, authenticated;

-- Dynamically attach to public.profiles if the table exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles') THEN
    EXECUTE '
      DROP TRIGGER IF EXISTS trg_protect_profiles_privileged_fields ON public.profiles;
      CREATE TRIGGER trg_protect_profiles_privileged_fields
      BEFORE INSERT OR UPDATE ON public.profiles
      FOR EACH ROW EXECUTE FUNCTION public.protect_profiles_privileged_fields();
    ';
  END IF;
END $$;
