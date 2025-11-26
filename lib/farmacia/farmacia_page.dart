import 'package:asrarpages/medicine_page/medicinedetailspage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/data_provider.dart';
import '../models/medicine_model.dart';
import 'cart_provider.dart';
import 'cart_page.dart';

class FarmaciaPage extends StatefulWidget {
  const FarmaciaPage({super.key});

  @override
  State<FarmaciaPage> createState() => _FarmaciaPageState();
}

class _FarmaciaPageState extends State<FarmaciaPage> {
  List<Medicine> medicines = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<Medicine> _filteredMedicines = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DataProvider.loadMedicines();
    setState(() {
      medicines = data;
      _filteredMedicines = data;
      isLoading = false;
    });
  }

  void _filterMedicines(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMedicines = medicines;
      } else {
        _filteredMedicines = medicines.where((medicine) {
          return medicine.brandName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              medicine.generic.toLowerCase().contains(query.toLowerCase()) ||
              medicine.manufacturer.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Widget _buildMedicineCard(Medicine med, BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isInCart = cart.items.any((item) => item.medicine.id == med.id);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.all(6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medicine Image/Icon
                Container(
                  height: constraints.maxHeight * 0.25,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication,
                    size: 40,
                    color: Colors.blue.shade700,
                  ),
                ),

                // Brand Name
                Text(
                  med.brandName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Generic
                Text(
                  med.generic,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Strength & Manufacturer
                Flexible(
                  child: Text(
                    "${med.strength} • ${med.manufacturer}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Price + Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      med.unitPrice != null && med.unitPrice!.isNotEmpty
                          ? "৳${med.unitPrice}"
                          : "৳0.00",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (isInCart) {
                          cart.removeItem(med.id as Medicine);
                        } else {
                          cart.addItem(med);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInCart ? Colors.red : Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: const Size(0, 0),
                      ),
                      child: Text(
                        isInCart ? "Remove" : "Add to Cart",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Farmacia",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  );
                },
              ),
              if (cart.count > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      cart.count.toString(),
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      onChanged: _filterMedicines,
                    ),
                  ),
                  Expanded(
                    child: _filteredMedicines.isEmpty
                        ? const Center(
                            child: Text(
                              "No medicines found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 8,
                              bottom: 12,
                            ),
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio:
                                      0.82, // ✅ Increased slightly
                                ),
                            itemCount: _filteredMedicines.length,
                            itemBuilder: (context, index) {
                              final med = _filteredMedicines[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MedicineDetailPage(medicine: med),
                                    ),
                                  );
                                },
                                child: _buildMedicineCard(med, context),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
