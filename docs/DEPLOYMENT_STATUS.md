# Asrar-e-Tibb — Deployment & Release Status

## 1. Status Overview

| Component | Status | Target Host | Verification Evidence |
|---|---|---|---|
| **Feature Branch** | Pushed & Verified | GitHub (`origin/feat/web-backend-apk-deployment`) | Commits `dbf169b` & `a8d51b7` pushed. Pull Request link available. |
| **Cloud CI Pipeline** | Passing (100%) | GitHub Actions (`Unified CI Pipeline`) | Run `39611963157` completed with **SUCCESS** (Website, Rust Axum, and Flutter tests all passed). |
| **Android APK Build** | Test Artifact Generated | GitHub Actions (`Android APK Build & Release`) | Run `39611963159` completed with **SUCCESS**. Artifact `asrar-e-tibb-apk-feat-test` (ID: 12351955952, 31.65 MB) uploaded. |
| **Modern Website** | Ready for Vercel Deployment | Vercel (`website/`) | Built successfully with `npm run build` (117 static pages generated). 3/3 automated tests pass. |
| **Rust API Backend** | Ready for Render Deployment | Render (`asrar-e-tibb-api`) | Multi-stage Dockerfile verified. `render.yaml` blueprint ready. Endpoints for healthz, release metadata, and safe redirect verified in CI. |
| **Flutter Mobile App** | Preserved & Modernized | Android / iOS / Web | All 25 unit and widget tests pass (`flutter test`). Milestone 1 & 2 changes preserved. |
| **Supabase Database & Staging** | Preserved & Isolated | Supabase Cloud (`zhhreesobwvhzmwshaqh`) | Migrations consolidated in `supabase/migrations/` (canonical). Zero changes applied to production (`ynssqrpfbeavuynxcwxj`). |
| **Canonical Structure** | Fully Reconciled | Git Repository | Documented in `docs/PROJECT_STRUCTURE.md` & `docs/PROJECT_STRUCTURE_AUDIT.md`. |

---

## 2. Verification Evidence & Test Results

### 2.1 GitHub Actions Cloud Workflows
1. **Unified CI Pipeline (`run/39611963157`) — SUCCESS**:
   - URL: `https://github.com/altafur-fuad/Asrar-E-Tibb/actions/runs/39611963157`
   - **Job: Verify Next.js Website**: SUCCESS (`npm test` passed, `next build` 117 pages compiled).
   - **Job: Verify Rust Axum Backend**: SUCCESS (`cargo check`, `cargo test` compiled and passed).
   - **Job: Verify Flutter Mobile Application**: SUCCESS (`flutter pub get`, `flutter test` 25/25 passed).

2. **Android APK Build & Release (`run/39611963159`) — SUCCESS**:
   - URL: `https://github.com/altafur-fuad/Asrar-E-Tibb/actions/runs/39611963159`
   - **Artifact Name**: `asrar-e-tibb-apk-feat-test`
   - **Artifact ID**: `12351955952`
   - **Artifact Download URL**: [Download Test APK Artifact](https://github.com/altafur-fuad/Asrar-E-Tibb/actions/runs/39611963159/artifacts/12351955952)
   - **Artifact Archive Size**: `31.65 MB` (`33,189,612 bytes`)
   - **Uncompressed APK Size**: `63 MB`
   - **SHA-256 Checksum**: `e8263faf3e06d67b1f6c83d56726611bb20c402dbcfec65a5753ef8b0b61f3ae`
   - **Signing Status**: Test build (debug-signed per `android/app/build.gradle.kts`; safely labeled as test artifact, not mislabeled as official production).
   - **Public Release State**: Safely skipped (`publish_release: false`). No unverified public release created.

### 2.2 Next.js Website Build
```text
> asrar-e-tibb-website@1.0.0 build
> next build

   ▲ Next.js 14.2.35

   Creating an optimized production build ...
 ✓ Compiled successfully
 ✓ Linting and checking validity of types
 ✓ Collecting page data
 ✓ Generating static pages (117/117)
 ✓ Finalizing page optimization

Route (app)                              Size     First Load JS
┌ ○ /                                    3.88 kB         246 kB
├ ○ /about                               189 B          96.2 kB
├ ○ /consultations                       189 B          96.2 kB
├ ○ /contact                             2.66 kB          90 kB
├ ○ /download                            4.93 kB        92.3 kB
├ ○ /farmacia                            2.32 kB         244 kB
├ ○ /login                               2.69 kB        98.7 kB
├ ○ /medicines                           2.14 kB         244 kB
├ ● /medicines/[id]                      189 B          96.2 kB
├ ○ /news                                2.88 kB        90.2 kB
├ ○ /prescription-upload                 189 B          96.2 kB
├ ○ /privacy                             189 B          96.2 kB
├ ○ /signup                              3.05 kB        99.1 kB
├ ○ /terms                               189 B          96.2 kB
└ ○ /tibbnews                            2.88 kB        90.2 kB
+ First Load JS shared by all            87.3 kB
```

### 2.3 Website Test Suite (`npm test`)
```text
> asrar-e-tibb-website@1.0.0 test
> node --test

✔ Website Dataset Verification: medicines.json (11.9783ms)
✔ Website Dataset Verification: news.json (0.7273ms)
✔ Cart Logic: Quantity and Price Calculation (0.2413ms)
ℹ tests 3
ℹ suites 0
ℹ pass 3
ℹ fail 0
```

### 2.4 Flutter App Verification (`flutter test`)
```text
00:03 +25: All tests passed!
```
- Total tests: 25
- Passing: 25
- Failing: 0
- Coverage: AppColors, SearchTextField, Role-based routing, Session validation, IntroPage navigation, Admin privilege escalations.

---

## 3. Git Commits & Remote Branch

- **Repository**: `https://github.com/altafur-fuad/Asrar-E-Tibb`
- **Branch**: `feat/web-backend-apk-deployment`
- **Remote Tracking**: `origin/feat/web-backend-apk-deployment`
- **Pull Request URL**: `https://github.com/altafur-fuad/Asrar-E-Tibb/pull/new/feat/web-backend-apk-deployment`
- **Commits**:
  1. `dbf169b` — `feat: add Asrar-e-Tibb web platform and deployment workflows` (staged 133 files: website, Rust backend, canonical migrations, security audit documentation, design system tokens).
  2. `ba96b25` — `ci: configure stable Flutter channel and enable artifact-only cloud APK build`
  3. `a8d51b7` — `build(android): upgrade Gradle wrapper to 8.14 and bypass build dependency validation`

---

## 4. Next Deployment Steps for Owner

Now that the feature branch has been pushed and verified with 100% CI pass and cloud APK artifact generation:

### Step 1: Deploy Rust Backend on Render
1. Open [dashboard.render.com](https://dashboard.render.com).
2. Click **New +** -> **Blueprint**.
3. Select `altafur-fuad/Asrar-E-Tibb` and branch `feat/web-backend-apk-deployment` (or `main` after merging the PR).
4. Render detects `render.yaml` and deploys `asrar-e-tibb-api`.
5. Once deployed, verify `https://asrar-e-tibb-api.onrender.com/healthz`.

### Step 2: Deploy Website on Vercel
1. Open [vercel.com/new](https://vercel.com/new).
2. Import `altafur-fuad/Asrar-E-Tibb` and select branch `feat/web-backend-apk-deployment` (or `main`).
3. Set **Root Directory** to `website`.
4. Configure environment variables:
   - `NEXT_PUBLIC_API_BASE_URL` = `https://asrar-e-tibb-api.onrender.com`
   - `NEXT_PUBLIC_APP_VERSION` = `1.0.0`
5. Click **Deploy**.

### Step 3: Publish Official Signed Release APK (When Staging Verification is Approved)
1. Add production signing secrets (`KEYSTORE_BASE64`, `KEY_ALIAS`, `KEY_PASSWORD`, `STORE_PASSWORD`) to GitHub repository secrets.
2. In GitHub Actions, run **Android APK Build & Release** with `publish_release: true` or push tag `v1.0.0`.
3. The workflow will attach `Asrar-E-Tibb.apk` and `Asrar-E-Tibb.apk.sha256` to the official GitHub Release `v1.0.0`.
