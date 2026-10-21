import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../theme_controller.dart';
import '../widgets/brand_button.dart';
import 'loginpage.dart';
import 'signuppage.dart';

/// Screen allowing new and returning users to select their authoritative role:
/// Patient, Doctor, Pharmacist, or Shop Owner.
/// Admin role is strictly excluded from public selection.
class IdentitySelectionScreen extends StatefulWidget {
  const IdentitySelectionScreen({super.key});

  @override
  State<IdentitySelectionScreen> createState() =>
      _IdentitySelectionScreenState();
}

class _IdentitySelectionScreenState extends State<IdentitySelectionScreen> {
  String? selectedIdentity;

  final List<Map<String, dynamic>> identities = const [
    {
      'title': 'Patient',
      'icon': Icons.person_outline,
      'subtitle': 'Reminders, notes & medication directory',
    },
    {
      'title': 'Doctor',
      'icon': Icons.medical_services_outlined,
      'subtitle': 'Verified healthcare practice & community',
    },
    {
      'title': 'Pharmacist',
      'icon': Icons.local_pharmacy_outlined,
      'subtitle': 'Medicine knowledge & pharmacy network',
    },
    {
      'title': 'Shop Owner',
      'icon': Icons.storefront_outlined,
      'subtitle': 'Storefront, inventory & distribution',
    },
  ];

  Future<void> _saveRoleAndNavigate(Widget page) async {
    if (selectedIdentity == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', selectedIdentity!);
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.isDark;

    final logo = isDark
        ? 'assets/image/logo_dark1.png'
        : 'assets/image/logo_light1.png';

    final activeColor = isDark ? AppColors.brandFresh : AppColors.brandForest;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Choose Your Role'),
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
                activeThumbColor: AppColors.brandFresh,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(logo, height: 110),
              const SizedBox(height: 16),
              Text(
                'Welcome to Asrar-e-Tibb',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select your role to access your personalized healthcare portal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 24),

              // 2x2 Grid of Role Cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: identities.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final identity = identities[index];
                  final isSelected = selectedIdentity == identity['title'];

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedIdentity = identity['title'] as String);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? AppColors.softSage.withValues(alpha: 0.12)
                                : AppColors.softSage.withValues(alpha: 0.45))
                            : Theme.of(context).cardColor,
                        border: Border.all(
                          color: isSelected
                              ? activeColor
                              : (isDark
                                  ? AppColors.borderSubtle.withValues(alpha: 0.15)
                                  : AppColors.borderSubtle),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? activeColor.withValues(alpha: 0.15)
                                      : (isDark
                                          ? Colors.white10
                                          : AppColors.softSage.withValues(alpha: 0.5)),
                                ),
                                child: Icon(
                                  identity['icon'] as IconData,
                                  size: 32,
                                  color: isSelected
                                      ? activeColor
                                      : Theme.of(context).iconTheme.color,
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: activeColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            identity['title'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            identity['subtitle'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white54 : AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              BrandButton(
                text: selectedIdentity == null
                    ? 'Select a Role to Continue'
                    : 'Sign In as $selectedIdentity',
                icon: Icons.login,
                isFullWidth: true,
                onPressed: selectedIdentity == null
                    ? null
                    : () => _saveRoleAndNavigate(
                        LoginPage(selectedRole: selectedIdentity!),
                      ),
              ),
              const SizedBox(height: 12),
              BrandButton(
                text: 'Create New Account',
                icon: Icons.person_add_outlined,
                variant: BrandButtonVariant.outline,
                isFullWidth: true,
                onPressed: selectedIdentity == null
                    ? null
                    : () => _saveRoleAndNavigate(
                        SignUpPage(role: selectedIdentity!),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
