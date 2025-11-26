import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("About App"), centerTitle: true),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "AsrareTibb / Medilens",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _card(
            title: "App Description",
            text:
                "This app helps users explore detailed medicine information such as generic name, brand name, dosage, herbal ingredients, side effects and more. Designed for doctors, pharmacists, students and general users.",
          ),

          const SizedBox(height: 16),

          _card(
            title: "Goal & Mission",
            text:
                "To provide fast, accurate and multilingual medical knowledge so that anyone can find trusted information instantly anytime, anywhere.",
          ),

          const SizedBox(height: 16),

          _card(title: "Version", text: "v1.0.0"),
        ],
      ),
    );
  }

  Widget _card({required String title, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
