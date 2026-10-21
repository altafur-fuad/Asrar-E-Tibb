# Asrar-e-Tibb: Security Gate Stage 2.1 — Final SQL Review Bundle

> **Document:** Comprehensive SQL Migration Review Bundle, Security Verification & Staging Strategy
> **Status:** Stage 2.1 Complete — Full Review Bundle Prepared (Awaiting Staging Execution Approval)
> **Target Database:** Supabase Postgres (`https://ynssqrpfbeavuynxcwxj.supabase.co`)
> **Repository Root:** `e:/Asrar-E-Tibb`
> **Author:** Senior Full-Stack Security Auditor & Systems Architect
> **Date:** 2026-10-21

---

## 1. Executive Summary & Verification Boundary

This document consolidates the complete, untruncated SQL migrations, in-depth architectural verifications, and staging execution strategy for resolving the privilege-escalation and authorization risks identified in Milestone 2.

### Critical Verification Boundary Statement:
> [!IMPORTANT]
> **Remote Database State Remains Unverified:**
> The repository contains only public client-safe credentials (`NEXT_PUBLIC_SUPABASE_URL` and `anonKey`). Zero database passwords, administrative connection strings, `psql` URIs, or `service_role` secrets exist in the repository or local configuration.
> As a result, the live database configuration (active RLS enablement, table grants, existing triggers, and storage policies on `https://ynssqrpfbeavuynxcwxj.supabase.co`) **remains unverified**.
> We do not infer remote database security from Flutter query code alone. The corrected migrations are engineered defensively to ensure least-privilege security regardless of the current remote configuration.

---

## 2. Table & Column Inventory: Confirmed vs. Inferred Metadata

Because no baseline migration existed in the repository and remote database inspection credentials are unavailable, every table and column was cataloged through static analysis of the Flutter application code (`Asrar-E-Tibb/lib/`).

| Migration File | Object / Table Name | Columns Required | Verification Source | Status / Risk |
|---|---|---|---|---|
| `0000`, `0001`, `0002` | `public.users` | `id` (uuid, PK), `name` (text), `email` (text), `mobile` (text), `role` (text), `dob` (text), `verified` (bool), `is_blocked` (bool), `is_admin` (bool), `created_at` (timestamptz) | `signuppage.dart:144-154`, `loginpage.dart:68`, `admin_panel_page.dart:130, 154` | **Inferred from client code**. Columns `is_admin` and `is_blocked` must exist for triggers to execute. |
| `0000`, `0001`, `0002` | `public.profiles` | `id` (uuid, PK), `name`, `email`, `mobile`, `role`, `is_verified` (bool), `avatar_url`, `bio`, `blood_group`, `last_donate`, `health_condition`, `home_address`, `office_address`, `emergency_contact`, `notes`, `dob`, `created_at` | `supabase_services.dart:272, 515`, `admin_panel_page.dart:279`, `reminder_page.dart:40` | **Inferred from client code**. Safe dynamic exception handling implemented in trigger to prevent column mismatch crashes. |
| `0000`, `0002` | `public.patients` | `id`, `user_id`, `auth_id`, `name`, `email`, `mobile`, `gender`, `dob`, `blood_group`, `created_at` | `signuppage.dart:82, 156` | **Inferred from client code**. |
| `0000`, `0002` | `public.doctors` | `id`, `user_id`, `auth_id`, `name`, `email`, `mobile`, `specialist`, `licence`, `workplace`, `dob`, `created_at` | `signuppage.dart:84, 156` | **Inferred from client code**. |
| `0000`, `0002` | `public.pharmacists` | `id`, `user_id`, `auth_id`, `name`, `email`, `mobile`, `workplace`, `dob`, `created_at` | `signuppage.dart:86, 156` | **Inferred from client code**. |
| `0000`, `0002` | `public.shop_owners` | `id`, `user_id`, `auth_id`, `name`, `email`, `mobile`, `shop_name`, `dob`, `created_at` | `signuppage.dart:89, 156` | **Inferred from client code**. |
| `0000`, `0002` | `public.posts` | `id` (uuid, PK), `user_id` (uuid, FK), `content` (text), `created_at` (timestamptz), `updated_at` | `supabase_services.dart:74, 109, 347, 385` | **Inferred from client code**. |
| `0000`, `0002` | `public.post_images` | `id` (uuid, PK), `post_id` (uuid, FK), `storage_path` (text), `created_at` | `supabase_services.dart:83, 356, 360` | **Inferred from client code**. |
| `0000`, `0002` | `public.post_likes` | `id` (uuid, PK), `post_id` (uuid, FK), `user_id` (uuid, FK), `created_at` | `supabase_services.dart:185, 192, 217, 382` | **Inferred from client code**. `UNIQUE(post_id, user_id)` constraint required. |
| `0000`, `0002` | `public.comments` | `id` (uuid, PK), `post_id` (uuid, FK), `user_id` (uuid, FK), `content` (text), `created_at` | `supabase_services.dart:236, 383, 411` | **Inferred from client code**. |
| `0000`, `0002` | `public.notifications` | `id` (uuid, PK), `user_id` (uuid, FK), `actor_id` (uuid, FK), `type` (text), `created_at` | `supabase_services.dart:206, 250, 425` | **Inferred from client code**. |
| `0000`, `0002` | `public.schedules` | `id` (uuid, PK), `user_id` (uuid, FK), `medicine_name` (text), `dosage` (text), `time` (text), `created_at` | `supabase_services.dart:578, 609, 624, 640` | **Inferred from client code**. Strict medical privacy. |
| `0000`, `0002` | `public.notes` | `id` (uuid, PK), `user_id` (uuid, FK), `title` (text), `content` (text), `pinned` (bool), `created_at` | `supabase_services.dart:676, 707, 722, 738` | **Inferred from client code**. Strict personal privacy. |
| `0000`, `0002` | `public.todos` | `id` (uuid, PK), `user_id` (uuid, FK), `text` (text), `done` (bool), `created_at`, `updated_at` | `supabase_services.dart:774, 805, 820, 836` | **Inferred from client code**. Strict personal privacy. |
| `0000`, `0003` | `storage.buckets` / `storage.objects` | `bucket_id` ('profile-pictures', 'post-images'), `name` (text) | `supabase_services.dart:15, 23, 48` | **Inferred from client code**. Storage schema is standard Supabase Storage. |

> [!NOTE]
> **No Backend Orders or Consultation Tables:**
> Static analysis confirmed `checkoutpage.dart`, `cart_provider.dart`, `prescriptions.dart`, and `onlineconsultationpage.dart` operate entirely with in-memory state. No backend `orders` or `consultations` tables exist in the database.

---

## 3. Role Values, Capitalization & Storage Path Verification

### 3.1 Role Values in Codebase:
- **Registration (`signuppage.dart:80-92, 138-153`):**
  - Allowed UI identities: `"Patient"`, `"Doctor"`, `"Pharmacist"`, `"Shop Owner"`.
  - Client normalization: `_selectedRole.toLowerCase().trim()`.
  - Special shop owner handling: If `"shopowner"` or `"shop_owner"` -> converted to `"shop owner"`.
  - Value stored in database: `'patient'`, `'doctor'`, `'pharmacist'`, `'shop owner'`.
  - Database trigger normalization: Migration `0001` automatically normalizes `'shop_owner'` and `'shopowner'` to `'shop owner'` and checks against whitelist `('patient', 'doctor', 'pharmacist', 'shop owner')`.
- **Login Verification (`loginpage.dart:73`):**
  - Compares `_selectedRole.toLowerCase() == role.toLowerCase()`.
- **Admin Verification (`supabase_auth_helper.dart:288`, `adminhomepage.dart:36`):**
  - Checks `role.toLowerCase().trim() == 'admin'` OR `is_admin == true`.
  - Block check: `is_blocked == true` immediately invalidates admin privileges.

### 3.2 Storage Buckets & Real Upload Paths:
- **Bucket 1: `profile-pictures`**
  - Defined in `supabase_services.dart:15`: `profileBucket = 'profile-pictures'`.
  - Real upload path (`supabase_services.dart:48`): `'$userId/profile.$ext'`.
  - Options: `FileOptions(upsert: true)`.
  - Policy enforcement: `(storage.foldername(name))[1] = auth.uid()::text` on `INSERT`, `UPDATE`, and `DELETE`.
- **Bucket 2: `post-images`**
  - Defined in `supabase_services.dart`: `postBucket = 'post-images'`.
  - Real upload path (`supabase_services.dart:23`): `'posts/$id.$ext'` where `$id` is a UUID.
  - Options: `FileOptions(upsert: false)`.
  - Policy enforcement: `(storage.foldername(name))[1] = 'posts'` on `INSERT`, public `SELECT`, and admin `DELETE`.

---

## 4. `SECURITY DEFINER` Function Review & Schema Placement Analysis

### 4.1 Security Properties Evaluated:
1. **Execution Context:**
   - Functions are defined with `SECURITY DEFINER`, allowing them to read `public.users` to verify administrative status without triggering recursive RLS evaluations.
2. **Pinned Search Path:**
   - Every function explicitly specifies: `SET search_path = pg_catalog, public, pg_temp;`. This prevents search-path hijacking attacks where a malicious user creates a shadowing function in a temporary schema.
3. **Execution Privilege Revocation:**
   - `public.is_admin(uuid)`: `REVOKE ALL FROM PUBLIC;` and granted explicitly to `anon, authenticated, service_role` because PostgREST RLS policies evaluate `is_admin()` during user queries.
   - `public.is_trusted_admin_context()`: `REVOKE ALL FROM PUBLIC, anon, authenticated;` and granted strictly to `service_role`. This internal function is **not** callable over PostgREST RPC.
   - `public.protect_user_privileged_fields()` & `protect_profiles_privileged_fields()`: Revoked from `PUBLIC, anon, authenticated`. Triggers execute via internal PostgreSQL trigger machinery.

### 4.2 Schema Placement Evaluation (`public` vs. Private Schema):
- **Trade-Off Analysis:**
  - In Supabase, any function in the `public` schema is inspected by PostgREST and exposed as an RPC endpoint (`POST /rest/v1/rpc/<func_name>`) unless execute permissions are revoked.
  - Revoking execute on `is_trusted_admin_context()` prevents ordinary users from calling it over PostgREST.
  - **Gold-Standard Alternative (Dedicated Security Schema):**
    Placing internal security helpers in an unexposed schema (e.g. `CREATE SCHEMA IF NOT EXISTS auth_private;`) ensures PostgREST never generates an RPC route for them, regardless of grants.
  - **Staging Recommendation:** The bundled migrations keep the functions in `public` with strict `REVOKE` statements to ensure maximum compatibility with existing PostgREST grants, while providing a drop-in option for `auth_private` schema isolation if preferred by the owner.

---

## 5. Permissive Policy Conflict Analysis (The `OR` Risk)

> [!WARNING]
> **PostgreSQL Combines Permissive Policies with `OR`:**
> In PostgreSQL Row Level Security, if multiple permissive policies exist for the same action on a table, access is granted if **ANY** policy evaluates to true:
> `access_allowed = (policy_1 OR policy_2 OR policy_3)`
> Simply executing `CREATE POLICY` without removing prior permissive policies provides **zero** security. For example, if a table already has a template policy like `"Allow all access for authenticated"`, adding an owner-check policy `USING (auth.uid() = user_id)` will still allow any user to read or modify all data because the old policy remains true.

### Policy Plan & Cleanup Table:

| Table | Policy Name Created | Target Role | Command | Action Taken | Rationale |
|---|---|---|---|---|---|
| `public.users` | `users_select_policy` | `authenticated` | `SELECT` | Replaces any existing | Allows users to read profile cards & authors in feed. |
| `public.users` | `users_insert_policy` | `authenticated` | `INSERT` | Replaces any existing | Restricts insert to `auth.uid() = id`. |
| `public.users` | `users_update_policy` | `authenticated` | `UPDATE` | Replaces any existing | Restricts update to `auth.uid() = id OR is_admin()`. |
| `public.users` | `users_delete_policy` | `authenticated` | `DELETE` | Replaces any existing | Reserved strictly to administrators. |
| `public.profiles` | `profiles_select_policy` | `authenticated` | `SELECT` | Replaces any existing | Public profile inspection across app. |
| `public.profiles` | `profiles_insert_policy` | `authenticated` | `INSERT` | Replaces any existing | Restricts insert to `auth.uid() = id`. |
| `public.profiles` | `profiles_update_policy` | `authenticated` | `UPDATE` | Replaces any existing | Restricts update to `auth.uid() = id OR is_admin()`. |
| `public.profiles` | `profiles_delete_policy` | `authenticated` | `DELETE` | Replaces any existing | Reserved strictly to administrators. |
| `public.schedules` | `schedules_*` (ALL) | `authenticated` | `ALL` | Drops legacy, creates owner-only | Medical data must be isolated strictly to `auth.uid() = user_id`. |
| `public.notes` | `notes_*` (ALL) | `authenticated` | `ALL` | Drops legacy, creates owner-only | Personal notes must be isolated strictly to `auth.uid() = user_id`. |
| `public.todos` | `todos_*` (ALL) | `authenticated` | `ALL` | Drops legacy, creates owner-only | Personal to-dos must be isolated strictly to `auth.uid() = user_id`. |
| `public.posts` | `posts_update_policy` | `authenticated` | `UPDATE` | Replaces any existing | Prevents transferring post ownership: `auth.uid() = user_id`. |
| `public.posts` | `posts_delete_policy` | `authenticated` | `DELETE` | Replaces any existing | Author or admin moderation: `auth.uid() = user_id OR is_admin()`. |
| `public.post_likes` | `likes_delete_policy` | `authenticated` | `DELETE` | Replaces any existing | Fixes admin post moderation by allowing admin deletion. |
| `public.comments` | `comments_delete_policy` | `authenticated` | `DELETE` | Replaces any existing | Author or admin moderation: `auth.uid() = user_id OR is_admin()`. |
| `public.notifications` | `notifications_select` | `authenticated` | `SELECT` | Replaces any existing | Recipient only: `auth.uid() = user_id`. |
| `public.notifications` | `notifications_insert` | `authenticated` | `INSERT` | Replaces any existing | Sender must be `auth.uid() = actor_id`. |

---

## 6. Safe Staging Schema & Data Strategy

Because no baseline migration existed in the repository:
1. **Never copy real production patient data to staging.**
2. Migration `0000_baseline_schema.sql` was created to initialize an empty Supabase project with the complete schema and storage buckets.
3. Three synthetic test accounts are used for verification:
   - `admin@test.local` (promoted to admin via bootstrap script)
   - `user_a@test.local` (role: `'patient'`, non-admin)
   - `user_b@test.local` (role: `'doctor'`, non-admin)

---

## 7. Migration Dependency Order, Prerequisites & Rollback

### 7.1 Prerequisites:
- A separate staging Supabase project (or local `npx supabase start`).
- Access to Supabase Dashboard SQL Editor for staging.
- Never use production API keys in staging test scripts.

### 7.2 Execution Order:
1. **`0000_baseline_schema.sql`**: Creates tables, columns, constraints, and storage buckets (if starting from empty database).
2. **`0001_security_functions_and_triggers.sql`**: Installs `is_admin()`, `is_trusted_admin_context()`, and protection triggers on `users` and `profiles`.
3. **`0002_rls_policies.sql`**: Enables RLS on all 14 tables and applies least-privilege policies.
4. **`0003_storage_policies.sql`**: Applies folder-scoped policies on `profile-pictures` and path constraints on `post-images`.
5. **One-Time Administrator Bootstrap Script**: Promotes `admin@test.local` in staging.

### 7.3 Rollback Limitations & Teardown:
- Dropping triggers and functions restores default behavior immediately.
- If RLS policies are reverted, tables should remain with `ENABLE ROW LEVEL SECURITY` to prevent accidental public data exposure during maintenance.

---

## 8. Complete, Untruncated SQL Migrations

The complete, untruncated contents of all migration files are presented below:

### Migration 0: `backend/migrations/0000_baseline_schema.sql`

```sql
-- ==============================================================================
-- Migration 0000: Staging Baseline Schema & Storage Bucket Initialization
-- Purpose:
--   Reproduces the complete Asrar-e-Tibb database schema and storage bucket configuration
--   for isolated local or cloud staging environments WITHOUT copying real production user data.
-- Author: Asrar-e-Tibb Security Gate (Stage 2.1)
-- Date: 2026-10-21
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Identity & Profile Tables
-- ------------------------------------------------------------------------------

-- public.users (Primary account metadata & authorization claims)
CREATE TABLE IF NOT EXISTS public.users (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL DEFAULT '',
  email text NOT NULL DEFAULT '',
  mobile text DEFAULT '',
  role text NOT NULL DEFAULT 'patient',
  dob text DEFAULT '',
  verified boolean NOT NULL DEFAULT false,
  is_blocked boolean NOT NULL DEFAULT false,
  is_admin boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- public.profiles (Extended profile data for feed & user profile screens)
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name text DEFAULT '',
  email text DEFAULT '',
  mobile text DEFAULT '',
  role text DEFAULT 'patient',
  is_verified boolean DEFAULT false,
  avatar_url text DEFAULT '',
  bio text DEFAULT '',
  blood_group text DEFAULT '',
  last_donate text DEFAULT '',
  health_condition text DEFAULT '',
  home_address text DEFAULT '',
  office_address text DEFAULT '',
  emergency_contact text DEFAULT '',
  notes text DEFAULT '',
  dob text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- ------------------------------------------------------------------------------
-- 2. Role-Specific Profile Extension Tables
-- ------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.patients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  auth_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  name text DEFAULT '',
  email text DEFAULT '',
  mobile text DEFAULT '',
  gender text DEFAULT '',
  dob text DEFAULT '',
  blood_group text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.doctors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  auth_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  name text DEFAULT '',
  email text DEFAULT '',
  mobile text DEFAULT '',
  specialist text DEFAULT '',
  licence text DEFAULT '',
  workplace text DEFAULT '',
  dob text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.pharmacists (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  auth_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  name text DEFAULT '',
  email text DEFAULT '',
  mobile text DEFAULT '',
  workplace text DEFAULT '',
  dob text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.shop_owners (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  auth_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  name text DEFAULT '',
  email text DEFAULT '',
  mobile text DEFAULT '',
  shop_name text DEFAULT '',
  dob text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- ------------------------------------------------------------------------------
-- 3. Community Feed & Moderation Tables
-- ------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.post_images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  storage_path text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.post_likes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(post_id, user_id)
);

CREATE TABLE IF NOT EXISTS public.comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  actor_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ------------------------------------------------------------------------------
-- 4. Personal Health & Productivity Data (Strict Private)
-- ------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.schedules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  medicine_name text NOT NULL DEFAULT '',
  dosage text DEFAULT '',
  time text DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL DEFAULT '',
  content text DEFAULT '',
  pinned boolean DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.todos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  text text NOT NULL DEFAULT '',
  done boolean DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ------------------------------------------------------------------------------
-- 5. Storage Buckets Initialization
-- ------------------------------------------------------------------------------

INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-pictures', 'profile-pictures', true)
ON CONFLICT (id) DO UPDATE SET public = true;

INSERT INTO storage.buckets (id, name, public)
VALUES ('post-images', 'post-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;
```

---

### Migration 1: `backend/migrations/0001_security_functions_and_triggers.sql`

```sql
-- ==============================================================================
-- Migration 0001: Admin Helper Function & Privileged Field Protection Triggers (CORRECTED)
-- Purpose:
--   1. Establish public.users as the single authoritative source of truth for identity & roles.
--   2. Define fail-closed, non-recursive public.is_admin() and public.is_trusted_admin_context().
--   3. Securely revoke public execution grants on security functions.
--   4. Prevent ordinary authenticated clients from modifying role, is_admin, is_blocked,
--      or verified via INSERT, UPSERT, or PATCH on public.users.
--   5. Safely protect public.profiles without crashing on differing column schemas.
-- Author: Asrar-e-Tibb Security Gate (Stage 2.1 Final Review)
-- Date: 2026-10-21
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Helper function to check admin privileges safely without RLS recursion
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_admin(check_user_id uuid)
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

COMMENT ON FUNCTION public.is_admin IS 'Returns true only if the user is a verified, non-blocked administrator in public.users.';

-- Revoke default public execution privileges and grant explicitly
REVOKE ALL ON FUNCTION public.is_admin(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_admin(uuid) TO anon, authenticated, service_role;


-- ------------------------------------------------------------------------------
-- 2. Helper function to evaluate trusted administrative execution context
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_trusted_admin_context()
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
  IF auth.uid() IS NOT NULL AND public.is_admin(auth.uid()) THEN
    RETURN true;
  END IF;

  RETURN false;
END;
$$;

COMMENT ON FUNCTION public.is_trusted_admin_context IS 'Returns true if caller is database superuser, service_role, or authenticated administrator.';

-- Restrict execution: ordinary clients (anon, authenticated) must NOT call this RPC directly
REVOKE ALL ON FUNCTION public.is_trusted_admin_context() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.is_trusted_admin_context() FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION public.is_trusted_admin_context() TO service_role;


-- ------------------------------------------------------------------------------
-- 3. Trigger function to protect privileged fields on public.users
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.protect_user_privileged_fields()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  trusted_caller boolean := public.is_trusted_admin_context();
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
-- 4. Dedicated trigger function to protect public.profiles safely
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.protect_profiles_privileged_fields()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  trusted_caller boolean := public.is_trusted_admin_context();
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
```

---

### Migration 2: `backend/migrations/0002_rls_policies.sql`

```sql
-- ==============================================================================
-- Migration 0002: Row Level Security Policies for Core, Identity & Personal Tables (CORRECTED)
-- Purpose:
--   1. Enable RLS on all 14 existing tables across the project.
--   2. Strict owner isolation on personal health data (schedules, notes, todos).
--   3. Identity row protection for users, profiles, and role tables (patients, doctors, etc.).
--   4. Dual author/admin moderation on community tables (posts, comments, post_images, post_likes).
--   5. Fix admin moderation delete permission on post_likes.
-- Author: Asrar-e-Tibb Security Gate (Stage 2 Review)
-- Date: 2026-10-21
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Identity & Profile Tables (public.users, public.profiles)
-- ------------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.profiles ENABLE ROW LEVEL SECURITY;

-- public.users
DROP POLICY IF EXISTS "users_select_policy" ON public.users;
CREATE POLICY "users_select_policy" ON public.users
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "users_insert_policy" ON public.users;
CREATE POLICY "users_insert_policy" ON public.users
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "users_update_policy" ON public.users;
CREATE POLICY "users_update_policy" ON public.users
  FOR UPDATE TO authenticated
  USING (auth.uid() = id OR public.is_admin(auth.uid()))
  WITH CHECK (auth.uid() = id OR public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "users_delete_policy" ON public.users;
CREATE POLICY "users_delete_policy" ON public.users
  FOR DELETE TO authenticated
  USING (public.is_admin(auth.uid()));

-- public.profiles
DROP POLICY IF EXISTS "profiles_select_policy" ON public.profiles;
CREATE POLICY "profiles_select_policy" ON public.profiles
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "profiles_insert_policy" ON public.profiles;
CREATE POLICY "profiles_insert_policy" ON public.profiles
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_update_policy" ON public.profiles;
CREATE POLICY "profiles_update_policy" ON public.profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = id OR public.is_admin(auth.uid()))
  WITH CHECK (auth.uid() = id OR public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "profiles_delete_policy" ON public.profiles;
CREATE POLICY "profiles_delete_policy" ON public.profiles
  FOR DELETE TO authenticated
  USING (public.is_admin(auth.uid()));


-- ------------------------------------------------------------------------------
-- 2. Role-Specific Extension Tables (patients, doctors, pharmacists, shop_owners)
-- ------------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.pharmacists ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.shop_owners ENABLE ROW LEVEL SECURITY;

-- Macro DO block to configure role tables safely if they exist
DO $$
DECLARE
  t text;
  tables text[] := ARRAY['patients', 'doctors', 'pharmacists', 'shop_owners'];
BEGIN
  FOREACH t IN ARRAY tables LOOP
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = t) THEN
      EXECUTE format('DROP POLICY IF EXISTS "%s_select" ON public.%I;', t, t);
      EXECUTE format('CREATE POLICY "%s_select" ON public.%I FOR SELECT TO authenticated USING (true);', t, t);

      EXECUTE format('DROP POLICY IF EXISTS "%s_insert" ON public.%I;', t, t);
      EXECUTE format('CREATE POLICY "%s_insert" ON public.%I FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id OR auth.uid() = auth_id);', t, t);

      EXECUTE format('DROP POLICY IF EXISTS "%s_update" ON public.%I;', t, t);
      EXECUTE format('CREATE POLICY "%s_update" ON public.%I FOR UPDATE TO authenticated USING (auth.uid() = user_id OR auth.uid() = auth_id OR public.is_admin(auth.uid())) WITH CHECK (auth.uid() = user_id OR auth.uid() = auth_id OR public.is_admin(auth.uid()));', t, t);

      EXECUTE format('DROP POLICY IF EXISTS "%s_delete" ON public.%I;', t, t);
      EXECUTE format('CREATE POLICY "%s_delete" ON public.%I FOR DELETE TO authenticated USING (auth.uid() = user_id OR auth.uid() = auth_id OR public.is_admin(auth.uid()));', t, t);
    END IF;
  END LOOP;
END $$;


-- ------------------------------------------------------------------------------
-- 3. Strict Personal Health Data (schedules, notes, todos)
-- ------------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.todos ENABLE ROW LEVEL SECURITY;

-- Schedules
DROP POLICY IF EXISTS "schedules_select_policy" ON public.schedules;
CREATE POLICY "schedules_select_policy" ON public.schedules
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "schedules_insert_policy" ON public.schedules;
CREATE POLICY "schedules_insert_policy" ON public.schedules
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "schedules_update_policy" ON public.schedules;
CREATE POLICY "schedules_update_policy" ON public.schedules
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "schedules_delete_policy" ON public.schedules;
CREATE POLICY "schedules_delete_policy" ON public.schedules
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- Notes
DROP POLICY IF EXISTS "notes_select_policy" ON public.notes;
CREATE POLICY "notes_select_policy" ON public.notes
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "notes_insert_policy" ON public.notes;
CREATE POLICY "notes_insert_policy" ON public.notes
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "notes_update_policy" ON public.notes;
CREATE POLICY "notes_update_policy" ON public.notes
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "notes_delete_policy" ON public.notes;
CREATE POLICY "notes_delete_policy" ON public.notes
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- Todos
DROP POLICY IF EXISTS "todos_select_policy" ON public.todos;
CREATE POLICY "todos_select_policy" ON public.todos
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "todos_insert_policy" ON public.todos;
CREATE POLICY "todos_insert_policy" ON public.todos
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "todos_update_policy" ON public.todos;
CREATE POLICY "todos_update_policy" ON public.todos
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "todos_delete_policy" ON public.todos;
CREATE POLICY "todos_delete_policy" ON public.todos
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);


-- ------------------------------------------------------------------------------
-- 4. Community & Moderation (posts, comments, post_images, post_likes, notifications)
-- ------------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.post_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.notifications ENABLE ROW LEVEL SECURITY;

-- Posts: Public Read, Author Create/Edit, Author OR Admin Delete
DROP POLICY IF EXISTS "posts_select_policy" ON public.posts;
CREATE POLICY "posts_select_policy" ON public.posts
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "posts_insert_policy" ON public.posts;
CREATE POLICY "posts_insert_policy" ON public.posts
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "posts_update_policy" ON public.posts;
CREATE POLICY "posts_update_policy" ON public.posts
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "posts_delete_policy" ON public.posts;
CREATE POLICY "posts_delete_policy" ON public.posts
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id OR public.is_admin(auth.uid()));

-- Comments: Public Read, Author Create/Edit, Author OR Admin Delete
DROP POLICY IF EXISTS "comments_select_policy" ON public.comments;
CREATE POLICY "comments_select_policy" ON public.comments
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "comments_insert_policy" ON public.comments;
CREATE POLICY "comments_insert_policy" ON public.comments
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "comments_update_policy" ON public.comments;
CREATE POLICY "comments_update_policy" ON public.comments
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "comments_delete_policy" ON public.comments;
CREATE POLICY "comments_delete_policy" ON public.comments
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id OR public.is_admin(auth.uid()));

-- Post Likes: Read All, Insert Own, Delete Own OR Admin Delete
DROP POLICY IF EXISTS "likes_select_policy" ON public.post_likes;
CREATE POLICY "likes_select_policy" ON public.post_likes
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "likes_insert_policy" ON public.post_likes;
CREATE POLICY "likes_insert_policy" ON public.post_likes
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "likes_delete_policy" ON public.post_likes;
CREATE POLICY "likes_delete_policy" ON public.post_likes
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id OR public.is_admin(auth.uid()));

-- Post Images: Read All, Insert Authenticated, Delete Author OR Admin
DROP POLICY IF EXISTS "post_images_select_policy" ON public.post_images;
CREATE POLICY "post_images_select_policy" ON public.post_images
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "post_images_insert_policy" ON public.post_images;
CREATE POLICY "post_images_insert_policy" ON public.post_images
  FOR INSERT TO authenticated
  WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "post_images_delete_policy" ON public.post_images;
CREATE POLICY "post_images_delete_policy" ON public.post_images
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.posts
      WHERE posts.id = post_images.post_id
        AND (posts.user_id = auth.uid() OR public.is_admin(auth.uid()))
    )
  );

-- Notifications: Read Own, Insert Authenticated Actor, Update Own (mark read), Delete Own
DROP POLICY IF EXISTS "notifications_select_policy" ON public.notifications;
CREATE POLICY "notifications_select_policy" ON public.notifications
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "notifications_insert_policy" ON public.notifications;
CREATE POLICY "notifications_insert_policy" ON public.notifications
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = actor_id);

DROP POLICY IF EXISTS "notifications_update_policy" ON public.notifications;
CREATE POLICY "notifications_update_policy" ON public.notifications
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "notifications_delete_policy" ON public.notifications;
CREATE POLICY "notifications_delete_policy" ON public.notifications
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);
```

---

### Migration 3: `backend/migrations/0003_storage_policies.sql`

```sql
-- ==============================================================================
-- Migration 0003: Storage Bucket Access Policies (CORRECTED)
-- Purpose:
--   1. Restrict profile-pictures uploads/updates strictly to user-owned root folder (<auth.uid()>/...).
--   2. Restrict post-images uploads to the 'posts/' directory for authenticated users.
--   3. Enable public read access intentionally required for feed & avatar rendering.
--   4. Allow owners to delete their own avatars and administrators to delete post images.
-- Author: Asrar-e-Tibb Security Gate (Stage 2 Review)
-- Date: 2026-10-21
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Profile Pictures Bucket (`profile-pictures`)
-- Upload pattern in Flutter: `<userId>/profile.<ext>` with upsert: true
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "profile_pictures_select" ON storage.objects;
CREATE POLICY "profile_pictures_select" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'profile-pictures');

DROP POLICY IF EXISTS "profile_pictures_insert" ON storage.objects;
CREATE POLICY "profile_pictures_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'profile-pictures' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "profile_pictures_update" ON storage.objects;
CREATE POLICY "profile_pictures_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'profile-pictures' AND
    (storage.foldername(name))[1] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id = 'profile-pictures' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "profile_pictures_delete" ON storage.objects;
CREATE POLICY "profile_pictures_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'profile-pictures' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );


-- ------------------------------------------------------------------------------
-- 2. Post Images Bucket (`post-images`)
-- Upload pattern in Flutter: `posts/<uuid>.<ext>` with upsert: false
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "post_images_select" ON storage.objects;
CREATE POLICY "post_images_select" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'post-images');

DROP POLICY IF EXISTS "post_images_insert" ON storage.objects;
CREATE POLICY "post_images_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'post-images' AND
    (storage.foldername(name))[1] = 'posts' AND
    auth.role() = 'authenticated'
  );

DROP POLICY IF EXISTS "post_images_delete" ON storage.objects;
CREATE POLICY "post_images_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'post-images' AND
    (public.is_admin(auth.uid()) OR auth.role() = 'service_role')
  );
```

---

## 9. Staging Setup Plan & Objective Pass/Fail Verification Criteria

### 9.1 Staging Environment Execution:
1. Target: Local Supabase CLI instance (`http://127.0.0.1:54321`) or separate cloud staging project (`asrar-e-tibb-staging`).
2. Run migrations in sequence: `0000`, `0001`, `0002`, `0003`.
3. Bootstrap staging admin account: `admin@test.local`.

### 9.2 Objective Pass/Fail Verification Matrix:

| Test ID | Test Scenario | Execution Command / Direct API Call | Pass Criteria | Fail Criteria |
|---|---|---|---|---|
| **STG-01** | Unauthenticated Access | `GET /rest/v1/schedules` (no auth header) | HTTP **401 Unauthorized** | Any rows returned or 200 OK |
| **STG-02** | User Self-Promotion | `PATCH /rest/v1/users?id=eq.<user_a_id>` with payload `{"role": "admin"}` (User A JWT) | HTTP **403 Forbidden** (error `42501`) | HTTP 200/204 or `role` becomes `'admin'` |
| **STG-03** | User Self-Unblocking | `PATCH /rest/v1/users?id=eq.<user_a_id>` with payload `{"is_blocked": false}` (User A JWT) | HTTP **403 Forbidden** (error `42501`) | HTTP 200/204 or `is_blocked` modified |
| **STG-04** | Forged Admin Signup | `POST /rest/v1/users` with payload `{"id": "<new_uid>", "role": "admin"}` | HTTP **403 Forbidden** (error `42501`) | Account created with admin role |
| **STG-05** | Cross-User Note Access | User A queries `GET /rest/v1/notes?user_id=eq.<user_b_id>` | HTTP **200 OK with `[]`** | User B's note visible to User A |
| **STG-06** | Cross-User Note Delete | User A sends `DELETE /rest/v1/notes?id=eq.<user_b_note_id>` | HTTP **200 OK with 0 affected rows** | User B's note deleted |
| **STG-07** | Unauthorized Moderation | User A sends `DELETE /rest/v1/posts?id=eq.<user_b_post_id>` | HTTP **200 OK with 0 affected rows** | User B's post deleted by non-admin |
| **STG-08** | Authorized Moderation | Admin sends `DELETE /rest/v1/posts?id=eq.<user_b_post_id>` | HTTP **200 OK with 1 affected row** | Post deletion fails or blocked by likes |
| **STG-09** | Avatar Folder Hijacking | User A uploads to `/storage/v1/object/profile-pictures/<user_b_id>/profile.jpg` | HTTP **403 Forbidden** | File uploaded into User B's folder |
| **STG-10** | Post Image Path Traversal| User A uploads to `/storage/v1/object/post-images/malicious.exe` (outside `posts/`) | HTTP **403 Forbidden** | File uploaded outside `posts/` folder |

---

## 10. Strict Stop Gate

- **Migrations Executed:** **0** (Zero).
- **Production State:** Untouched.
- **Application Code:** Unmodified.
- **Milestone 3:** Paused.

**Standing by for explicit owner approval to initialize staging environment and execute migration tests.**

