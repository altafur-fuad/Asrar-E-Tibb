# Asrar-e-Tibb — Medicine-Centric Website UI & Data Specification

## Priority

This is the immediate priority for the Asrar-e-Tibb web platform. Focus on making the website a professional, searchable medicine information directory. Do not spend this task on the unfinished cloud staging User A/B tests, production database migrations, paid consultation, checkout implementation, or unrelated Flutter screen redesign.

Repository: `https://github.com/altafur-fuad/Asrar-E-Tibb`
Feature branch: `feat/web-backend-apk-deployment`
Website root: `website/`
Existing Flutter application: repository root; preserve it.
Flutter Web folder: root `web/`; do not replace or repurpose it.

## 1. Required workflow: inspect real data before coding

Before changing the website, inspect the actual repository and all medicine-related assets and dataset files, including but not limited to:

- `medicine.csv`
- `generic.csv`
- Any additional CSV, JSON, image metadata, or medicine dataset files under `assets/`, `website/src/data/`, or other existing data directories.
- Existing `website/src/data/medicines.json` and the script or process that generated it.
- Existing medicine models, parsing scripts, filters, routes, detail components, dosage-form badges, tests, and image-loading components.

Create `docs/MEDICINE_DATA_AUDIT.md` before implementation. Record:

1. Each source file and its actual path.
2. Actual row count, headers/field names, encoding, and any missing-value patterns.
3. Stable IDs, generic IDs, slugs, generic name fields, brand/medicine name fields, dose/strength, dosage form, manufacturer, indication, drug class, monograph URLs, and image URL/path fields that truly exist.
4. Relationships between generic records and brand medicine records, including observed duplicate IDs, unmatched foreign keys, missing generics, and ambiguous rows.
5. Whether image links are direct image URLs, local asset paths, product images, or document/monograph URLs. Never treat a monograph or prescribing-information URL as an image URL.
6. All medicine-description fields actually present, distinguishing absent fields from empty values.
7. Which source is authoritative for each field if different datasets disagree.

Do not invent or infer nonexistent fields. Do not hardcode an assumed row count. Report discrepancies rather than silently discarding data. Keep original datasets unchanged.

## 2. Main website goal

The most important purpose of the website is to let users search, browse, and open complete medicine information from the project's existing dataset.

The user experience must be data-first, polished, fast, mobile-friendly, and easy to understand. Use the existing Asrar-e-Tibb brand identity:

- Forest Green: `#064E3B`
- Evergreen: `#0B6B4B`
- Fresh Green: `#23845B`
- Warm Ivory: `#F7F7F2`
- White: `#FFFFFF`
- Deep Ink: `#12231D`
- Soft Sage: `#E6F0EA`
- Restrained Amber: `#E6B84B`

Avoid a generic template appearance. Use careful typography, editorial spacing, consistent design tokens, a strong search experience, clear data hierarchy, refined medicine cards, accessible contrast, and responsive layouts. Keep the UI professional and realistic; do not use decorative random medicine photographs.

## 3. Homepage / Medicine Discovery

The homepage must prominently feature a functional medicine search and discovery panel, not just a generic hero banner.

### Searchable fields and filters

Provide search/filter options for whichever of the following fields exist in the audited datasets:

- Generic name
- Brand/medicine name
- Dose or strength
- Dosage form
- Indication / use
- Drug class / therapeutic class
- Manufacturer / company

Search should be case-insensitive, trim whitespace, tolerate reasonable punctuation differences, and provide a clear empty state. Show a useful label for the field users are searching or filtering. Do not create filters based on fields that the data audit proves do not exist.

Include a clear search box with autocomplete/suggestions if practical, a filter panel/drawer for mobile, removable active-filter chips, a clear-all action, result count, sort options that use real fields, and pagination or virtualized result rendering appropriate to actual dataset size.

A user must be able to search, for example, `Adalimumab`, select a generic, browse all of that generic's medicines/brands, and open a particular medicine record.

## 4. Generic detail pages

Create or improve a route such as `/generics/[slug]` (adapt to the current router without duplicating route structures).

When the user opens a generic name:

- Display the generic name, generic ID, slug, drug class, indication, therapeutic class description, and monograph/source link if present.
- Display every medicine/brand record associated with the generic using the verified generic ID/foreign-key relationship, not loose string matching if a stable ID exists.
- Offer filters for dose/strength, dosage form, and manufacturer only when those fields exist.
- Show a count of matching medicine/brand records.
- Selecting a medicine navigates to its medicine detail page.
- Show a clear empty state if no brand medicine rows link to that generic.

Avoid mixing generic-level monograph information with fields belonging to an individual brand medicine. Make their source/level clear in the UI.

## 5. Medicine/brand detail pages: show all actual data

Create or improve a medicine detail route such as `/medicines/[id]` (preserve current working URLs where possible).

When a user opens a medicine, display all non-empty fields available for that record and its linked generic record, organized into readable sections. Do not arbitrarily truncate or omit dataset fields because the section is long.

The provided example schema includes the following generic/monograph-level fields, if confirmed by the source data:

- `generic_id`
- `generic_name`
- `slug`
- `monograph_link`
- `drug_class`
- `indication`
- `indication_description`
- `therapeutic_class_description`
- `pharmacology_description`
- `dosage_description`
- `administration_description`
- `interaction_description`
- `contraindications_description`
- `side_effects_description`
- `pregnancy_and_lactation_description`
- `precautions_description`
- `pediatric_usage_description`
- `overdose_effects_description`
- `duration_of_treatment_description`
- `reconstitution_description`
- `storage_conditions_description`
- `descriptions_count`

Map these example names to the actual source headers; do not rename or lose fields during transformation. The exact available fields must come from the audit.

The individual medicine/brand record should show its own actual available details, for example:

- Brand/medicine name
- Linked generic name
- Strength/dose
- Dosage form
- Manufacturer/company
- Actual listed price or pack info if present and reliable
- Actual product image if an image field/path exists
- Any medicine-specific fields found in the audit

Then render the linked generic's full monograph fields, including dosage, administration, pharmacology, interactions, contraindications, side effects, precautions, pregnancy/lactation, pediatric use, overdose, duration, reconstitution, and storage conditions, whenever populated. Do not invent absent values. Hide a section only if no meaningful data exists for it; otherwise preserve full content.

### Long details UX

Use an accessible table of contents, section navigation, or anchor links for the long monograph. On desktop, a sticky section navigator is acceptable if it does not obscure content. On mobile, use readable section headings and collapsible sections only if the user can readily find and read everything. The page should not make the entire monograph difficult to reach.

Provide copy-link/share actions where practical. Add a clear source/monograph external link when the source URL is valid. External links must open safely (`rel="noopener noreferrer"` when using a new tab).

Add a concise educational-use disclaimer: medicine information is for reference and does not replace assessment by a licensed clinician. Do not alter prescribed dosage information or generate personalized dosing recommendations from the dataset.

## 6. Image URL and image asset handling

The owner says image links exist in the available assets/data. Verify that against the real files.

- Identify exact columns or lookup files containing image URLs or asset paths.
- Preserve the image URL in the normalized data where it is genuinely an image.
- Render the corresponding image on the appropriate medicine/brand page and card.
- Use a safe remote image configuration or a controlled image component compatible with the actual Next.js version.
- Validate URLs and handle failed, unavailable, malformed, or blocked images with a graceful fallback.
- If an actual product image is unavailable, use the existing `MedicineImageBadge` or its website equivalent with a correct dosage-form icon and brand/generic monogram.
- Never use the developer portrait or an unrelated image as a medicine image.
- Never render the `monograph_link` (for example, a prescribing-information page/PDF URL) as the product image.
- Do not fabricate image URLs or scrape arbitrary external pages at runtime as a hidden workaround.
- Do not unnecessarily download huge external images into the repo. Prefer reliable existing asset references and appropriate image sizes.

## 7. Alternative brands / medicines

Every medicine detail page should have a visible, meaningful `Alternative Brands` or `Other brands with the same generic` option.

On click, show the other medicine/brand records linked to the same generic ID, excluding the currently selected medicine. Show available name, strength/dose, dosage form, manufacturer, real image or fallback badge, and a link to each medicine detail page.

If the dataset includes enough information to determine matching strength and dosage form, provide filters or grouping to help users compare like-for-like products. Never imply that different strength or dosage forms are automatically interchangeable.

Do not label drugs from different generic ingredients or different therapeutic classes as direct brand alternatives. If a separate clinically related alternative dataset exists, present it separately as `Related therapeutic options`, explain its source, and avoid claiming clinical equivalence.

Include a careful warning that changing brands or formulations should be confirmed with a doctor or pharmacist. The website is a reference catalogue, not an automatic substitution or prescription tool.

## 8. Data normalization and relationships

Build a robust, reproducible transformation pipeline from the actual source datasets to website data. Keep the original files untouched.

- Prefer stable generic IDs and medicine IDs for relationships and routes.
- Create unique and stable slugs, handling duplicates deliberately.
- Preserve source values and HTML-rich descriptions accurately.
- Keep null/empty values distinct during parsing, then render empty fields gracefully.
- Report row counts before and after conversion and explain any intentionally excluded malformed rows.
- Preserve Unicode text and Bangladesh-specific characters if present.
- Do not fabricate medicine records, images, companies, stock or prices.
- Write unit tests for generic-to-medicine relationships, alternatives, slug uniqueness, search across available fields, missing values, and image URL classification.

## 9. Rich HTML and clinical content safety

Several description values may contain HTML tags, `<strong>`, lists, line breaks, and nested elements.

Render the source content in a readable, semantic format while preventing cross-site scripting:

- Sanitize HTML using a maintained sanitizer and an explicit safe allowlist.
- Retain safe elements such as paragraphs, lists, headings, strong/emphasis, and line breaks where appropriate.
- Remove scripts, event-handler attributes, unsafe embedded content, and `javascript:` URLs.
- Do not blindly inject arbitrary raw dataset HTML into the page.
- Check how `&lt;`, HTML entities, lists, and line breaks render.
- Use accessible headings and keep clinical content legible.

## 10. Performance, accessibility and responsive behavior

- Search/filter updates should feel immediate for the real dataset size.
- Avoid sending the entire giant source dataset to every client component if an optimized generated JSON/index is better.
- Use static generation, server rendering, or indexed data as appropriate to the current Next.js architecture.
- Preserve existing working routes and direct-link behavior.
- Check desktop, tablet, and mobile layouts.
- Add loading, empty, and error states.
- Ensure keyboard access, visible focus, labels, semantic HTML, and usable touch targets.
- Run website tests and a production build.

## 11. Acceptance tests

Before marking this work complete, verify all of these with the actual data:

1. Searching by a generic returns the correct generic result.
2. Opening a generic displays every linked medicine/brand record.
3. Filtering by brand name, dose/strength, indication, drug class, and manufacturer works whenever those fields exist.
4. Opening a medicine shows every populated field available in the source and linked generic monograph.
5. Image URLs are correctly classified; monograph links are never mistaken for images.
6. Failed or missing images gracefully fall back to the dosage-form badge.
7. Alternative brands shows other records with the same generic ID and excludes the current record.
8. The brand detail route remains stable and directly shareable.
9. Rich HTML descriptions render safely without script execution.
10. Search/filter and detail pages work on phone and desktop.
11. The original datasets and Flutter application remain unchanged unless a separate, explicitly approved change is necessary.
12. Existing website tests continue to pass and new data logic has tests.

## 12. Required deliverables

Create or update:

- `docs/MEDICINE_DATA_AUDIT.md`
- `docs/MEDICINE_CATALOG_IMPLEMENTATION.md`
- Website homepage medicine discovery UI.
- Search/filter components.
- Generic detail route.
- Complete medicine detail/monograph rendering.
- Alternative-brand listing.
- Correct image URL mapping and robust fallback handling.
- Reproducible dataset transformation script, if needed.
- Tests for the requirements above.
- `docs/DEPLOYMENT_STATUS.md` with real status.

Report the exact files changed, verified source columns and row counts, available image-link fields, test results, and any missing/ambiguous data.

Do not claim all medicine data is displayed until you have compared actual source fields with the rendered detail page. Do not deploy or modify production Supabase as part of this task. First audit the data and current website, then implement and verify the medicine-focused web experience. The existing Flutter app should be left intact for now; mobile app changes will be handled after the website medicine catalogue is correct.
