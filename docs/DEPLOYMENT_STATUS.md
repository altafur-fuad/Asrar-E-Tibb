# Asrar-e-Tibb — Deployment & Release Status

## 1. Status Overview

| Component | Status | Target Host | Verification Evidence |
|---|---|---|---|
| **Modern Website** | Ready for Vercel Deployment | Vercel (`website/`) | Built successfully with `npm run build` (117 static pages generated). 3/3 automated tests pass. |
| **Rust API Backend** | Ready for Render Deployment | Render (`asrar-e-tibb-api`) | Multi-stage Dockerfile verified. `render.yaml` blueprint ready. Endpoints for healthz, release metadata, and safe redirect implemented. |
| **Android APK Distribution** | Pipeline Ready | GitHub Actions & Releases | `.github/workflows/android-release.yml` created. SHA-256 checksum generation verified. |
| **Flutter Mobile App** | Preserved & Modernized | Android / iOS / Web | All 25 unit and widget tests pass (`flutter test`). Milestone 1 & 2 changes preserved. |
| **Supabase Database & Staging** | Preserved & Isolated | Supabase Cloud (`zhhreesobwvhzmwshaqh`) | Migrations consolidated in `supabase/migrations/` (canonical). Zero changes applied to production (`ynssqrpfbeavuynxcwxj`). |
| **Canonical Structure** | Fully Reconciled | Git Repository | Documented in `docs/PROJECT_STRUCTURE.md` & `docs/PROJECT_STRUCTURE_AUDIT.md`. |

---

## 2. Verification Evidence & Test Results

### 2.1 Next.js Website Build
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

### 2.2 Website Test Suite (`npm test`)
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

### 2.3 Flutter App Verification (`flutter test`)
```text
00:05 +25: All tests passed!
```
- Total tests: 25
- Passing: 25
- Failing: 0
- Coverage: AppColors, SearchTextField, Role-based routing, Session validation, IntroPage navigation, Admin privilege escalations.

---

## 3. Deployment URLs & Endpoints

### 3.1 Website (Vercel)
- **Status**: Ready for owner GitHub authorization / import.
- **Repository Root for Vercel**: `website`
- **Framework Preset**: Next.js
- **Target URL**: Assigned upon Vercel project creation (e.g. `https://asrar-e-tibb.vercel.app`).
- **Required Build Environment Variables**:
  - `NEXT_PUBLIC_APP_VERSION`: `1.0.0`
  - `NEXT_PUBLIC_API_BASE_URL`: `https://asrar-e-tibb-api.onrender.com`
  - `NEXT_PUBLIC_GITHUB_REPO_URL`: `https://github.com/altafur-fuad/Asrar-E-Tibb`

### 3.2 Rust Backend (Render)
- **Status**: Blueprint ready (`render.yaml`).
- **Service Name**: `asrar-e-tibb-api`
- **Target URL**: `https://asrar-e-tibb-api.onrender.com`
- **Health Endpoint**: `https://asrar-e-tibb-api.onrender.com/healthz`
- **Latest Release Metadata**: `https://asrar-e-tibb-api.onrender.com/api/v1/app/android/latest`
- **Direct Download Redirect**: `https://asrar-e-tibb-api.onrender.com/api/v1/app/android/download`

### 3.3 Android APK Public Distribution
- **Target URL**: `https://github.com/altafur-fuad/Asrar-E-Tibb/releases/latest/download/Asrar-E-Tibb.apk`
- **Checksum Asset**: `https://github.com/altafur-fuad/Asrar-E-Tibb/releases/latest/download/Asrar-E-Tibb.apk.sha256`
- **Status**: Will be published upon pushing git tag `v1.0.0` or triggering `.github/workflows/android-release.yml`.

---

## 4. Remaining Owner Actions (Authentication & Deployment)

Because account authentication credentials (Vercel token, Render token, and Android production keystore) are securely managed by the project owner and must never be shared in chat, the following exact steps complete the deployment:

### Step 1: Push Feature Branch to GitHub
```bash
git push -u origin feat/web-backend-apk-deployment
```

### Step 2: Trigger APK Release on GitHub
1. Navigate to **Actions** in `https://github.com/altafur-fuad/Asrar-E-Tibb`.
2. Select **Android APK Build & Release**.
3. Click **Run workflow** -> Version `1.0.0` -> **Run workflow**.
4. GitHub Actions will build the release APK, generate `Asrar-E-Tibb.apk.sha256`, and publish them under GitHub Releases `v1.0.0`.

### Step 3: Deploy Rust API on Render
1. Open [dashboard.render.com](https://dashboard.render.com).
2. Click **New +** -> **Blueprint**.
3. Select `altafur-fuad/Asrar-E-Tibb` and branch `feat/web-backend-apk-deployment` (or `main` after merging).
4. Render detects `render.yaml` and provisions `asrar-e-tibb-api`.
5. Once deployed, verify `https://asrar-e-tibb-api.onrender.com/healthz`.

### Step 4: Deploy Website on Vercel
1. Open [vercel.com/new](https://vercel.com/new).
2. Import `altafur-fuad/Asrar-E-Tibb`.
3. Set **Root Directory** to `website`.
4. Add environment variables:
   - `NEXT_PUBLIC_API_BASE_URL` = `https://asrar-e-tibb-api.onrender.com`
   - `NEXT_PUBLIC_APP_VERSION` = `1.0.0`
5. Click **Deploy**.
