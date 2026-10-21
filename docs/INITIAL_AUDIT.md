# Initial Repository Review — What Is Known vs Unknown

**Review basis:** publicly visible GitHub repository page, its README, its `pubspec.yaml` page metadata and `SETUP_COMPLETE_GUIDE.md` text. This was not a local build or complete source/security audit. A local `git clone` attempt in the analysis environment could not resolve `github.com`, so source files, actual database policies and runtime tests could not be inspected here.

## Observed from the public repo/README
- Repository: `altafur-fuad/Asrar-E-Tibb`, public, default branch `main` at time checked.
- Project README describes “Asrar-e-Tibb” as a Flutter/Dart pharmacy directory and health community, with Supabase Postgres/Auth/Storage/Realtime.
- Public README describes Farmacia medicine directory, alternatives, cart/checkout, dataset import from CSV; TibbNews text/image posts, edit/delete, likes, comments, profiles, notifications; admin user/content moderation; and personal reminders/notepad.
- README lists typical Flutter project areas: `lib/admin`, `lib/data`, `lib/farmacia`, `lib/identity_login_signup`, `lib/medicine_page`, `lib/models`, `lib/pages`, `lib/remainder_notepad`, `lib/services`, `lib/tibbnews`, plus `assets/`, `test/`, Android/platform directories and `web/`.
- The repository page shows `README.md`, `SETUP_COMPLETE_GUIDE.md`, `pubspec.yaml` and a `docs/screenshots/` directory. The README references eight screenshot filenames (`01_intro.png` through `08_admin_panel.png`); confirm each referenced file actually exists and renders.
- The README shows a MIT license badge while the license section says to add a preferred license and the root listing visible during review did not show a `LICENSE` file. Confirm the actual legal license and add the authoritative `LICENSE` before relying on a badge/distributing code.
- The README’s setup instructions say to create an admin user via SQL. Treat any such SQL as high-risk until the exact statement is reviewed; bootstrap admin access through an owner-controlled procedure, not an ordinary client signup path.
- README lists future roadmap items including payment gateway integration, OCR prescription detection, doctor/pharmacist consultation, seller inventory, ratings/reviews, push notifications and Bangla-first expansion.

## Important discrepancy to validate
The public README's folder name is shown as `lib/services/` but setup guide text refers to `lib/sevices/supabase_services.dart` (spelling differs). Antigravity must inspect actual file paths instead of assuming either name is correct.

## Not verified yet
- Whether any data/table schemas currently deployed match repository docs.
- Whether RLS is enabled on all exposed tables and whether grants/policies/storage/realtime are safe.
- Whether admin checks can be forged or private data leaks across users.
- Whether all described screens/features are implemented, compile or function correctly.
- Exact medicine dataset filenames, column structure, image mapping, rights/licensing and clinical data quality.
- Whether any secret exists in source or Git history.
- Whether payment is configured (README suggests payment gateway as future work).
- Whether a public signed APK release currently exists.
- Whether existing website output is only Flutter platform scaffolding or a developed web app.

## Findings / risk hypotheses to investigate (not confirmed vulnerabilities)
1. **RLS and privilege separation:** README names a fairly rich client-direct Supabase app; every exposed table, view, function, Storage bucket and Realtime subscription needs independent authorization tests.
2. **Role escalation:** README describes role-based login/signup and admin tools; verify that client signup/profile update cannot grant admin/professional verification.
3. **Private data isolation:** reminders and notes must be strictly user-owned. Admin moderation should not automatically reveal these private records.
4. **Payment integrity:** checkout exists in README, but gateway is listed as future work. Confirm whether checkout is catalog/cart demo or actual ordering; never assume a client success message represents payment.
5. **Dataset integrity:** the medicine dataset is a separate information source from inventory/prices/stock; verify image mappings and all field meanings.
6. **Web feasibility:** the repo has a `web/` directory typical of Flutter platform support. A separate Next.js web storefront should live in `website/` so files do not collide.
7. **Deployment secrets:** inspect Git history, environment configs, Android signing files and build output for secrets, without printing them in reports.

## Immediate next audit steps
1. Clone/open repository locally and inspect Git status.
2. Build/test baseline.
3. Map features to real source files and data.
4. Export actual DB schema/RLS/Storage policies safely.
5. Review admin-bootstrap SQL and reconcile the license badge/file discrepancy.
6. Run cross-user security tests with two synthetic accounts.
7. Deliver a file-by-file audit report and plan before implementation.
