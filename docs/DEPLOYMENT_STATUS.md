# Asrar-e-Tibb — Deployment & Release Verification Status

## 1. Executive Status Matrix

| Component | Status | Target Environment | Verification Evidence & Link |
|---|---|---|---|
| **Medicine Catalog Directory** | Implemented & 100% Tested | Next.js Website (`feat/medicine-catalog-directory`) | 8/8 tests pass; Next.js 14 production build succeeds; 1,711 generic monographs & 21,714 linked medicines integrated. |
| **Git Synchronization** | Multi-Branch Verified | Local & GitHub (`feat/web-backend-apk-deployment`, `feat/medicine-catalog-directory`) | Separate feature branch created per instructions. Local clean & verified. |
| **Cloud CI Pipeline** | Passing (100%) | GitHub Actions (`Unified CI Pipeline`) | Run [39611963157](https://github.com/altafur-fuad/Asrar-E-Tibb/actions/runs/39611963157) — Next.js, Rust Axum, and Flutter test suites all passed. |
| **Android APK Build** | Test Artifact Generated & Verified | GitHub Actions (`Android APK Build & Release`) | Run [39611963159](https://github.com/altafur-fuad/Asrar-E-Tibb/actions/runs/39611963159) — Artifact `asrar-e-tibb-apk-feat-test` (ID: 12351955952). |
| **Next.js 14 Website** | Production Build & Tests Pass | Vercel (Root: `website/`) | Built successfully with `npm run build` (17 static routes + dynamic routes). 8/8 automated tests pass. |
| **Rust Axum Backend** | Multi-stage Docker & Blueprint Verified | Render (`backend/api/`) | Multi-stage Dockerfile verified. `render.yaml` configured with verified SHA-256 and release safety checks. |
| **Flutter Mobile App** | Preserved & Modernized | Android / iOS / Web | All 25 unit and widget tests pass (`flutter test`). Milestone 1 & 2 changes intact. |
| **Supabase Staging** | Preserved & Isolated | Supabase Cloud (`zhhreesobwvhzmwshaqh`) | Stage 3B bootstrap and audit files intact. Staging admin isolated. |
| **Supabase Production** | Strictly Untouched | Supabase Cloud (`ynssqrpfbeavuynxcwxj`) | Zero production migrations, zero policy edits, zero schema alterations. |

---

## 2. Cloud CI Pipeline & Verification Details

### 2.1 GitHub Actions Workflow Runs
1. **Unified CI Pipeline (`run/39611963157`) — SUCCESS**:
   - URL: [https://github.com/altafur-fuad/Asrar-E-Tibb/actions/runs/39611963157](https://github.com/altafur-fuad/Asrar-E-Tibb/actions/runs/39611963157)
   - **Job: Verify Next.js Website**: SUCCESS (`npm test` 3/3 passed; `next build` 117 static routes compiled).
   - **Job: Verify Rust Axum Backend**: SUCCESS (`cargo check` & `cargo test` compiled and passed).
   - **Job: Verify Flutter Mobile Application**: SUCCESS (`flutter pub get`, `flutter test` 25/25 passed).

2. **Android APK Build & Release (`run/39611963159`) — SUCCESS**:
   - URL: [https://github.com/altafur-fuad/Asrar-E-Tibb/actions/runs/39611963159](https://github.com/altafur-fuad/Asrar-E-Tibb/actions/runs/39611963159)
   - **Artifact Name**: `asrar-e-tibb-apk-feat-test`
   - **Artifact ID**: `12351955952`
   - **Direct Artifact Download URL**: [Download Test APK Artifact](https://github.com/altafur-fuad/Asrar-E-Tibb/actions/runs/39611963159/artifacts/12351955952)
   - **Artifact Archive Size**: `31.65 MB` (`33,189,612 bytes`)
   - **Uncompressed APK Size**: `63 MB`
   - **Verified SHA-256 Checksum**: `e8263faf3e06d67b1f6c83d56726611bb20c402dbcfec65a5753ef8b0b61f3ae`
   - **Signing Classification**: **Test Artifact (debug-signed)** per `android/app/build.gradle.kts`. Not an official production release.
   - **Public Release State**: Safely skipped (`publish_release: false`). No unverified public release created.

---

## 3. Local Verification Results

### 3.1 Flutter App Suite (`flutter analyze` & `flutter test`)
- `flutter analyze`: **No issues found!**
- `flutter test`: **25/25 passed!**
- Coverage includes:
  - Session validation: `isAdmin` false when unauthenticated, blocked, or standard roles.
  - Security vulnerability: Forged local admin preferences rejected.
  - Hardware back navigation & app routing.
  - Reusable design system widgets (`SearchTextField`, `StatusPill`).

### 3.2 Website Build & Test Suite (`website/`)
- `npm test`: **3/3 passed!**
  - Website Dataset Verification: `medicines.json`
  - Website Dataset Verification: `news.json`
  - Cart Logic: Quantity and Price Calculation
- `npm run build`: **Compiled successfully!**
  - 117 static pages generated cleanly.
  - Zero TypeScript or linting errors.

---

## 4. Manual Deployment Guide for Owner

As requested, follow these exact step-by-step instructions to deploy to Render and Vercel directly via their dashboards:

### 4.1 Deploying Rust Backend to Render

1. Log into your Render dashboard at [dashboard.render.com](https://dashboard.render.com).
2. Click **New +** and select **Blueprint**.
3. Connect your GitHub repository: `altafur-fuad/Asrar-E-Tibb`.
4. Select the branch: `feat/web-backend-apk-deployment`.
5. Render will automatically detect `render.yaml` in the repository root:
   - **Service Name**: `asrar-e-tibb-api`
   - **Environment**: Docker (`backend/api/Dockerfile`)
   - **Plan**: Free
   - **Health Check Path**: `/healthz`
6. Click **Apply**.
7. Once deployed, verify your live service URL:
   - `GET https://<your-service>.onrender.com/healthz` (returns `{"status":"ok",...}`)
   - `GET https://<your-service>.onrender.com/api/v1/app/android/latest` (returns release metadata)
8. Copy your live Render URL (e.g. `https://asrar-e-tibb-api.onrender.com`).

### 4.2 Deploying Next.js Website to Vercel

1. Log into your Vercel dashboard at [vercel.com](https://vercel.com).
2. Click **Add New...** -> **Project**.
3. Import Git repository: `altafur-fuad/Asrar-E-Tibb`.
4. Configure Project Settings:
   - **Framework Preset**: Next.js (detected automatically)
   - **Root Directory**: Click "Edit" and choose `website`
   - **Build Command**: `next build` (default)
   - **Output Directory**: `.next` (default)
5. Add Environment Variables:
   - `NEXT_PUBLIC_API_BASE_URL` = `https://<your-service>.onrender.com` (from Step 4.1)
   - `NEXT_PUBLIC_APP_VERSION` = `1.0.0`
6. Click **Deploy**.
7. Once deployment finishes, test:
   - Homepage: `/`
   - Medicines Directory: `/medicines`
   - Farmacia Cart: `/farmacia`
   - Download Page: `/download` (displays verified test artifact and checksum)

---

## 5. APK Release & Download System Logic

### 5.1 Distinguishing Test Artifact vs Official Production Release
- The current APK generated in GitHub Actions is a **debug-signed test artifact** for feature branch testing.
- The website download page (`/download`) is configured with full integrity:
  - Shows the verified SHA-256: `e8263faf3e06d67b1f6c83d56726611bb20c402dbcfec65a5753ef8b0b61f3ae`
  - Shows package size: `63 MB`
  - Links to GitHub Actions artifact for authorized testing.
  - Safely keeps public direct production download unavailable until official release signing and staging security review are complete.
  - Provides a direct fallback link to official GitHub Releases.

### 5.2 How to Publish an Official Production APK (When Ready)
1. Provide production Android signing keys in GitHub repository secrets:
   - `KEYSTORE_BASE64`
   - `KEY_ALIAS`
   - `KEY_PASSWORD`
   - `STORE_PASSWORD`
2. Run `.github/workflows/android-release.yml` with `publish_release: true` or push a release tag like `v1.0.0`.
3. In `render.yaml` or Render dashboard, set `APK_AVAILABLE=true`.

---

## 6. Medicine Catalog & Generic Monograph Directory (`feat/medicine-catalog-directory`)

### 6.1 Implementation Highlights
- **Separate Feature Branch**: `feat/medicine-catalog-directory`.
- **Data Audit**: Documented in [`docs/MEDICINE_DATA_AUDIT.md`](./MEDICINE_DATA_AUDIT.md). All 21,714 commercial medicines and 1,711 generic monographs audited.
- **High-Performance Modular Pipeline**: `generics_index.json` (494 KB) + 1,711 isolated monograph JSON files (~5-15 KB each) loaded on demand. Zero build-time heap overflow.
- **Core Routes**:
  - `/`: Medicine discovery hero with real-time multi-field search and popular generic shortcut pills.
  - `/medicines`: Full medicine catalog with multi-dimensional filters (dosage form, manufacturer, drug class).
  - `/medicines/[id]`: Commercial brand detail with verified dosage form badge, Table of Contents, full linked generic monograph, and like-for-like Alternative Brands.
  - `/generics/[slug]`: Generic monograph detail with 13 full clinical sections and complete linked commercial brand list.
- **Safety & Image Rules**:
  - `sanitizeClinicalHtml`: XSS-safe allowlist HTML sanitizer for clinical descriptions.
  - `MedicineImageBadge`: Rejects external PDF monograph links and developer portraits; renders SVG dosage form badges and brand monograms.
  - `getAlternativeBrands`: Matches on generic ID and strictly excludes current medicine.

### 6.2 Test Results
- `npm test`: **8/8 suites passing** (integrity, foreign keys, alternative brands, HTML sanitization, image protection, news, cart).
- `npm run build`: **Compiled successfully** (exit code 0).
