class Medicine {
  final int id;
  final String brandName;
  final String type;
  final String slug;
  final String dosageForm;
  final String generic;
  final String strength;
  final String manufacturer;
  final String packageContainer;
  final String packageSize;
  final String? unitPrice; // dynamically extracted

  Medicine({
    required this.id,
    required this.brandName,
    required this.type,
    required this.slug,
    required this.dosageForm,
    required this.generic,
    required this.strength,
    required this.manufacturer,
    required this.packageContainer,
    required this.packageSize,
    this.unitPrice,
  });

  /// ✅ Extracts numeric price value from text containing "৳"
  static String? _extractPrice(String? text) {
    if (text == null || text.isEmpty) return null;
    final regex = RegExp(r'৳\s*([\d,]+(?:\.\d{1,2})?)');
    final match = regex.firstMatch(text);
    if (match != null) {
      return match.group(1); // returns number as string (e.g. "45.00")
    }
    return null;
  }

  factory Medicine.fromCsv(List<dynamic> row) {
    final id = int.tryParse(row[0].toString()) ?? 0;
    final brandName = row[1]?.toString() ?? '';
    final type = row[2]?.toString() ?? '';
    final slug = row[3]?.toString() ?? '';
    final dosageForm = row[4]?.toString() ?? '';
    final generic = row[5]?.toString() ?? '';
    final strength = row[6]?.toString() ?? '';
    final manufacturer = row[7]?.toString() ?? '';
    final packageContainer = row[8]?.toString() ?? '';
    final packageSize = row[9]?.toString() ?? '';

    // ✅ Try to extract price from both packageContainer and packageSize
    final price = _extractPrice(packageContainer) ?? _extractPrice(packageSize);

    return Medicine(
      id: id,
      brandName: brandName,
      type: type,
      slug: slug,
      dosageForm: dosageForm,
      generic: generic,
      strength: strength,
      manufacturer: manufacturer,
      packageContainer: packageContainer,
      packageSize: packageSize,
      unitPrice: price,
    );
  }
}
