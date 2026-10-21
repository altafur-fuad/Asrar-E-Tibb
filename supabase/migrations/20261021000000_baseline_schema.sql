-- ==============================================================================
-- Migration 20261021000000: Staging Baseline Schema & Storage Bucket Initialization
-- Purpose:
--   Reproduces the complete Asrar-e-Tibb database schema and storage bucket configuration
--   for isolated local or cloud staging environments WITHOUT copying real production user data.
-- Author: Asrar-e-Tibb Security Gate (Stage 3A Canonical)
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
