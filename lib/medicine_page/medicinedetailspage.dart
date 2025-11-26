import 'package:asrarpages/medicine_page/alternative_brands_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import '../app_themes.dart';
import '../data/data_provider.dart';
import '../models/generic_model.dart';
import '../models/medicine_model.dart';

class MedicineDetailPage extends StatefulWidget {
  final Medicine medicine;
  const MedicineDetailPage({super.key, required this.medicine});

  @override
  State<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  bool isBookmarked = false;
  Generic? generic;
  bool _isLoading = true;
  final Map<String, bool> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    _loadGenericInfo();
    // Initially expand first few important sections
    _expandedSections.addAll({
      'indications': true,
      'dosage': true,
      'side_effects': true,
    });
  }

  Future<void> _loadGenericInfo() async {
    try {
      final allGenerics = await DataProvider.loadGenerics();
      final found = allGenerics.firstWhere(
        (g) =>
            g.genericName.toLowerCase() ==
            widget.medicine.generic.toLowerCase(),
        orElse: () => Generic(
          id: 0,
          genericName: widget.medicine.generic,
          slug: '',
          monographLink: '',
          drugClass: '',
          indication: '',
          indicationDescription: '',
          therapeuticClassDescription: '',
          pharmacologyDescription: '',
          dosageDescription: '',
          administrationDescription: '',
          interactionDescription: '',
          contraindicationsDescription: '',
          sideEffectsDescription: '',
          pregnancyAndLactationDescription: '',
          precautionsDescription: '',
          pediatricUsageDescription: '',
          overdoseEffectsDescription: '',
          durationOfTreatmentDescription: '',
          reconstitutionDescription: '',
          storageConditionsDescription: '',
          descriptionsCount: 0,
        ),
      );
      setState(() {
        generic = found;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading generic info: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      print('Could not launch $url: $e');
    }
  }

  // Safe HTML content widget with error handling
  // ✅ HTML rendering enabled content widget
  Widget _buildHtmlContent(String? htmlContent) {
    if (htmlContent == null || htmlContent.isEmpty) {
      return _buildNoContentAvailable();
    }

    return Html(
      data: htmlContent,
      style: {
        "body": Style(
          fontSize: FontSize(14),
          lineHeight: LineHeight(1.5),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white70
              : Colors.black87,
          fontFamily: 'Roboto',
          padding: HtmlPaddings.all(0),
          margin: Margins.zero,
        ),
        "ul": Style(
          margin: Margins.only(left: 15),
          padding: HtmlPaddings.only(left: 10),
        ),
        "li": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.symmetric(vertical: 2),
        ),
        "strong": Style(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        "h1": Style(fontSize: FontSize(20), fontWeight: FontWeight.bold),
        "h2": Style(fontSize: FontSize(18), fontWeight: FontWeight.bold),
        "h3": Style(fontSize: FontSize(16), fontWeight: FontWeight.bold),
        "br": Style(margin: Margins.zero),
      },
      onLinkTap: (url, _, __) async {
        if (url != null) await _launchURL(url);
      },
    );
  }

  Widget _buildNoContentAvailable() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'No information available',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required String key,
    required String? content,
  }) {
    final isExpanded = _expandedSections[key] ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
        border: isDark
            ? Border.all(color: Colors.grey[700]!)
            : Border.all(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        key: Key(key),
        initiallyExpanded: isExpanded,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildHtmlContent(content),
          ),
        ],
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedSections[key] = expanded;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.medicine;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (generic?.monographLink != null)
            IconButton(
              icon: Icon(
                Icons.open_in_new,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              onPressed: () => _launchURL(generic!.monographLink!),
              tooltip: 'Open Monograph',
            ),
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {
              setState(() {
                isBookmarked = !isBookmarked;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppThemes.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Medicine Details...',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medicine Icon/Image
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                        border: isDark
                            ? Border.all(color: Colors.grey[700]!)
                            : null,
                      ),
                      child: Icon(
                        Icons.medication,
                        size: 80,
                        color: AppThemes.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Medicine Name
                  Text(
                    m.brandName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Medicine Details Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                      border: isDark
                          ? Border.all(color: Colors.grey[700]!)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${m.generic}\n${m.strength}\n${m.manufacturer}",
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        if (m.unitPrice != null && m.unitPrice!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Unit Price: ৳${m.unitPrice}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Alternate Brands Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppThemes.primaryBlue.withOpacity(0.8)
                          : AppThemes.primaryBlue.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlternativeBrandsPage(
                            generic: widget.medicine.generic,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Alternate Brands",
                      style: TextStyle(
                        color: isDark ? Colors.white : AppThemes.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Expandable Sections
                  _buildExpandableSection(
                    key: 'indications',
                    title: 'Indications',
                    content: generic?.indicationDescription,
                  ),

                  _buildExpandableSection(
                    key: 'dosage',
                    title: 'Dosage & Administration',
                    content: generic?.dosageDescription,
                  ),

                  _buildExpandableSection(
                    key: 'side_effects',
                    title: 'Side Effects',
                    content: generic?.sideEffectsDescription,
                  ),

                  // Additional sections
                  _buildExpandableSection(
                    key: 'pharmacology',
                    title: 'Pharmacology',
                    content: generic?.pharmacologyDescription,
                  ),

                  _buildExpandableSection(
                    key: 'interactions',
                    title: 'Drug Interactions',
                    content: generic?.interactionDescription,
                  ),

                  _buildExpandableSection(
                    key: 'contraindications',
                    title: 'Contraindications',
                    content: generic?.contraindicationsDescription,
                  ),

                  _buildExpandableSection(
                    key: 'pregnancy',
                    title: 'Pregnancy & Lactation',
                    content: generic?.pregnancyAndLactationDescription,
                  ),

                  _buildExpandableSection(
                    key: 'precautions',
                    title: 'Precautions & Warnings',
                    content: generic?.precautionsDescription,
                  ),

                  _buildExpandableSection(
                    key: 'overdose',
                    title: 'Overdose Effects',
                    content: generic?.overdoseEffectsDescription,
                  ),

                  _buildExpandableSection(
                    key: 'storage',
                    title: 'Storage Conditions',
                    content: generic?.storageConditionsDescription,
                  ),

                  const SizedBox(height: 30),

                  // Footer Note
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]!.withOpacity(0.5)
                          : Colors.grey[100]!.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: isDark
                          ? Border.all(color: Colors.grey[700]!)
                          : Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      'For complete prescribing information, please consult the official monograph or healthcare provider.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
