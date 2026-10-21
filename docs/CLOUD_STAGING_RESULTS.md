# Asrar-e-Tibb: Stage 3B — Cloud Supabase Staging & Security Migration Report

> **Document:** Cloud Staging Environment Audit, Canonical SQL Migration Execution & Security Verification Report
> **Status:** Stage 3B Active — Migrations Verified on Cloud Staging, Initial Live Security Tests Passing (3/10 Verified)
> **Staging Project URL:** `https://zhhreesobwvhzmwshaqh.supabase.co`
> **Staging Project Reference:** `zhhreesobwvhzmwshaqh`
> **Production Project Reference (STRICT ISOLATION):** `ynssqrpfbeavuynxcwxj` (100% UNTOUCHED)
> **Staging Administrator Auth ID:** `7d557deb-4459-409b-84cf-289dbb52324b`
> **Repository Root:** `e:/Asrar-E-Tibb`
> **Author:** Lead Backend & Database Security Engineer
> **Date:** 2026-10-21

---

## 1. Environment & Target Isolation Verification

### 1.1 Strict Project Boundary Confirmation:
- **Authorized Target:** Hosted Supabase Staging Project `zhhreesobwvhzmwshaqh` (`https://zhhreesobwvhzmwshaqh.supabase.co`).
- **Production Reference:** `ynssqrpfbeavuynxcwxj`.
- **Isolation Guarantee:** Zero network requests, connection strings, migrations, or database writes have been sent to production. Production remains strictly untouched.
- **Client Security Tokens:** Configured locally in git-ignored `e:/Asrar-E-Tibb/.env`. No secrets or database passwords are committed to Git.

---

## 2. Remote Database Metadata Inspection Results

Live read-only probing was executed against `https://zhhreesobwvhzmwshaqh.supabase.co` using the verified staging client API key:

### 2.1 Table Existence & Anonymous Access Control (14/14 Verified):
All 14 application tables exist and strictly enforce Row Level Security, rejecting anonymous queries with PostgreSQL error `42501 (permission denied)`:

| Table Name | Schema | Live HTTP Status | RLS Response / Enforcement |
|---|---|---|---|
| `public.users` | `public` | `401 Unauthorized` | Code `42501` (permission denied for table users) |
| `public.profiles` | `public` | `401 Unauthorized` | Code `42501` (permission denied for table profiles) |
| `public.patients` | `public` | `401 Unauthorized` | Code `42501` (permission denied for table patients) |
| `public.doctors` | `public` | `401 Unauthorized` | Code `42501` (permission denied for table doctors) |
| `public.pharmacists` | `public` | `401 Unauthorized` | Code `42501` (permission denied for table pharmacists) |
| `public.shop_owners` | `public` | `401 Unauthorized` | Code `42501` (permission denied for table shop_owners) |
| `public.posts` | `public` | `401 Unauthorized` | Code `42501` (permission denied for table posts) |
| `public.post_images` | `public` | `401 Unauthorized` | Code `42501` (permission denied for table post_images) |
| `public.post_likes` | `public` | `401 Unauthorized` | Code `42501` (permission denied for table post_likes) |
| `public.comments` | `public` | `401 Unauthorized` | Code `42501` (permission denied for table comments) |
| `public.notifications` | `public` | `401 Unauthorized` | Code `42501` (permission denied for table notifications) |
| `public.schedules` | `public` | `401 Unauthorized` | Code `42501` (permission denied for table schedules) |
| `public.notes` | `public` | `401 Unauthorized` | Code `42501` (permission denied for table notes) |
| `public.todos` | `public` | `401 Unauthorized` | Code `42501` (permission denied for table todos) |

### 2.2 Security Functions & RPC Probe-Resistance:
- **`public.is_admin(check_user_id)`:** Verified live via `POST /rest/v1/rpc/is_admin`. An unauthenticated caller querying an arbitrary user UUID returned `Status 200` with value `false`. Information disclosure probe prevention is fully operative.
- **`app_security.is_trusted_admin_context()`:** Verified live via `POST /rest/v1/rpc/is_trusted_admin_context`. Returned `Status 404 (PGRST202: Could not find function in schema cache)`. Private helper isolation is fully operative.

### 2.3 Storage Buckets:
- **`profile-pictures`:** Verified live via `POST /storage/v1/object/list/profile-pictures`. Returned `Status 200 []`.
- **`post-images`:** Verified live via `POST /storage/v1/object/list/post-images`. Returned `Status 200 []`.

---

## 3. Automated Security Verification Results (STG-01 to STG-10)

The automated test harness `backend/tests/verify_staging_security.js` was executed against `https://zhhreesobwvhzmwshaqh.supabase.co`:

```text
================================================================
Asrar-e-Tibb: Cloud Staging Security Verification Suite
Target: https://zhhreesobwvhzmwshaqh.supabase.co
================================================================

[PASS] STG-01: Unauthenticated access to protected personal data
   Details: Status: 401, Code: 42501, Message: permission denied for table schedules
[PASS] STG-04: Forged administrator public registration blocked
   Details: Status: 401, Code: 42501, Message: permission denied for table users
[PASS] STG-10: Storage post-image root path traversal rejected
   Details: Status: 400, Response: {"statusCode":"403","error":"Unauthorized","message":"new row violates row-level security policy","code":"AccessDenied"}
[AWAITING] STG-02: User A self-promotion (Requires User A credentials)
[AWAITING] STG-03: User A self-unblocking (Requires User A credentials)
[AWAITING] STG-05: Cross-user private note access (Requires User A & User B credentials)
[AWAITING] STG-06: Cross-user private note deletion (Requires User A & User B credentials)
[AWAITING] STG-07: Unauthorized post moderation deletion (Requires User A & User B credentials)
[AWAITING] STG-08: Authorized administrator moderation (Requires Administrator credentials)
[AWAITING] STG-09: Storage profile picture folder hijacking (Requires User A & User B credentials)

================================================================
Cloud Staging Security Verification Results: 3/10 verified passed
================================================================
```

---

## 4. Required Action to Complete Remaining 7 Authenticated Tests

To run scenarios **STG-02, STG-03, STG-05, STG-06, STG-07, STG-08, STG-09**, normal authenticated JWT sessions are required for User A, User B, and the Administrator.

### Step 1: Provision Synthetic Test Users A & B
Execute this script in the Supabase Dashboard SQL Editor (runs as database superuser `postgres`):

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

-- Synthetic User A: user_a@staging.test (Password: StagingTest123!)
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  'a1111111-1111-1111-1111-111111111111',
  'authenticated',
  'authenticated',
  'user_a@staging.test',
  extensions.crypt('StagingTest123!', extensions.gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{"name":"Synthetic User A"}',
  now(),
  now(),
  ''
)
ON CONFLICT (id) DO UPDATE SET
  email = 'user_a@staging.test',
  encrypted_password = extensions.crypt('StagingTest123!', extensions.gen_salt('bf')),
  email_confirmed_at = now();

INSERT INTO public.users (id, email, name, role, is_admin, verified, is_blocked)
VALUES (
  'a1111111-1111-1111-1111-111111111111',
  'user_a@staging.test',
  'Synthetic User A',
  'patient',
  false,
  false,
  false
)
ON CONFLICT (id) DO UPDATE SET
  role = 'patient',
  is_admin = false,
  is_blocked = false;

-- Synthetic User B: user_b@staging.test (Password: StagingTest123!)
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  'b2222222-2222-2222-2222-222222222222',
  'authenticated',
  'authenticated',
  'user_b@staging.test',
  extensions.crypt('StagingTest123!', extensions.gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{"name":"Synthetic User B"}',
  now(),
  now(),
  ''
)
ON CONFLICT (id) DO UPDATE SET
  email = 'user_b@staging.test',
  encrypted_password = extensions.crypt('StagingTest123!', extensions.gen_salt('bf')),
  email_confirmed_at = now();

INSERT INTO public.users (id, email, name, role, is_admin, verified, is_blocked)
VALUES (
  'b2222222-2222-2222-2222-222222222222',
  'user_b@staging.test',
  'Synthetic User B',
  'patient',
  false,
  false,
  false
)
ON CONFLICT (id) DO UPDATE SET
  role = 'patient',
  is_admin = false,
  is_blocked = false;
```

### Step 2: Configure Staging Credentials in Local `.env`
Add the following entries directly to `e:\Asrar-E-Tibb\.env` (which is git-ignored and never committed or shared in chat):

```env
STAGING_USER_A_EMAIL=user_a@staging.test
STAGING_USER_A_PASSWORD=StagingTest123!

STAGING_USER_B_EMAIL=user_b@staging.test
STAGING_USER_B_PASSWORD=StagingTest123!

# Enter the credentials for administrator 7d557deb-4459-409b-84cf-289dbb52324b:
STAGING_ADMIN_EMAIL=<your_admin_email>
STAGING_ADMIN_PASSWORD=<your_admin_password>
# OR paste the admin JWT:
# STAGING_ADMIN_TOKEN=<admin_access_token>
```

