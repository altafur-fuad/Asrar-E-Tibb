class Manufacturer {
  final int id;
  final String manufacturerName;
  final String slug;
  final int genericsCount;
  final int brandNamesCount;

  Manufacturer({
    required this.id,
    required this.manufacturerName,
    required this.slug,
    required this.genericsCount,
    required this.brandNamesCount,
  });

  factory Manufacturer.fromCsv(List<dynamic> row) {
    return Manufacturer(
      id: int.tryParse(row[0].toString()) ?? 0,
      manufacturerName: row[1]?.toString() ?? '',
      slug: row[2]?.toString() ?? '',
      genericsCount: int.tryParse(row[3].toString()) ?? 0,
      brandNamesCount: int.tryParse(row[4].toString()) ?? 0,
    );
  }
}
