import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine_model.dart';
import 'cart_provider.dart';

class DetailsPage extends StatelessWidget {
  final Medicine medicine;
  const DetailsPage({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(medicine.brandName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('assets/image/pic.png', height: 120)),
            const SizedBox(height: 20),
            Text(
              medicine.brandName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(medicine.generic, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text("Manufacturer: ${medicine.manufacturer}"),
            Text("Dosage: ${medicine.strength}"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  cart.addItem(medicine);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart')),
                  );
                },
                child: const Text("Add to Cart"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
