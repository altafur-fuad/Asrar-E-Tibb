class Generic {
  final int id;
  final String genericName;
  final String slug;
  final String? monographLink;
  final String? drugClass;
  final String? indication;
  final String? indicationDescription;
  final String? therapeuticClassDescription;
  final String? pharmacologyDescription;
  final String? dosageDescription;
  final String? administrationDescription;
  final String? interactionDescription;
  final String? contraindicationsDescription;
  final String? sideEffectsDescription;
  final String? pregnancyAndLactationDescription;
  final String? precautionsDescription;
  final String? pediatricUsageDescription;
  final String? overdoseEffectsDescription;
  final String? durationOfTreatmentDescription;
  final String? reconstitutionDescription;
  final String? storageConditionsDescription;
  final int? descriptionsCount;

  Generic({
    required this.id,
    required this.genericName,
    required this.slug,
    this.monographLink,
    this.drugClass,
    this.indication,
    this.indicationDescription,
    this.therapeuticClassDescription,
    this.pharmacologyDescription,
    this.dosageDescription,
    this.administrationDescription,
    this.interactionDescription,
    this.contraindicationsDescription,
    this.sideEffectsDescription,
    this.pregnancyAndLactationDescription,
    this.precautionsDescription,
    this.pediatricUsageDescription,
    this.overdoseEffectsDescription,
    this.durationOfTreatmentDescription,
    this.reconstitutionDescription,
    this.storageConditionsDescription,
    this.descriptionsCount,
  });

  // HTML content কে intact রাখবে, শুধু minor fixes করবে
  static String _cleanHtmlContent(String? htmlString) {
    if (htmlString == null || htmlString.isEmpty) return '';

    // শুধু problematic characters fix করবে, HTML structure intact রাখবে
    return htmlString
        .replaceAll('class="ac-body"', '')
        .replaceAll('class="min-str-block"', '')
        .replaceAll('class="min-str mb-5"', '')
        .replaceAll('class="full-str"', '')
        .replaceAll('class="min-str-toggle tx-green tx-bold"', '')
        .replaceAll('style="display: none;"', '')
        .replaceAll('style="cursor:pointer;font-style:italic;"', '')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .trim();
  }

  factory Generic.fromCsv(List<dynamic> row) {
    return Generic(
      id: int.tryParse(row[0].toString()) ?? 0,
      genericName: row[1]?.toString() ?? '',
      slug: row[2]?.toString() ?? '',
      monographLink: row[3]?.toString(),
      drugClass: row[4]?.toString(),
      indication: row[5]?.toString(),
      indicationDescription: _cleanHtmlContent(row[6]?.toString()),
      therapeuticClassDescription: _cleanHtmlContent(row[7]?.toString()),
      pharmacologyDescription: _cleanHtmlContent(row[8]?.toString()),
      dosageDescription: _cleanHtmlContent(row[9]?.toString()),
      administrationDescription: _cleanHtmlContent(row[10]?.toString()),
      interactionDescription: _cleanHtmlContent(row[11]?.toString()),
      contraindicationsDescription: _cleanHtmlContent(row[12]?.toString()),
      sideEffectsDescription: _cleanHtmlContent(row[13]?.toString()),
      pregnancyAndLactationDescription: _cleanHtmlContent(row[14]?.toString()),
      precautionsDescription: _cleanHtmlContent(row[15]?.toString()),
      pediatricUsageDescription: _cleanHtmlContent(row[16]?.toString()),
      overdoseEffectsDescription: _cleanHtmlContent(row[17]?.toString()),
      durationOfTreatmentDescription: _cleanHtmlContent(row[18]?.toString()),
      reconstitutionDescription: _cleanHtmlContent(row[19]?.toString()),
      storageConditionsDescription: _cleanHtmlContent(row[20]?.toString()),
      descriptionsCount: int.tryParse(row[21].toString()) ?? 0,
    );
  }
}
