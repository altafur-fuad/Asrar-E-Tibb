class DrugClass {
  final int id;
  final String drugClassName;
  final String slug;
  final int genericsCount;

  DrugClass({
    required this.id,
    required this.drugClassName,
    required this.slug,
    required this.genericsCount,
  });

  factory DrugClass.fromCsv(List<dynamic> row) {
    return DrugClass(
      id: int.tryParse(row[0].toString()) ?? 0,
      drugClassName: row[1]?.toString() ?? '',
      slug: row[2]?.toString() ?? '',
      genericsCount: int.tryParse(row[3].toString()) ?? 0,
    );
  }
}
