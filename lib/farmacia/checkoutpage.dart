import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  final double total;

  const CheckoutPage({super.key, required this.total});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedAddress = "Home";
  String selectedPayment = "Cash on Delivery";

  final double deliveryFee = 30.0;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final subTotal = cart.total;
    final totalAmount = subTotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Delivery Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildAddressOption("Home", "Muradpur"),
              _buildAddressOption("Office", "Muradpur"),
              const SizedBox(height: 25),
              const Text(
                "Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildPaymentOption("Cash on Delivery"),
              _buildPaymentOption("Bkash / Nagad / Rocket"),
              _buildPaymentOption("Card Payment"),
              const SizedBox(height: 25),
              const Divider(thickness: 1),
              const SizedBox(height: 10),
              _buildAmountRow(
                "Delivery Fee",
                "৳${deliveryFee.toStringAsFixed(2)}",
              ),
              _buildAmountRow("Subtotal", "৳${subTotal.toStringAsFixed(2)}"),
              const Divider(thickness: 1),
              _buildAmountRow(
                "Total",
                "৳${totalAmount.toStringAsFixed(2)}",
                isBold: true,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: const Text("Order Placed!"),
                        content: Text(
                          "Your order has been placed successfully.\n\n"
                          "Delivery: $selectedAddress\n"
                          "Payment: $selectedPayment\n"
                          "Total: ৳${totalAmount.toStringAsFixed(2)}",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    "Confirm & Pay",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressOption(String title, String subtitle) {
    final bool selected = selectedAddress == title;
    return InkWell(
      onTap: () => setState(() => selectedAddress = title),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: ListTile(
          leading: Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? Colors.blue : Colors.grey,
          ),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title) {
    final bool selected = selectedPayment == title;
    return InkWell(
      onTap: () => setState(() => selectedPayment = title),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: ListTile(
          leading: Icon(
            selected ? Icons.check_circle : Icons.circle_outlined,
            color: selected ? Colors.green : Colors.grey,
          ),
          title: Text(title),
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
