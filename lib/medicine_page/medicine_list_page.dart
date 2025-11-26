import 'package:flutter/material.dart';
import '../data/data_provider.dart';
import '../models/medicine_model.dart';
import '../app_themes.dart';
import 'medicinedetailspage.dart';

class MedicineListPage extends StatefulWidget {
  final String? filterGeneric;
  final String? filterManufacturer;
  final String? filterDrugClass;
  final String? filterDosageForm;
  final String? filterIndication;

  const MedicineListPage({
    super.key,
    this.filterGeneric,
    this.filterManufacturer,
    this.filterDrugClass,
    this.filterDosageForm,
    this.filterIndication,
  });

  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  late Future<List<Medicine>> _medicinesFuture;
  List<Medicine> _allMedicines = [];
  List<Medicine> _filteredMedicines = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  /// 🔹 Load data from CSV via DataProvider
  void _loadMedicines() {
    _medicinesFuture = DataProvider.loadMedicines(
      generic: widget.filterGeneric,
      manufacturer: widget.filterManufacturer,
      indication: widget.filterIndication,
      drugClass: widget.filterDrugClass,
      dosageForm: widget.filterDosageForm,
    );
  }

  /// 🔹 Filter medicines by query
  void _filterMedicines(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMedicines = _allMedicines;
      } else {
        _filteredMedicines = _allMedicines.where((m) {
          return m.brandName.toLowerCase().contains(query.toLowerCase()) ||
              m.generic.toLowerCase().contains(query.toLowerCase()) ||
              m.manufacturer.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = AppThemes.primaryBlue;

    // 🧾 Determine title dynamically
    final title =
        widget.filterGeneric ??
        widget.filterManufacturer ??
        widget.filterDrugClass ??
        widget.filterDosageForm ??
        widget.filterIndication ??
        "Medicines";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Medicine>>(
        future: _medicinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading data:\n${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No medicines found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // ✅ Load data into lists
          _allMedicines = snapshot.data!;
          _filteredMedicines =
              _filteredMedicines.isEmpty && _searchQuery.isEmpty
              ? _allMedicines
              : _filteredMedicines;

          return Column(
            children: [
              // 🔍 Search Bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: _filterMedicines,
                  decoration: InputDecoration(
                    hintText: "Search medicine, generic, or manufacturer...",
                    prefixIcon: const Icon(Icons.search),
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // 💊 Medicine List
              Expanded(
                child: _filteredMedicines.isEmpty
                    ? Center(
                        child: Text(
                          "No matching results.",
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredMedicines.length,
                        itemBuilder: (context, index) {
                          final medicine = _filteredMedicines[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: isDark ? 0 : 2,
                            color: theme.cardColor,
                            child: ListTile(
                              title: Text(
                                medicine.brandName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                "${medicine.generic} • ${medicine.strength}\n${medicine.manufacturer}",
                                style: TextStyle(
                                  height: 1.4,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                              trailing:
                                  medicine.unitPrice != null &&
                                      medicine.unitPrice!.isNotEmpty
                                  ? Text(
                                      "৳ ${medicine.unitPrice}",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MedicineDetailPage(medicine: medicine),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
