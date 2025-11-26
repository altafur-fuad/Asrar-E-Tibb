import 'package:flutter/material.dart';
import '../data/data_provider.dart';
import '../models/medicine_model.dart';
import 'medicinedetailspage.dart';

class AlternativeBrandsPage extends StatefulWidget {
  final String generic;
  const AlternativeBrandsPage({super.key, required this.generic});

  @override
  State<AlternativeBrandsPage> createState() => _AlternativeBrandsPageState();
}

class _AlternativeBrandsPageState extends State<AlternativeBrandsPage> {
  List<Medicine> _brands = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlternatives();
  }

  Future<void> _loadAlternatives() async {
    final meds = await DataProvider.loadMedicines(generic: widget.generic);
    setState(() {
      _brands = meds;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alternative Brands")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _brands.length,
              itemBuilder: (context, i) {
                final m = _brands[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(
                      m.brandName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${m.manufacturer}\n${m.strength} • ${m.dosageForm}",
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MedicineDetailPage(medicine: m),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
