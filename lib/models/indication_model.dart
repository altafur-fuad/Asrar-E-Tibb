class Indication {
  final int id;
  final String indicationName;
  final String slug;
  final int genericsCount;

  Indication({
    required this.id,
    required this.indicationName,
    required this.slug,
    required this.genericsCount,
  });

  factory Indication.fromCsv(List<dynamic> row) {
    return Indication(
      id: int.tryParse(row[0].toString()) ?? 0,
      indicationName: row[1]?.toString() ?? '',
      slug: row[2]?.toString() ?? '',
      genericsCount: int.tryParse(row[3].toString()) ?? 0,
    );
  }
}
