import 'package:flutter/material.dart';
import '../data/data_provider.dart';
import '../models/generic_model.dart';
import '../models/indication_model.dart';
import '../models/manufacturer_model.dart';
import '../models/drug_class_model.dart';
import '../models/dosage_form_model.dart';
import '../app_themes.dart';
import 'medicine_list_page.dart';

class ListPage extends StatefulWidget {
  final String category; // <-- from HomePage

  const ListPage({super.key, required this.category});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Generic> generics = [];
  List<Indication> indications = [];
  List<Manufacturer> manufacturers = [];
  List<DrugClass> drugClasses = [];
  List<DosageForm> dosageForms = [];
  bool _loading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 🔹 Load data dynamically based on category
  Future<void> _loadData() async {
    switch (widget.category) {
      case 'Generic':
        generics = await DataProvider.loadGenerics();
        break;
      case 'Indication':
        indications = await DataProvider.loadIndications();
        break;
      case 'Manufacturer':
        manufacturers = await DataProvider.loadManufacturers();
        break;
      case 'Drug Class':
        drugClasses = await DataProvider.loadDrugClasses();
        break;
      case 'Dosage Form':
        dosageForms = await DataProvider.loadDosageForms();
        break;
      case 'Brand Name':
        generics = await DataProvider.loadGenerics();
        break;
    }
    setState(() => _loading = false);
  }

  /// 🔹 Navigate to medicine list with filters
  void _navigateToMedicineList({
    String? generic,
    String? indication,
    String? manufacturer,
    String? drugClass,
    String? dosageForm,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicineListPage(
          filterGeneric: generic,
          filterIndication: indication,
          filterManufacturer: manufacturer,
          filterDrugClass: drugClass,
          filterDosageForm: dosageForm,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppThemes.primaryBlue;
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.category),
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 🔹 Filter items by search query
    bool matchesQuery(String text) =>
        text.toLowerCase().contains(_searchQuery.toLowerCase());

    List<Widget> items = [];

    if (widget.category == 'Generic') {
      items = generics
          .where((g) => matchesQuery(g.genericName))
          .map(
            (g) => _buildTile(
              title: g.genericName,
              onTap: () => _navigateToMedicineList(generic: g.genericName),
            ),
          )
          .toList();
    } else if (widget.category == 'Indication') {
      items = indications
          .where((i) => matchesQuery(i.indicationName))
          .map(
            (i) => _buildTile(
              title: i.indicationName,
              onTap: () =>
                  _navigateToMedicineList(indication: i.indicationName),
            ),
          )
          .toList();
    } else if (widget.category == 'Manufacturer') {
      items = manufacturers
          .where((m) => matchesQuery(m.manufacturerName))
          .map(
            (m) => _buildTile(
              title: m.manufacturerName,
              onTap: () =>
                  _navigateToMedicineList(manufacturer: m.manufacturerName),
            ),
          )
          .toList();
    } else if (widget.category == 'Drug Class') {
      items = drugClasses
          .where((d) => matchesQuery(d.drugClassName))
          .map(
            (d) => _buildTile(
              title: d.drugClassName,
              onTap: () => _navigateToMedicineList(drugClass: d.drugClassName),
            ),
          )
          .toList();
    } else if (widget.category == 'Dosage Form') {
      items = dosageForms
          .where((f) => matchesQuery(f.dosageFormName))
          .map(
            (f) => _buildTile(
              title: f.dosageFormName,
              onTap: () =>
                  _navigateToMedicineList(dosageForm: f.dosageFormName),
            ),
          )
          .toList();
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🔹 Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: "Search ${widget.category}...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🔹 List
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      "No matching results.",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => Divider(
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                      thickness: 0.8,
                    ),
                    itemBuilder: (context, index) => items[index],
                  ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Custom styled ListTile
  Widget _buildTile({required String title, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: isDark ? Colors.white60 : Colors.grey.shade600,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      tileColor: theme.cardColor,
    );
  }
}
