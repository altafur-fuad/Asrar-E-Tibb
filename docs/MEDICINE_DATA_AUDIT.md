# Asrar-e-Tibb — Medicine Dataset & Image Asset Audit

**Audit Date**: October 21, 2026  
**Auditor**: Senior Software Engineer & Platform Architect  
**Specification Reference**: `docs/ASRAR_E_TIBB_MEDICINE_WEB_SPEC.md`  

---

## 1. Overview of Audited Datasets

The repository contains six primary CSV datasets located in `assets/data/`:

| Dataset Filename | Absolute Path | File Size | Header Count | Row Count | Primary Key | Description |
|---|---|---|---|---|---|---|
| `medicine.csv` | `assets/data/medicine.csv` | 3,843,823 bytes (3.84 MB) | 10 | 21,714 | `brand id` | Brand-level commercial medicine records |
| `generic.csv` | `assets/data/generic.csv` | 8,519,440 bytes (8.52 MB) | 22 | 1,711 | `generic id` | Generic chemical monographs & clinical details |
| `dosage_form.csv` | `assets/data/dosage_form.csv` | 5,012 bytes (5 KB) | 4 | 113 | `dosage form id` | Pharmaceutical formulations catalog |
| `drug_class.csv` | `assets/data/drug_class.csv` | 31,617 bytes (31.6 KB) | 4 | 453 | `drug class id` | Pharmacological and therapeutic drug classes |
| `indication.csv` | `assets/data/indication.csv` | 124,512 bytes (124.5 KB) | 4 | 2,043 | `indication id` | Medical condition indications index |
| `manufacturer.csv`| `assets/data/manufacturer.csv` | 14,535 bytes (14.5 KB) | 5 | 240 | `manufacturer id` | Pharmaceutical manufacturers index |

---

## 2. Field-by-Field Schema & Missing Value Analysis

### 2.1 `medicine.csv` (21,714 rows)
- **Encoding**: UTF-8
- **Fields**:
  1. `brand id` (21,714 populated, 100%): Integer ID (e.g. `4077`, `3039`).
  2. `brand name` (21,714 populated, 100%): Commercial brand name (e.g. `A-Cold`, `Napa`, `Seclo`).
  3. `type` (21,714 populated, 100%): Medicine type, primarily `allopathic` or `herbal`.
  4. `slug` (21,714 populated, 100%): Unique URL-safe slug (e.g. `a-coldsyrup4-mg5-ml`).
  5. `dosage form` (21,714 populated, 100%): Pharmaceutical form (e.g. `Tablet`, `Syrup`, `Capsule`, `Injection`).
  6. `generic` (21,712 populated, 99.99%): Generic chemical name. *Missing in exactly 2 rows (`Affrox` and `Pregcare`).*
  7. `strength` (20,865 populated, 96.09%): Dosage strength (e.g. `500 mg`, `20 mg`, `(10 mg+30 mg)/5 ml`). Missing in 849 rows (chiefly herbal products or single-strength liquids).
  8. `manufacturer` (21,714 populated, 100%): Manufacturing laboratory (e.g. `ACME Laboratories Ltd.`, `Square Pharmaceuticals Ltd.`, `Beximco Pharmaceuticals Ltd.`).
  9. `package container` (21,672 populated, 99.81%): Official packaging and unit price string (e.g. `100 ml bottle: ৳ 40.12`, `Unit Price: ৳ 1.43, (100's pack: ৳ 143.00)`).
  10. `Package Size` (13,935 populated, 64.18%): Additional packaging packaging string or duplicate price format.

### 2.2 `generic.csv` (1,711 rows)
- **Encoding**: UTF-8
- **Fields**:
  1. `generic id` (1,711 populated, 100%): Unique integer identifier.
  2. `generic name` (1,711 populated, 100%): International Nonproprietary Name (INN).
  3. `slug` (1,711 populated, 100%): Unique slug (e.g. `adalimumab-31`, `paracetamol-1`).
  4. `monograph link` (1,199 populated, 70.08%): Prescribing information PDF/attachment URL (e.g. `https://medex.com.bd/attachments/...`).
  5. `drug class` (1,650 populated, 96.43%): Therapeutic classification.
  6. `indication` (1,627 populated, 95.09%): Short summary of clinical indications.
  7. `indication description` (1,711 populated, 100%): Full clinical indications with HTML formatting.
  8. `therapeutic class description` (1,658 populated, 96.90%): Mechanism & class details (HTML).
  9. `pharmacology description` (1,614 populated, 94.33%): Pharmacodynamics & pharmacokinetics (HTML).
  10. `dosage description` (1,695 populated, 99.06%): Detailed dosing regimens (adult/pediatric) (HTML).
  11. `administration description` (295 populated, 17.24%): Special administration instructions (HTML).
  12. `interaction description` (1,301 populated, 76.04%): Drug-drug & food interactions (HTML).
  13. `contraindications description` (1,570 populated, 91.76%): Clinical contraindications (HTML).
  14. `side effects description` (1,631 populated, 95.32%): Adverse reactions and symptoms (HTML).
  15. `pregnancy and lactation description` (1,545 populated, 90.30%): Pregnancy category and lactation safety (HTML).
  16. `precautions description` (1,525 populated, 89.13%): Special warnings and precautions (HTML).
  17. `pediatric usage description` (569 populated, 33.26%): Pediatric safety and efficacy guidelines (HTML).
  18. `overdose effects description` (775 populated, 45.30%): Symptoms and management of overdose (HTML).
  19. `duration of treatment description` (5 populated, 0.29%): Maximum course durations (HTML).
  20. `reconstitution description` (84 populated, 4.91%): Reconstitution instructions for injectables/suspensions (HTML).
  21. `storage conditions description` (1,546 populated, 90.36%): Temperature and moisture storage rules (HTML).
  22. `descriptions count` (1,711 populated, 100%): Integer count of populated sections.

---

## 3. Generic-to-Brand Foreign Key Audit

- **Matching Methodology**:
  - `medicine.csv` links to `generic.csv` via the generic name string.
  - Test results:
    - Exactly **21,712 of 21,714 medicines (99.99%)** match an existing generic entry in `generic.csv`.
    - Only **2 medicines** (`Affrox` and `Pregcare`) lack a generic name in `medicine.csv`.
    - **1,661 of 1,711 generic monographs (97.08%)** have one or more associated commercial brand medicines.
    - **50 generic monographs** have zero linked brands in Bangladesh (chiefly specialized institutional or hospital-only medications).

---

## 4. Image URL and Image Asset Audit

### 4.1 Dataset Inspection
- **`medicine.csv`**: Contains **zero** product image columns. Neither image URLs nor local file paths exist in `medicine.csv`.
- **`generic.csv`**: Contains `monograph link` (1,199 rows), which points to official prescribing information PDFs or attachments on external portals.
  - **Critical Rule Applied**: Per `docs/ASRAR_E_TIBB_MEDICINE_WEB_SPEC.md`, `monograph link` is strictly treated as an external clinical documentation reference and **never as an image URL**.
  - A regex scan across all 8.52 MB of `generic.csv` found exactly **1 embedded image** (`https://i.imgur.com/YwkaPsO.png`), located inside the pharmacology mechanism text of Generic ID #1239.

### 4.2 Local Image Assets (`assets/image/`)
- `assets/image/` contains logos (`logo.png`, `logo2.png`, `logo_dark1.png`, etc.), promo banners (`banner1.png` to `banner4.jpg`), app icons (`app_icon.png`), and developer personal portrait (`pic.png`).
- None of these are medicine product images. Per specification, `pic.png` must **never** be used for medicine display.

### 4.3 Image Strategy: Deterministic Clinical Badge (`MedicineImageBadge`)
- To provide a professional, premium visual experience without misleading or fabricated photos:
  - If a genuine verified image URL is present in the record, the UI renders the image with a graceful fallback on load error.
  - When no product photo exists (the default for the raw dataset), the UI renders **`MedicineImageBadge`**:
    - High-quality SVG icon tailored to the dosage form (Tablet, Capsule, Liquid/Syrup, Injectable, Inhalation, Drops, Topical).
    - Subtle background monogram derived from the brand name.
    - Soft, accessible clinical color coding following the Asrar-e-Tibb green and warm-ivory design system.

---

## 5. Rich HTML & Clinical Content Security

- The 13 clinical monograph fields in `generic.csv` contain rich HTML:
  - Typical wrappers: `<div class="ac-body">`, `<div class="min-str">`, `<div class="full-str">`.
  - Content tags: `<p>`, `<strong>`, `<ul>`, `<li>`, `<br>`.
- **Security Requirement**: Raw HTML from CSV must never be injected directly with `dangerouslySetInnerHTML` without rigorous sanitization.
- **Sanitization Strategy**:
  - Implement a dedicated sanitization utility allowlisting only safe formatting tags (`p`, `br`, `strong`, `b`, `em`, `i`, `ul`, `ol`, `li`, `span`).
  - Strip all `<script>`, `<iframe>`, `style` attributes, and `on*` event handlers.
  - Clean redundant outer `<div class="ac-body">` wrappers to blend seamlessly into the Next.js typography and cards.

---

## 6. Architecture & Optimization Plan

1. **Normalized Data Generation (`website/src/data/`)**:
   - Generate an indexed, rich dataset joining `medicine.csv` with `generic.csv`.
   - Structure:
     - `medicines_index.json`: Lightweight directory catalog for high-speed client filtering and search across brand name, generic name, dosage form, manufacturer, drug class, and strength.
     - `generics_index.json`: Generic catalog containing generic ID, name, slug, drug class, indication summary, and list of linked brand IDs.
     - `clinical_monographs.json` (or split chunked JSON / dynamic SSG routes): Full clinical monograph details loaded per generic.
2. **Routes to Implement / Modernize**:
   - `/`: Medicine discovery hero with live search and multi-field filters.
   - `/medicines`: Full medicine catalog with brand, generic, strength, dosage form, and manufacturer filters.
   - `/medicines/[id]`: Complete medicine detail page with linked generic monograph and Alternative Brands.
   - `/generics/[slug]`: Generic monograph page displaying all linked commercial brands.
3. **Alternative Brands Feature**:
   - For any medicine with `generic_id`, query other medicines with the same `generic_id` excluding the current medicine.
   - Group by strength and dosage form to facilitate like-for-like comparison.
