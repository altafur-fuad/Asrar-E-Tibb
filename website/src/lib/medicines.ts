import fs from 'fs';
import path from 'path';
import rawMedicines from '../data/medicines.json';
import rawGenericsIndex from '../data/generics_index.json';
import rawFilters from '../data/filters.json';

export interface Medicine {
  id: string;
  name: string;
  slug: string;
  dosage_form: string;
  generic: string;
  generic_id: string;
  generic_slug: string;
  strength: string;
  manufacturer: string;
  price: string;
  package_container?: string;
  type?: string;
  drug_class?: string;
  indication?: string;
  image_url?: string | null;
}

export interface GenericBrand {
  id: string;
  name: string;
  slug: string;
  dosage_form: string;
  strength: string;
  manufacturer: string;
  price: string;
  package_container?: string;
}

export interface GenericSummary {
  id: string;
  name: string;
  slug: string;
  drug_class: string;
  indication: string;
  monograph_link?: string;
  brand_count: number;
  brands: GenericBrand[];
}

export interface GenericMonograph extends GenericSummary {
  indication_description?: string;
  therapeutic_class_description?: string;
  pharmacology_description?: string;
  dosage_description?: string;
  administration_description?: string;
  interaction_description?: string;
  contraindications_description?: string;
  side_effects_description?: string;
  pregnancy_and_lactation_description?: string;
  precautions_description?: string;
  pediatric_usage_description?: string;
  overdose_effects_description?: string;
  duration_of_treatment_description?: string;
  reconstitution_description?: string;
  storage_conditions_description?: string;
}

export interface FilterOptions {
  dosage_forms: string[];
  manufacturers: string[];
  drug_classes: string[];
  total_medicines_audited: number;
  total_generics_audited: number;
}

const medicinesList: Medicine[] = rawMedicines as Medicine[];
const genericsIndexList: GenericSummary[] = rawGenericsIndex as GenericSummary[];
const filterOptionsData: FilterOptions = rawFilters as FilterOptions;

// In-memory lookup maps for O(1) performance
const medicinesBySlug = new Map<string, Medicine>();
const medicinesById = new Map<string, Medicine>();
for (const med of medicinesList) {
  medicinesBySlug.set(med.slug.toLowerCase(), med);
  medicinesById.set(med.id.toString(), med);
}

const genericsBySlug = new Map<string, GenericSummary>();
const genericsById = new Map<string, GenericSummary>();
for (const gen of genericsIndexList) {
  genericsBySlug.set(gen.slug.toLowerCase(), gen);
  genericsById.set(gen.id.toString(), gen);
}

export function getAllMedicines(): Medicine[] {
  return medicinesList;
}

export function getMedicineBySlug(slug: string): Medicine | undefined {
  if (!slug) return undefined;
  const lower = slug.toLowerCase();
  return medicinesBySlug.get(lower) || medicinesById.get(slug);
}

export function getAllGenerics(): GenericSummary[] {
  return genericsIndexList;
}

export function getGenericBySlug(slug: string): GenericSummary | undefined {
  if (!slug) return undefined;
  const lower = slug.toLowerCase();
  return genericsBySlug.get(lower) || genericsById.get(slug);
}

export function getGenericById(id: string): GenericSummary | undefined {
  if (!id) return undefined;
  return genericsById.get(id.toString());
}

/**
 * Loads the full clinical monograph for a generic by its slug.
 * Executes server-side by reading the isolated monograph file.
 */
export function getMonographBySlug(slug: string): GenericMonograph | undefined {
  const genericSummary = getGenericBySlug(slug);
  if (!genericSummary) return undefined;

  try {
    const monoPath = path.join(process.cwd(), 'src', 'data', 'monographs', `${genericSummary.slug}.json`);
    if (fs.existsSync(monoPath)) {
      const content = fs.readFileSync(monoPath, 'utf-8');
      const monographData = JSON.parse(content);
      return {
        ...genericSummary,
        ...monographData
      };
    }
  } catch (err) {
    console.warn(`Failed to read monograph for slug ${slug}:`, err);
  }

  // Graceful fallback to summary if file read is unavailable
  return {
    ...genericSummary,
    indication_description: genericSummary.indication,
    therapeutic_class_description: genericSummary.drug_class
  };
}

/**
 * Returns alternative commercial brands with the same generic ID,
 * strictly excluding the current medicine.
 */
export function getAlternativeBrands(genericId: string, currentMedicineId: string): GenericBrand[] {
  if (!genericId) return [];
  const generic = getGenericById(genericId);
  if (!generic) return [];

  const monograph = getMonographBySlug(generic.slug);
  if (!monograph || !monograph.brands) return [];

  return monograph.brands.filter(
    (b) => b.id.toString() !== currentMedicineId.toString() && b.slug !== currentMedicineId
  );
}

export function getFilterOptions(): FilterOptions {
  return filterOptionsData;
}
