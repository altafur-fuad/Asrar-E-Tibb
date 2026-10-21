# Asrar-e-Tibb — Canonical Project Structure

**Purpose:** Give Antigravity one unambiguous target structure for the existing Flutter app, the new Next.js website, the Rust/Axum API, Supabase migrations, and Android APK releases.

## Non-negotiable boundaries
1. The repository root remains the existing Flutter application. Do not move or rewrite it as part of website setup.
2. The root `web/` directory belongs to Flutter Web. Never repurpose it for Next.js. The separate website lives only in `website/`.
3. The Rust/Axum service lives only in `backend/api/`.
4. The canonical Supabase migration history lives only in `supabase/migrations/`. Keep `backend/migrations/` as an existing reference/audit copy only if it already contains useful reviewed SQL; do not execute both copies or maintain two competing migration histories.
5. Keep existing `lib/`, `assets/`, `android/`, `test/`, Flutter config files, and current docs intact. Add files around them; do not generate a replacement Flutter app.
6. Never commit `.env` files, passwords, access tokens, service-role keys, signing keystores, or signing passwords.
7. Do not commit APK binaries to the repository. Build and publish APKs as versioned GitHub Release assets.
8. Vercel deploys `website/`; Render deploys the Rust service from `backend/api/`; Supabase remains the authentication/database/storage service.
9. No production database changes or production deployment without separate explicit approval.

---

## Target tree
```text
Asrar-E-Tibb/
├── README.md                         # Project entry point; links to app, website, docs, release
├── pubspec.yaml                      # Existing Flutter app; preserve
├── pubspec.lock                      # Existing Flutter lockfile; preserve
├── analysis_options.yaml             # Existing Flutter analysis config; preserve
├── lib/                              # EXISTING Flutter source; preserve and modernize incrementally
│   ├── app_colors.dart
│   ├── app_themes.dart
│   ├── widgets/
│   ├── identity_login_signup/
│   ├── pages/
│   ├── medicine_page/
│   ├── remainder_notepad/
│   ├── tibbnews/
│   ├── farmacia/
│   ├── admin/
│   └── services/
├── assets/                           # Existing Flutter assets and medicine datasets; preserve
├── android/                          # Existing Flutter Android build/signing configuration
├── ios/                              # Existing, if present
├── web/                              # Flutter Web platform files ONLY; never use for Next.js
├── test/                             # Flutter unit/widget tests
│
├── website/                          # NEW separate Next.js website; Vercel project root
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx                  # Homepage
│   │   ├── medicines/
│   │   │   ├── page.tsx              # Search and catalogue
│   │   │   └── [id]/page.tsx         # Medicine detail/monograph
│   │   ├── tibbnews/page.tsx
│   │   ├── farmacia/page.tsx
│   │   ├── download/page.tsx         # APK version/checksum/download
│   │   ├── login/page.tsx
│   │   ├── signup/page.tsx
│   │   ├── about/page.tsx
│   │   ├── contact/page.tsx
│   │   ├── privacy/page.tsx
│   │   └── terms/page.tsx
│   ├── components/
│   │   ├── layout/                   # Header, footer, navigation
│   │   ├── medicine/                 # Product card, search, image fallback
│   │   ├── tibbnews/                 # Feed/article components
│   │   ├── farmacia/                 # Cart and product UI
│   │   └── ui/                       # Buttons, inputs, badges, dialogs
│   ├── lib/
│   │   ├── supabase/                 # Browser/server clients, if safely configured
│   │   ├── api-client.ts             # Calls Rust backend
│   │   ├── medicines/                # Dataset parsing/indexing/data adapters
│   │   ├── app-release.ts            # Typed APK release API adapter
│   │   └── utils.ts
│   ├── public/                       # Website-only static assets; no APK binary
│   ├── tests/                        # Website component/integration tests
│   ├── .env.example                  # Names/placeholders only; no real credentials
│   ├── next.config.ts
│   ├── package.json
│   ├── tsconfig.json
│   └── README.md                     # Website-specific commands and deployment
│
├── backend/                          # Server-side code and existing security tooling
│   ├── api/                          # NEW Rust/Axum API; Render service root
│   │   ├── src/
│   │   │   ├── main.rs
│   │   │   ├── config.rs
│   │   │   ├── error.rs
│   │   │   └── routes/
│   │   │       ├── mod.rs
│   │   │       ├── health.rs         # GET /healthz
│   │   │       └── app_release.rs    # latest metadata + safe download redirect
│   │   ├── tests/
│   │   ├── Cargo.toml
│   │   ├── Cargo.lock
│   │   ├── Dockerfile
│   │   ├── .dockerignore
│   │   └── .env.example              # Names/placeholders only
│   ├── tests/
│   │   └── verify_staging_security.js # Existing staging test harness; preserve
│   └── migrations/                   # Existing reviewed/reference SQL if present
│                                     # Do NOT execute in addition to canonical migrations
│
├── supabase/                         # Supabase CLI configuration and sole migration history
│   ├── config.toml                   # Existing CLI config
│   └── migrations/
│       ├── 20261021000000_baseline_schema.sql
│       ├── 20261021000001_security_functions_and_triggers.sql
│       ├── 20261021000002_rls_policies.sql
│       └── 20261021000003_storage_policies.sql
│
├── docs/
│   ├── 2. DESIGN.md
│   ├── UI_MODERNIZATION_README.md
│   ├── UI_AUDIT.md
│   ├── SECURITY_AUDIT.md
│   ├── SECURITY_MIGRATION_REVIEW.md
│   ├── SQL_REVIEW_BUNDLE.md
│   ├── LOCAL_STAGING_RESULTS.md
│   ├── CLOUD_STAGING_RESULTS.md         # Add/update only with actual evidence
│   ├── WEB_PLATFORM_IMPLEMENTATION.md
│   ├── DEPLOYMENT_STATUS.md
│   ├── PROJECT_STRUCTURE.md              # Copy this file here
│   └── reference_images/                 # Existing supplied design references
│
├── .github/
│   └── workflows/
│       ├── ci.yml                        # Flutter + website + Rust checks; inspect before adding
│       └── android-release.yml           # Signed APK build and GitHub Release publication
│
├── render.yaml                           # Render API service blueprint
├── .gitignore                            # Extend existing ignore rules; do not replace blindly
└── .env.example                          # Optional root-level shared variable-name reference only
```

---

## Ownership and deployment map

| Component | Directory | Host / destination | Notes |
|---|---|---|---|
| **Android app** | repository root (`lib/`, `android/`, `assets/`) | APK in GitHub Releases | Flutter app remains the source mobile application |
| **Website** | `website/` | Vercel | Set Vercel Root Directory to `website` |
| **Rust API** | `backend/api/` | Render | Docker deployment; listens on `0.0.0.0:$PORT` |
| **Database schema migrations** | `supabase/migrations/` | Supabase staging first | Single canonical migration history |
| **Staging security tests** | `backend/tests/verify_staging_security.js` | Run against explicitly verified staging only | Never run against production |
| **APK build/release workflow** | `.github/workflows/android-release.yml` | GitHub Actions → GitHub Release | Signing material stored only as repository/environment secrets |
| **Shared docs** | `docs/` | Git repository | Do not include secrets or test passwords |

---

## Environment variable boundaries

### `website/.env.example`
```env
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
NEXT_PUBLIC_API_BASE_URL=
```
Only browser-safe values may use the `NEXT_PUBLIC_` prefix. Do not put service-role keys, database passwords, private API tokens, or payment secrets in these variables.

### `backend/api/.env.example`
```env
PORT=10000
ALLOWED_ORIGINS=
ANDROID_RELEASE_METADATA_URL=
ANDROID_RELEASE_DOWNLOAD_URL=
ANDROID_RELEASE_VERSION=
ANDROID_RELEASE_DATE=
ANDROID_RELEASE_SHA256=
ANDROID_RELEASE_NOTES=
```
The backend should report the release as unavailable until valid HTTPS release metadata and an existing APK asset have been configured and verified. Add secret variables only when a real backend feature needs them; never invent placeholder secrets that might accidentally be used as credentials.

### Staging test credentials
Keep any staging-only test credentials in a separate ignored file outside source control. Do not share them between Flutter, website, backend, and production environments. Never use a production credential to run staging tests.

---

## Required deployment behavior
1. Build and test website from `website/`.
2. Deploy website to Vercel with `website/` as its root.
3. Build the Rust API remotely using `backend/api/Dockerfile` and deploy to Render.
4. Verify `GET /healthz` on the actual Render URL.
5. Build a signed release APK using the Android release workflow.
6. Publish the APK and checksum to a versioned GitHub Release, not into the Git repository or Vercel deployment bundle.
7. Configure the Rust release metadata endpoint with the real, verified GitHub Release asset URL.
8. Configure the website to call the actual Render URL and display the APK version, release date, checksum, and download link.
9. Test all public URLs and download flow before claiming deployment complete.
10. If account login, signing credentials, or owner approval is unavailable, complete all safe preparation and document the exact remaining owner action.
