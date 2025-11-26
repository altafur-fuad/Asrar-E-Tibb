import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme_controller.dart';
import 'loginpage.dart';
import 'signuppage.dart';

class IdentitySelectionScreen extends StatefulWidget {
  const IdentitySelectionScreen({super.key});

  @override
  State<IdentitySelectionScreen> createState() =>
      _IdentitySelectionScreenState();
}

class _IdentitySelectionScreenState extends State<IdentitySelectionScreen> {
  String? selectedIdentity;

  final List<Map<String, dynamic>> identities = [
    {'title': 'Patient', 'icon': Icons.person},
    {'title': 'Doctor', 'icon': Icons.medical_services},
    {'title': 'Pharmacist', 'icon': Icons.local_pharmacy},
    {'title': 'Shop Owner', 'icon': Icons.storefront},
  ];

  Future<void> _saveRoleAndNavigate(Widget page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', selectedIdentity!);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.isDark;

    final logo = isDark
        ? 'assets/image/logo_dark1.png'
        : 'assets/image/logo_light1.png';
    final selectedColor = isDark ? Colors.lightBlueAccent : Colors.blue;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Choose Your Identity'),
        actions: [
          Row(
            children: [
              Icon(
                Icons.light_mode,
                color: isDark ? Colors.white70 : Colors.black87,
                size: 18,
              ),
              Switch(
                value: isDark,
                onChanged: (v) => themeController.toggleTheme(v),
              ),
              Icon(
                Icons.dark_mode,
                color: isDark ? Colors.white : Colors.black87,
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Image.asset(logo, height: 140),
              const SizedBox(height: 24),
              const Text(
                'Choose Your Identity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: identities.map((identity) {
                    final isSelected = selectedIdentity == identity['title'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedIdentity = identity['title']);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withOpacity(0.12)
                              : Theme.of(context).cardColor,
                          border: Border.all(
                            color: isSelected ? selectedColor : Colors.grey,
                            width: isSelected ? 2.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              identity['icon'],
                              size: 48,
                              color: isSelected
                                  ? selectedColor
                                  : Theme.of(context).iconTheme.color,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              identity['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (selectedIdentity != null)
                Text(
                  'You Selected: $selectedIdentity',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedIdentity == null
                      ? null
                      : () => _saveRoleAndNavigate(
                          LoginPage(selectedRole: selectedIdentity!),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedIdentity == null
                        ? Colors.grey
                        : selectedColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: selectedIdentity == null
                    ? null
                    : () => _saveRoleAndNavigate(
                        SignUpPage(role: selectedIdentity!),
                      ),
                child: Text(
                  'New user? Create an account',
                  style: TextStyle(color: selectedColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
