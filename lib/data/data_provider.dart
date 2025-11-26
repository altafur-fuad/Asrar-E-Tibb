import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/medicine_model.dart';
import '../models/generic_model.dart';
import '../models/manufacturer_model.dart';
import '../models/drug_class_model.dart';
import '../models/dosage_form_model.dart';
import '../models/indication_model.dart';

class DataProvider {
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
    final data = await _loadCsv('assets/data/generic.csv');
    final list = data.skip(1).map((row) => Generic.fromCsv(row)).toList();
    return _sortWithPreview(list, (g) => g.genericName);
  }

  // ✅ INDICATIONS
  static Future<List<Indication>> loadIndications() async {
    final data = await _loadCsv('assets/data/indication.csv');
    final list = data.skip(1).map((row) => Indication.fromCsv(row)).toList();
    return _sortWithPreview(list, (i) => i.indicationName);
  }

  // ✅ MANUFACTURERS
  static Future<List<Manufacturer>> loadManufacturers() async {
    final data = await _loadCsv('assets/data/manufacturer.csv');
    final list = data.skip(1).map((row) => Manufacturer.fromCsv(row)).toList();
    return _sortWithPreview(list, (m) => m.manufacturerName);
  }

  // ✅ DRUG CLASSES
  static Future<List<DrugClass>> loadDrugClasses() async {
    final data = await _loadCsv('assets/data/drug_class.csv');
    final list = data.skip(1).map((row) => DrugClass.fromCsv(row)).toList();
    return _sortWithPreview(list, (d) => d.drugClassName);
  }

  // ✅ DOSAGE FORMS
  static Future<List<DosageForm>> loadDosageForms() async {
    final data = await _loadCsv('assets/data/dosage_form.csv');
    final list = data.skip(1).map((row) => DosageForm.fromCsv(row)).toList();
    return _sortWithPreview(list, (f) => f.dosageFormName);
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
      // Load all CSVs
      final medData = await _loadCsv('assets/data/medicine.csv');
      final genericData = await _loadCsv('assets/data/generic.csv');
      final manufacturerData = await _loadCsv('assets/data/manufacturer.csv');

      List<Medicine> medicines = medData
          .skip(1)
          .map((row) => Medicine.fromCsv(row))
          .toList();
      List<Generic> generics = genericData
          .skip(1)
          .map((row) => Generic.fromCsv(row))
          .toList();
      List<Manufacturer> manufacturers = manufacturerData
          .skip(1)
          .map((row) => Manufacturer.fromCsv(row))
          .toList();

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

        // ধরে নিচ্ছি genericsCount == generic.id (one-to-one relation)
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
            // fallback: match by manufacturer name
            medicines = medicines
                .where(
                  (m) =>
                      m.manufacturer.toLowerCase() ==
                      manufacturer.toLowerCase(),
                )
                .toList();
          }
        } else {
          // fallback: direct manufacturer name
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
      print('⚠️ Error in loadMedicines(): $e');
      return [];
    }
  }
}
