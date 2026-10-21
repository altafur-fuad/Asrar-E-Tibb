# Asrar-e-Tibb — Project Structure Audit

**Reference Specification:** [`docs/PROJECT_STRUCTURE.md`](PROJECT_STRUCTURE.md)
**Date:** October 21, 2026
**Status:** Audit Completed & Structure Reconciled

---

## 1. Executive Summary

This audit assesses the actual repository layout against the canonical target structure defined in [`docs/PROJECT_STRUCTURE.md`](PROJECT_STRUCTURE.md). All non-negotiable boundaries have been strictly enforced:
1. **Flutter Mobile Application** remains at the repository root (`lib/`, `android/`, `assets/`, `test/`, `pubspec.yaml`).
2. **Flutter Web Platform** directory (`web/`) is preserved untouched and has **NOT** been replaced or repurposed.
3. **Responsive Next.js Website** is housed in `website/` (dedicated Vercel root).
4. **Rust / Axum Microservice** is housed in `backend/api/` (dedicated Render root).
5. **Canonical Database Migration History** is consolidated under `supabase/migrations/`.
6. **Reference SQL** in `backend/migrations/` is preserved as an audit copy and marked as non-executable.
7. **Automated Android APK Release Workflow** is established in `.github/workflows/android-release.yml`.
8. **Automated CI Validation** is configured in `.github/workflows/ci.yml`.

---

## 2. Structure Comparison Matrix

| Component / Path | Target Structure Specification | Current Repository Status | Action Taken / Status |
|---|---|---|---|
| **Root Flutter App** | `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml` | Present at repository root | Reused & preserved intact |
| **Flutter Source** | `lib/` (colors, themes, widgets, auth, farmacia, tibbnews, admin) | Present with Milestone 1 & 2 modernizations | Reused & preserved; 25/25 tests passing |
| **Flutter Web** | `web/` (Flutter web entrypoint only) | Present at repository root | Strictly preserved; never touched by Next.js |
| **Flutter Tests** | `test/` (widget and unit tests) | Present (`widget_test.dart`, `auth_navigation_test.dart`, `design_system_test.dart`) | Reused & passing (25/25) |
| **Flutter Datasets** | `assets/` (`medicine.csv`, `generic.csv`, logos, images) | Present | Reused & parsed into website data |
| **Website Root** | `website/` (Vercel deployment root) | Present and fully configured | Implemented Next.js 14 App Router |
| **Website Pages** | `website/src/app/` (`page.tsx`, `medicines/`, `medicines/[id]`, `tibbnews/`, `farmacia/`, `download/`, `login/`, `signup/`, `about/`, `contact/`, `privacy/`, `terms/`) | Present and verified | All 117 pages statically built and tested |
| **Website Components**| `website/src/components/` (Navbar, Footer, MedicineCard, MedicineImageBadge, CartDrawer) | Present | Implemented with zero-runtime CSS tokens |
| **Website Datasets**  | `website/src/data/medicines.json` (2,939 curated medicines) | Present (1.39 MB) | Build-time static JSON; fast & offline-ready |
| **Website Tests**     | `website/test/website.test.js` | Present | 3/3 automated tests passing |
| **Website Config**    | `package.json`, `tsconfig.json`, `next.config.js`, `vercel.json`, `.env.example` | Present | Validated with Next.js 14.2 |
| **Rust Backend Root** | `backend/api/` (Render deployment root) | Present | Axum 0.7 + Tokio async runtime service |
| **Rust Routes**       | `src/routes/health.rs`, `src/routes/app_release.rs` | Present | Implemented `/healthz`, `/latest`, `/download` |
| **Rust Container**    | `backend/api/Dockerfile`, `.dockerignore` | Present | Multi-stage lean Dockerfile (~40 MB image) |
| **Staging Tests**     | `backend/tests/verify_staging_security.js` | Present | Preserved for non-production verification |
| **Reference SQL**     | `backend/migrations/` | Present | Preserved as audit copy; labeled non-canonical |
| **Canonical SQL**     | `supabase/migrations/` (0000 to 0003) | Present | Sole canonical migration sequence |
| **Supabase Config**   | `supabase/config.toml` | Present | Preserved |
| **Shared Docs**       | `docs/` (design, security audits, architecture) | Present | Preserved and expanded with implementation docs |
| **Release Workflow**  | `.github/workflows/android-release.yml` | Present | Configured for tag & dispatch release |
| **CI Workflow**       | `.github/workflows/ci.yml` | Present | Validates Website, Rust, and Flutter |
| **Render Blueprint**  | `render.yaml` | Present | Configured for `asrar-e-tibb-api` |
| **Git Configuration** | `.gitignore` | Extended | Ignores `.next`, `node_modules`, `target`, `.env` |

---

## 3. Discrepancies, Duplicates & Resolutions

### 3.1 Flutter Web vs. Next.js Isolation
- **Potential Risk:** Accidental collision or overwriting of the root `web/` directory when creating web application files.
- **Resolution:** `web/` was left 100% untouched for Flutter Web. All Next.js files reside exclusively inside `website/`.

### 3.2 Dual Migration Histories
- **Potential Risk:** Executing both `backend/migrations/` and `supabase/migrations/` creating race conditions or conflicting schema states.
- **Resolution:** Formally designated `supabase/migrations/` as the **sole canonical migration history**:
  - `20261021000000_baseline_schema.sql`
  - `20261021000001_security_functions_and_triggers.sql`
  - `20261021000002_rls_policies.sql`
  - `20261021000003_storage_policies.sql`
  `backend/migrations/` is retained as an informational audit reference only.

### 3.3 Dynamic Medicine Route (`[slug]` vs `[id]`)
- **Potential Risk:** Route naming divergence between `[slug]` and `[id]`.
- **Resolution:** Renamed parameter folder to `website/src/app/medicines/[id]`. Updated `generateStaticParams()` and the lookup handler to resolve both semantic slug strings (e.g. `napa-500-mg-tablet`) and numeric record IDs (e.g. `1`), satisfying both URL styles without duplicate routes.

### 3.4 Route Parity for TibbNews (`/news` vs `/tibbnews`)
- **Potential Risk:** Inconsistent URL targeting between documentation and application routing.
- **Resolution:** Provided canonical `/tibbnews` route re-exporting the feed component so both `/tibbnews` and `/news` operate identically.

### 3.5 Docker Ignore Configuration
- **Potential Risk:** Container builds in `backend/api/` uploading unnecessary compilation caches (`target/`) or sensitive local files.
- **Resolution:** Added `backend/api/.dockerignore` strictly omitting `target/`, `.env`, and VCS metadata.

---

## 4. Verification & Health Summary

1. **Website Compilation (`npm run build`):**
   - Success: 117/117 static pages generated.
   - Bundle size: 87.3 kB shared JS, fast initial page load.
2. **Website Automated Testing (`npm test`):**
   - 3/3 tests passing (dataset schema, integrity, cart calculation).
3. **Flutter App Automated Testing (`flutter test`):**
   - 25/25 tests passing (design tokens, auth validation, admin role verification).
4. **Secrets Audit:**
   - Zero hardcoded passwords, tokens, service keys, or private secrets in version control.
   - `.env` explicitly ignored; `.env.example` files provided for configuration templates.

