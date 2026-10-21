# Deployment Runbook — Vercel + Render + Supabase + APK

## Topology
- Website: `website/` → Vercel.
- Rust API: `backend/` Docker service → Render.
- Identity/database/storage/realtime: existing Supabase project.
- Android APK: signed artifact on GitHub Releases, linked from website.
- Flutter Android remains a native app; Vercel website is an additional web experience, not an APK runtime.

## Stage 1: staging first
1. Create/identify a staging Supabase project and apply reviewed migrations there.
2. Configure Auth redirect allowlist for local dev, Vercel preview and production domains explicitly.
3. Add a Vercel preview deployment for `website/`; use staging Supabase variables and a staging API URL.
4. Deploy Render API to staging with secrets stored only in Render settings.
5. Run RLS, Storage, cross-user and API tests; do not deploy real payment flow until provider and webhook tests are complete.

## Vercel website settings
- Framework: Next.js (if implemented as specified).
- Root Directory: `website`.
- Build command/output: use package configuration; normally `npm run build` for Next.js.
- Public variables: Supabase URL and publishable/anon key, API base URL, APK release URL, if needed.
- Do NOT put `SUPABASE_SERVICE_ROLE_KEY`, database password, webhook secret or payment private key in `NEXT_PUBLIC_*` or any browser bundle.
- Confirm headers, cache policies and that private API responses aren't publicly cached.

## Render Rust service settings
- Runtime: Docker; Dockerfile at `backend/Dockerfile` or specify correct context if configured at repo root.
- Process listens on `0.0.0.0:$PORT`; expose `/healthz` and `/readyz`.
- Configure exact production website origin(s) for CORS.
- Set DB/Auth secrets in Render environment dashboard only. Keep a non-secret `.env.example` in repo.
- Deploy from a protected branch; verify image build, health checks, logs, API contract, error handling and rollout recovery.

## Supabase configuration
- Verify RLS/grants/Storage policies and Auth URL configuration.
- Use distinct staging/production keys. Public key is safe for clients only with correct policies.
- Take/verify backup before migration. Apply a reviewed migration explicitly and verify post-deploy policies and test accounts.
- Avoid running destructive SQL or unreviewed automatic migrations as part of every app boot.

## APK release process
1. Verify package/application ID and version in Android project.
2. Build signed release with protected signing materials on owner-controlled machine/CI secret store.
3. Install and test on a clean device.
4. Generate SHA-256 (PowerShell):
   ```powershell
   Get-FileHash .\build\app\outputs\flutter-apk\app-release.apk -Algorithm SHA256
   ```
5. Attach APK and release notes to a tagged GitHub Release.
6. Verify asset URL downloads the file; verify published checksum matches downloaded file.
7. Set website's public APK URL to that **verified actual asset URL**. Do not invent the URL before release is published.

## Smoke tests after deploy
- Vercel pages load on desktop/mobile; search and deep links work; auth redirect and logout are correct.
- Guest only sees public content; User A cannot access User B private data.
- Rust health/readiness return expected status without secrets; CORS rejects unrelated origins.
- Payment webhooks accept valid sandbox events and reject invalid/replayed events; no unpaid session access.
- APK can download on Android and its checksum/signature/version are correct.

## Rollback
- Vercel: restore previous known-good deployment.
- Render: redeploy previous known-good image/commit and confirm health.
- Database: use documented forward-fix or approved restore plan; do not improvise schema rollback if it would destroy new production data.
- APK: keep previous release asset and release notes, then point site to an explicitly verified prior version if required.
- After rollback, disable unsafe payment entry points if payment state is ambiguous and reconcile against provider truth.
