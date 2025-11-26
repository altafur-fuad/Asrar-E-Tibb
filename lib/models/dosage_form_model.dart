class DosageForm {
  final int id;
  final String dosageFormName;
  final String slug;
  final int brandNamesCount;

  DosageForm({
    required this.id,
    required this.dosageFormName,
    required this.slug,
    required this.brandNamesCount,
  });

  factory DosageForm.fromCsv(List<dynamic> row) {
    return DosageForm(
      id: int.tryParse(row[0].toString()) ?? 0,
      dosageFormName: row[1]?.toString() ?? '',
      slug: row[2]?.toString() ?? '',
      brandNamesCount: int.tryParse(row[3].toString()) ?? 0,
    );
  }
}
