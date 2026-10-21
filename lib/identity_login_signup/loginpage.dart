import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_colors.dart';
import '../services/supabase_auth_helper.dart';
import '../theme_controller.dart';
import '../pages/homepage.dart';
import '../admin/adminhomepage.dart';
import '../widgets/brand_button.dart';
import '../widgets/status_pill.dart';
import 'signuppage.dart';

class LoginPage extends StatefulWidget {
  final String selectedRole;
  const LoginPage({super.key, required this.selectedRole});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final supabase = Supabase.instance.client;
  final authService = SupabaseAuthService();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // LOGIN LOGIC
  // -------------------------------------------------------------------------
  Future<void> _loginUser() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter your email and password.", isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      // 1. Supabase Auth Login
      final res = await authService.login(email, password);

      if (res.user == null) {
        _showSnackBar("Invalid email or password.", isError: true);
        return;
      }

      final uid = res.user!.id;

      // 2. Authoritative database role and status check
      final userRow = await supabase
          .from('users')
          .select('role, is_blocked')
          .eq('id', uid)
          .maybeSingle();

      if (userRow == null) {
        _showSnackBar(
          "User profile not found. Please complete registration.",
          isError: true,
        );
        await authService.signOutAndClearLocalState();
        return;
      }

      // 3. Block Check
      if (userRow['is_blocked'] == true) {
        _showSnackBar("This account has been suspended by an administrator.", isError: true);
        await authService.signOutAndClearLocalState();
        return;
      }

      final dbRole = userRow['role'].toString().toLowerCase().trim();

      // 4. Admin Login
      if (dbRole == 'admin') {
        await _saveSessionLocally(role: 'admin', email: email, userId: uid);
        _showSnackBar("Administrator access verified.");

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomePage()),
        );
        return;
      }

      // 5. Normal User Role Match
      String selected = widget.selectedRole.toLowerCase().trim();
      if (selected == "shopowner" || selected == "shop_owner") {
        selected = "shop owner";
      }

      if (dbRole != selected) {
        await authService.signOutAndClearLocalState();
        _showSnackBar(
          "Role mismatch! This account is registered as '$dbRole'.",
          isError: true,
        );
        return;
      }

      // 6. Save Session Locally
      await _saveSessionLocally(role: dbRole, email: email, userId: uid);
      _showSnackBar("Welcome back!");

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      final msg = e.toString().replaceFirst("Exception: ", "");
      _showSnackBar(msg, isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveSessionLocally({
    required String role,
    required String email,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
    await prefs.setString('user_email', email);
    await prefs.setString('user_id', userId);
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.danger : AppColors.brandForest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.isDark;

    final logo = isDark
        ? 'assets/image/logo_dark1.png'
        : 'assets/image/logo_light1.png';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(logo, height: 110),
                const SizedBox(height: 16),
                Text(
                  "Sign In",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Portal: ",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : AppColors.mutedText,
                      ),
                    ),
                    StatusPill(
                      label: widget.selectedRole,
                      variant: StatusPillVariant.sage,
                      icon: Icons.badge_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Email Input
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    hintText: "Enter your registered email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.brandGreen,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Input
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.brandGreen,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Login CTA
                BrandButton(
                  text: "Sign In",
                  isLoading: _loading,
                  icon: Icons.login,
                  isFullWidth: true,
                  onPressed: _loading ? null : _loginUser,
                ),
                const SizedBox(height: 24),

                // Signup Navigation Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don’t have an account? ",
                      style: TextStyle(
                        color: isDark ? Colors.white60 : AppColors.mutedText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignUpPage(role: widget.selectedRole),
                        ),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: AppColors.brandGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
