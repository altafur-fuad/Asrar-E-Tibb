# Asrar-e-Tibb — Modern, Realistic UI/UX Modernization Brief

> **Purpose:** Give Antigravity a practical, implementation-focused brief for modernizing the existing Flutter Android application's UI and building a matching responsive website. This document is a design and engineering requirement, not proof that the changes have been implemented.

## 1. Product vision

Make Asrar-e-Tibb feel like a trustworthy, polished digital medicine and traditional-health platform: calm, editorial, clinically responsible, easy to navigate, and realistic enough to ship to real users. The app and website should feel like two surfaces of the same product—not unrelated templates.

The supplied screenshots in `docs/reference_images/` are visual references for composition, spacing, pharmacy merchandising, healthcare trust, and mobile layouts. They are **not** assets to copy, and their brands, doctors, product claims, prices, reviews, and text must not appear in Asrar-e-Tibb. Use the existing Asrar-e-Tibb logo and the project's actual medicine dataset/assets wherever possible.

## 2. Non-negotiable implementation rules

1. **Audit before editing.** Inspect the current Flutter screens, routes, theme, widgets, services, Supabase usage, local assets, medicine dataset format, and Git status. List the actual screens and keep all working features.
2. **Modernize the existing Flutter app**, rather than replacing it with a new app. Preserve the app's existing navigation and business logic unless a verified defect requires a targeted fix.
3. Create the new web app separately in `website/` (recommended Next.js + TypeScript). The root `web/` directory belongs to Flutter's web platform and must not be overwritten.
4. Build a consistent design system before restyling screens. Prefer reusable widgets/components over one-off styling.
5. Use real local medicine/product imagery from `assets/` and the dataset's mapped image paths. Never display a random image as a particular medicine. If the asset is missing, show a neutral branded placeholder.
6. Never invent ratings, customer counts, verified doctor badges, stock levels, prices, delivery promises, medical claims, or consultation/payment success. Clearly label demo content and hide unsupported claims.
7. Do not place Supabase service-role/secret keys, payment credentials, or other server secrets in Flutter/web client code.
8. Do not silently change database schema, Supabase policies, authentication providers, or production records during a UI task. Propose those separately and get approval.
9. Every visible button, tab, search field, filter, menu, and CTA must work or be clearly disabled/marked “Coming soon.” Do not ship inert mock controls.
10. Keep accessibility, small-screen layout, loading/empty/error states, and localization-safe text lengths in scope.

## 3. Visual design direction

### Brand mood

- Premium, calm, clean, trustworthy, contemporary, and health-oriented.
- Strong visual hierarchy and generous whitespace; avoid cluttered product grids, huge hero text on phones, excessive gradients, glassmorphism, neon colors, and generic dashboard styling.
- Keep the Asrar-e-Tibb identity recognizable; do not copy reference brands.

### Starting color tokens

Use centralized semantic tokens and adjust only after checking the current logo/brand assets:

| Token | Value | Use |
|---|---|---|
| `brandForest` | `#064E3B` | Main brand, important navigation, footer |
| `brandGreen` | `#0B6B4B` | Primary actions, active states |
| `brandFresh` | `#23845B` | Positive/selected states |
| `pageIvory` | `#F7F7F2` | Warm, quiet page background |
| `surface` | `#FFFFFF` | Cards, sheets, forms |
| `ink` | `#12231D` | Main text |
| `mutedText` | `#64746C` | Secondary metadata |
| `softSage` | `#E6F0EA` | Subtle panels and chips |
| `accentAmber` | `#E6B84B` | Small promotional highlights only |
| `danger` | `#B42318` | Errors/destructive actions |

Use these as an initial palette—not as permission to apply green to every pixel. Verify contrast for text, icons, controls, disabled states, and focus rings. Avoid communicating status through color alone.

### Type, layout, and components

- Use a readable, modern type family already supported by the project. If adding fonts, verify Bangla glyph support (if Bangla copy is introduced), licensing, app size, and offline availability.
- Follow an 8-point spacing rhythm, consistent corner radii, restrained elevation/shadows, and comfortable touch targets.
- Build shared components: app/web header, bottom navigation, search field, category tile, medicine card, author row, post card, primary/secondary button, filter chips, form field, modal/sheet, status pill, loading skeleton, empty state, error state, and confirmation dialog.
- Keep icon style consistent. Prefer existing icon packages already in use; do not add dependencies without checking the current dependency list.
- Add subtle, short transitions only where they clarify navigation or feedback.

## 4. Flutter Android app: screens to review and modernize

First derive the real screen list from source code. The following list is the expected product scope; if a feature is missing, report it rather than pretending it exists.

### A. App shell and account flow

- Splash/launch screen, onboarding if already part of the flow, identity/role selection, login, sign-up, password reset, and session restore.
- Use clear field labels, inline validation, password visibility, show loading state during requests, understandable error messages, and accessible touch targets.
- User role selection must never grant privileged roles. Doctor/pharmacist/shop-owner approval, where required, must come from trusted server-side/admin workflow.
- Keep the app shell and navigation predictable. Verify dark-theme handling if the current project already supports it; do not build a second incomplete theme just for appearance.

### B. Home

- Clear personalized greeting only if user data is available.
- Prominent medicine search, then a small set of meaningful entry points: Medicines, TibbNews, Farmacia, Reminders, and Consultation where supported.
- Feature real dataset-backed medicine/category items. Avoid fake banners, fake statistics, fake reviews, and random stock photos.
- Keep the first screen useful on small devices. Do not force the user through a large promotional carousel.

### C. Medicine catalogue, search, and detail

- Search by fields that genuinely exist in the dataset: e.g. generic name, brand name, category, indication, or traditional medicine type when supported.
- Provide appropriate filters and sorting only where data supports them.
- Medicine card should show the correct product image, name, available generic/brand relationship, strength/form when present, and price only when backed by a trusted source.
- Detail page should organize the actual available fields—do not invent dosage, contraindications, indications, interactions, or substitutions. Distinguish reference-data content from editorial explanations and show a health-information disclaimer.
- Handle empty search, no results, missing image, malformed dataset item, loading, and local/offline cases gracefully.
- Preserve the existing dataset files. Document the schema and image mapping before changing parsing logic.

### D. TibbNews community

- Editorial feed optimized for reading: author identity, role, verification status if genuinely verified, date, readable body, optional image, and clear like/comment/share actions.
- Make long articles comfortable to read, with stable spacing and line length.
- Provide comment/reply, edit/delete where authorized, reporting/moderation where implemented, loading state, empty state, and error feedback.
- The UI may show different capabilities by role, but backend authorization remains the source of truth.
- Never render arbitrary user-supplied HTML unsanitized.

### E. Farmacia / cart / checkout

- Product listing, product details, cart quantity controls, remove-item action, subtotal/fees/total breakdown, address/delivery form if supported, and order summary.
- Make stock, delivery fee, product price, order status, and checkout eligibility data-driven—not hard-coded claims.
- Prevent duplicate submissions and keep cart state coherent. UI validation is not a security boundary; revalidate prices, inventory, ownership, and order totals on a trusted backend.
- If a real payment provider is not configured and verified, do not collect money or simulate successful payments. Show a truthful unavailable/coming-soon state.

### F. Reminder and personal notes

- Show the schedule, time, medicine label, and completion state in a scan-friendly way.
- Create/edit/delete flows should include validation, confirmation where destructive, empty state, notification-permission feedback, and timezone handling.
- Personal reminders and notes must remain private to their owner. Do not expose them in a public feed or admin UI by default.

### G. Prescription page

- Build only a polished **Coming soon** page/entry point for future AI-assisted prescription detection. Do not claim OCR or medicine detection works until implemented and clinically tested.
- Do not ask users to upload real prescriptions until secure file handling, private storage policies, retention rules, and access control have been reviewed.

### H. Paid doctor/pharmacist consultation

- Create the UI entry point and explain the intended flow: provider profile/availability (only if verified), clear consultation fee, payment, trusted payment confirmation, then access to the consultation.
- Do not unlock consultation based on a frontend redirect or a client-set flag. Until payment/provider integration is real, mark the feature unavailable or coming soon and do not accept money.
- Clearly distinguish doctors from pharmacists and do not fabricate credentials, availability, ratings, or endorsements.

### I. Profile, settings, notifications, and admin

- Profile/settings should expose only relevant fields and show privacy-safe errors.
- Notifications should distinguish unread/read and have working navigation.
- Admin UI should be operational, minimal, and permission-based—not a way to browse all private user data. Add confirmation for destructive actions and audit sensitive operations.
- Never rely solely on hiding a UI button to protect a route or API.

## 5. Website: separate responsive experience

Build the website in `website/`, using the same brand tokens and real medicine dataset/assets. It should be a polished pharmacy/health-information site, not a screenshot-like static mockup.

### Expected page structure

1. Home: compact header, search-first hero, clear actions, real category links, a small product selection, editorial TibbNews previews, app download panel, and a restrained footer.
2. Medicines listing: search, category/filter controls supported by real fields, pagination or incremental loading, and proper empty/loading/error states.
3. Medicine detail: accurate fields, correct image, disclaimer, and appropriate link to the Android app if helpful.
4. TibbNews: editorial listing, article page, author information, accessible reading width, and authenticated post/comment actions where implemented.
5. Account: sign in/up/reset/session handling integrated with the existing Supabase Auth configuration and correct redirect URLs.
6. Farmacia/cart/checkout: only enable commerce operations verified by the real backend. No fake payment success.
7. Reminders/notes: signed-in private area only if the underlying cross-platform service exists and access rules are reviewed. Otherwise link to the app or explain availability honestly.
8. Consultation: pay-first flow UI only when a genuine provider and payment integration exist; otherwise show a clear non-transactional coming-soon state.
9. Prescription: coming-soon page only.
10. Android app download: link to a real, versioned signed APK release with version, release date, file size, SHA-256 checksum and install instructions once a release artifact exists.

### Responsive behavior

- Mobile: compact header with accessible menu, search immediately available, single-column content, bottom-sheet filters when appropriate, readable product cards, no horizontal overflow.
- Tablet: balanced two-column sections where helpful.
- Desktop: constrained content width, clear navigation, thoughtful whitespace, and responsive product grid.
- Implement keyboard navigation, visible focus state, appropriate semantic landmarks, image alt text, reduced-motion support, and sufficient contrast.

## 6. Medicine dataset and visual asset rules

1. Inspect the actual `assets/` directory and every medicine dataset file before writing an adapter.
2. Map field names and actual image paths; do not assume all records have images or that every item has a price.
3. Create a deterministic image resolver with a neutral fallback. Do not match photos to medicines by guessing from filenames alone without verifying mapping.
4. Keep the source files intact. If normalization is needed, use a separate adapter or generated index and document the mapping.
5. Avoid loading the entire raw dataset into first-screen web UI if it negatively affects performance. Search/filter should remain responsive.
6. Do not expose local notes, prescription records, reminders, auth tokens, or private user information in client logs or analytics.

## 7. Engineering workflow Antigravity must follow

### Phase 1 — audit, no edits
- Run `git status` and preserve every existing local change.
- Inspect project tree, Flutter routes/screens/widgets, `pubspec.yaml`, assets/datasets, current theme, services, API/auth flows, and tests.
- Identify the actual implementation status for every feature above with file paths. Do not infer a feature is implemented just because documentation mentions it.
- Run baseline checks where tools are available (`flutter pub get`, `flutter analyze`, `flutter test`). Record command output and pre-existing failures.
- Write `docs/UI_AUDIT.md`, including current screens, reusable components, visual inconsistencies, broken interactions, missing states, asset/data limitations, and proposed component migration plan.
- Do not edit UI code in this phase. Present the report and phased changes for approval.

### Phase 2 — design system foundation
- Implement shared theme/color/type/spacing tokens and reusable component primitives appropriate to the existing Flutter codebase.
- If the repo uses an existing state-management/routing pattern, follow it unless the audit finds a material defect. Do not replace the architecture merely for stylistic preference.
- Add screenshot/test notes and update design docs.

### Phase 3 — modernize Flutter by screen family
Suggested order: app shell/auth → home/search/categories → medicine list/detail → TibbNews → Farmacia/cart → reminder/notes → profile/settings/admin → honest Coming soon pages.
- Work incrementally, keep diffs focused, and test after each family.
- Preserve all current logic. Refactor business logic only where required and explain why.
- Do not create fake data to fill visual gaps.

### Phase 4 — implement website UI
- Inspect `website/` first. If it is an empty placeholder, scaffold the web project there; if it already contains real code, build upon it.
- Reuse equivalent tokens and content semantics, but adapt navigation and layout to the web rather than making a stretched phone screen.
- Add responsive checks for narrow phone, tablet and desktop widths.
- Use real Supabase integration only after current auth flow, RLS assumptions and redirect URLs have been checked. Do not move secrets into browser code.

### Phase 5 — verification and handoff
- Run `flutter analyze`, relevant Flutter tests, website lint/typecheck/build, and UI tests available in the repo. Report any tool that could not run and why.
- Test tap targets, overflow, keyboard navigation, loading/empty/error states, sign-in/sign-out, and role-dependent UI.
- Ensure every displayed product image matches its dataset item. Check for fake content and unsupported medical/commercial claims.
- Produce a concise changed-files summary, screenshots if the environment supports them, tests run with actual results, remaining gaps, and exact next commands.
- Do not deploy automatically. Present staging/production steps and obtain explicit approval before making live changes.

## 8. UI acceptance checklist

- [ ] App and website use one recognizable Asrar-e-Tibb design system.
- [ ] App screens were identified from source before redesign, and existing features/routes are preserved.
- [ ] The first screen has a clear information hierarchy and search is easy to reach.
- [ ] Correct dataset-backed medicine images are used, with a neutral fallback for missing images.
- [ ] No invented prices, stock, reviews, customer stats, doctor credentials, or medical advice.
- [ ] All controls either work or are accurately disabled/labelled as unavailable.
- [ ] Loading, empty, validation, offline/error, and confirmation states exist for important flows.
- [ ] Phone, tablet, and desktop layouts do not overflow or clip text.
- [ ] Text contrast, focus states, semantics, and tap targets are checked.
- [ ] Patient notes/reminders/private data are not accidentally exposed in UI.
- [ ] No secrets or privileged operations are moved into client-side code.
- [ ] Baseline and final checks are reported honestly.
- [ ] UI work does not silently alter production schema, policies, or records.

## 9. Reference screenshots

See `docs/reference_images/` and `docs/REFERENCE_ASSETS.md`. Use the pharmacy examples for clean product merchandising and search hierarchy; clinic examples for trustworthy health-related content; reminder/mobile examples for compact schedule views. Retain Asrar-e-Tibb's own identity and real data.

## 10. Copy/paste prompt for Antigravity

Paste this after opening the repository root in Antigravity:

> Read `ANTIGRAVITY_MASTER_PROMPT.md`, `docs/2. DESIGN.md`, and `docs/UI_MODERNIZATION_README.md` completely. I want a premium, modern, realistic production-quality UI for both the existing Flutter Android app and a separate responsive website in `website/`, using the screenshots in `docs/reference_images/` as inspiration and the Asrar-e-Tibb brand identity. First perform Phase 1 only: inspect the actual repo, Git status, routes/screens, theme, assets and medicine datasets, services, auth and current features; run baseline checks where available; create `docs/UI_AUDIT.md` with file-path evidence and a phased redesign plan. Do not modify code, dependencies, database, Supabase policies, authentication settings, or deploy anything during this first phase. Show me the audit and wait for my approval. Then, after I approve, implement in small tested milestones: design system, Flutter screen modernization, web UI, and QA. Preserve working features, use the correct medicine images from existing assets/dataset, never invent product/medical/doctor/payment claims, and keep unsupported features honestly marked Coming soon. Do not replace Flutter's root `web/` folder; the new website belongs in `website/`. Report exact files changed and commands/tests actually run after each milestone.
