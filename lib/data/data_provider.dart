import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/medicine_model.dart';
import '../models/generic_model.dart';
import '../models/manufacturer_model.dart';
import '../models/drug_class_model.dart';
import '../models/dosage_form_model.dart';
import '../models/indication_model.dart';

class DataProvider {
  // In-memory caches to avoid reading assets on every query
  static List<Medicine>? _cachedMedicines;
  static List<Generic>? _cachedGenerics;
  static List<Manufacturer>? _cachedManufacturers;
  static List<Indication>? _cachedIndications;
  static List<DrugClass>? _cachedDrugClasses;
  static List<DosageForm>? _cachedDosageForms;

  // CSV Loader
  static Future<List<List<dynamic>>> _loadCsv(String path) async {
    final rawData = await rootBundle.loadString(path);
    return const CsvToListConverter().convert(rawData);
  }

  // Sorting helper
  static List<T> _sortWithPreview<T>(
    List<T> items,
    String Function(T) getName,
  ) {
    if (items.length <= 20) return items;
    final first20 = items.take(20).toList();
    final rest = items.skip(20).toList();
    rest.sort(
      (a, b) => getName(a).toLowerCase().compareTo(getName(b).toLowerCase()),
    );
    return [...first20, ...rest];
  }

  // ✅ GENERICS
  static Future<List<Generic>> loadGenerics() async {
    if (_cachedGenerics != null) return _cachedGenerics!;
    final data = await _loadCsv('assets/data/generic.csv');
    final list = data.skip(1).map((row) => Generic.fromCsv(row)).toList();
    _cachedGenerics = _sortWithPreview(list, (g) => g.genericName);
    return _cachedGenerics!;
  }

  // ✅ INDICATIONS
  static Future<List<Indication>> loadIndications() async {
    if (_cachedIndications != null) return _cachedIndications!;
    final data = await _loadCsv('assets/data/indication.csv');
    final list = data.skip(1).map((row) => Indication.fromCsv(row)).toList();
    _cachedIndications = _sortWithPreview(list, (i) => i.indicationName);
    return _cachedIndications!;
  }

  // ✅ MANUFACTURERS
  static Future<List<Manufacturer>> loadManufacturers() async {
    if (_cachedManufacturers != null) return _cachedManufacturers!;
    final data = await _loadCsv('assets/data/manufacturer.csv');
    final list = data.skip(1).map((row) => Manufacturer.fromCsv(row)).toList();
    _cachedManufacturers = _sortWithPreview(list, (m) => m.manufacturerName);
    return _cachedManufacturers!;
  }

  // ✅ DRUG CLASSES
  static Future<List<DrugClass>> loadDrugClasses() async {
    if (_cachedDrugClasses != null) return _cachedDrugClasses!;
    final data = await _loadCsv('assets/data/drug_class.csv');
    final list = data.skip(1).map((row) => DrugClass.fromCsv(row)).toList();
    _cachedDrugClasses = _sortWithPreview(list, (d) => d.drugClassName);
    return _cachedDrugClasses!;
  }

  // ✅ DOSAGE FORMS
  static Future<List<DosageForm>> loadDosageForms() async {
    if (_cachedDosageForms != null) return _cachedDosageForms!;
    final data = await _loadCsv('assets/data/dosage_form.csv');
    final list = data.skip(1).map((row) => DosageForm.fromCsv(row)).toList();
    _cachedDosageForms = _sortWithPreview(list, (f) => f.dosageFormName);
    return _cachedDosageForms!;
  }

  // ✅ MEDICINES (Linked filters for Generic, Manufacturer, Indication, Drug Class)
  static Future<List<Medicine>> loadMedicines({
    String? generic,
    String? manufacturer,
    String? brand,
    String? indication,
    String? drugClass,
    String? dosageForm,
  }) async {
    try {
      if (_cachedMedicines == null) {
        final medData = await _loadCsv('assets/data/medicine.csv');
        _cachedMedicines = medData
            .skip(1)
            .map((row) => Medicine.fromCsv(row))
            .toList();
      }

      List<Medicine> medicines = List.from(_cachedMedicines!);
      final generics = await loadGenerics();
      final manufacturers = await loadManufacturers();

      // ✅ Generic filter
      if (generic != null && generic.isNotEmpty) {
        medicines = medicines
            .where((m) => m.generic.toLowerCase() == generic.toLowerCase())
            .toList();
      }

      // ✅ Manufacturer filter (via genericCount relation)
      if (manufacturer != null && manufacturer.isNotEmpty) {
        final selectedManufacturer = manufacturers.firstWhere(
          (m) => m.manufacturerName.toLowerCase() == manufacturer.toLowerCase(),
          orElse: () => Manufacturer(
            id: 0,
            manufacturerName: '',
            slug: '',
            genericsCount: 0,
            brandNamesCount: 0,
          ),
        );

        if (selectedManufacturer.genericsCount > 0) {
          final relatedGenerics = generics
              .where((g) => g.id == selectedManufacturer.genericsCount)
              .map((g) => g.genericName.toLowerCase())
              .toList();

          if (relatedGenerics.isNotEmpty) {
            medicines = medicines
                .where(
                  (m) =>
                      relatedGenerics.contains(m.generic.toLowerCase()) ||
                      m.manufacturer.toLowerCase() ==
                          manufacturer.toLowerCase(),
                )
                .toList();
          } else {
            medicines = medicines
                .where(
                  (m) =>
                      m.manufacturer.toLowerCase() ==
                      manufacturer.toLowerCase(),
                )
                .toList();
          }
        } else {
          medicines = medicines
              .where(
                (m) =>
                    m.manufacturer.toLowerCase() == manufacturer.toLowerCase(),
              )
              .toList();
        }
      }

      // ✅ Brand filter
      if (brand != null && brand.isNotEmpty) {
        medicines = medicines
            .where((m) => m.brandName.toLowerCase() == brand.toLowerCase())
            .toList();
      }

      // ✅ Dosage Form filter
      if (dosageForm != null && dosageForm.isNotEmpty) {
        medicines = medicines
            .where(
              (m) => m.dosageForm.toLowerCase() == dosageForm.toLowerCase(),
            )
            .toList();
      }

      // ✅ Indication filter (linked via generic.indication)
      if (indication != null && indication.isNotEmpty) {
        final relatedGenerics = generics
            .where(
              (g) =>
                  g.indication != null &&
                  g.indication!.toLowerCase().contains(
                    indication.toLowerCase(),
                  ),
            )
            .map((g) => g.genericName.toLowerCase())
            .toSet();

        medicines = medicines
            .where((m) => relatedGenerics.contains(m.generic.toLowerCase()))
            .toList();
      }

      // ✅ Drug Class filter (linked via generic.drugClass)
      if (drugClass != null && drugClass.isNotEmpty) {
        final relatedGenerics = generics
            .where(
              (g) =>
                  g.drugClass != null &&
                  g.drugClass!.toLowerCase().contains(drugClass.toLowerCase()),
            )
            .map((g) => g.genericName.toLowerCase())
            .toSet();

        medicines = medicines
            .where((m) => relatedGenerics.contains(m.generic.toLowerCase()))
            .toList();
      }

      // ✅ Sort alphabetically
      medicines.sort(
        (a, b) =>
            a.brandName.toLowerCase().compareTo(b.brandName.toLowerCase()),
      );

      return medicines;
    } catch (e) {
      debugPrint('⚠️ Error in loadMedicines(): $e');
      return [];
    }
  }
}
