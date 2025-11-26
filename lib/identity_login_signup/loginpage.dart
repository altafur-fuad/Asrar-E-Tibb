// lib/identity_login_signup/loginpage.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../sevices/supabase_auth_hepler.dart';
import '../theme_controller.dart';
import '../pages/homepage.dart';
import '../admin/adminhomepage.dart';
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
  final supabase = Supabase.instance.client;
  final authService = SupabaseAuthService();

  bool _loading = false;

  // -------------------------------------------------------------------------
  // LOGIN LOGIC (FULLY FIXED)
  // -------------------------------------------------------------------------
  Future<void> _loginUser() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter your email and password");
      return;
    }

    setState(() => _loading = true);

    try {
      // ------------------ 1. Supabase Auth Login ------------------
      final res = await authService.login(email, password);

      if (res.user == null) {
        _showSnackBar("Invalid email or password.", color: Colors.red);
        return;
      }

      final uid = res.user!.id;

      // ------------------ 2. Fetch User Row ------------------
      final userRow = await supabase
          .from('users')
          .select('role, is_blocked')
          .eq('id', uid)
          .maybeSingle();

      if (userRow == null) {
        _showSnackBar(
          "User profile not found. Please sign up first.",
          color: Colors.red,
        );
        await authService.signOut();
        return;
      }

      // ------------------ 3. Block Check ------------------
      if (userRow['is_blocked'] == true) {
        _showSnackBar("Your account has been blocked.", color: Colors.red);
        await authService.signOut();
        return;
      }

      // ------------------ 4. Admin Login ------------------
      if (userRow['role'] == 'admin') {
        await _saveSessionLocally(role: 'admin', email: email, userId: uid);

        _showSnackBar("Welcome Admin 👑", color: Colors.green);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomePage()),
        );
        return;
      }

      // ------------------ 5. Normal User Role Match ------------------
      final dbRole = userRow['role'].toString().toLowerCase();
      String selected = widget.selectedRole.toLowerCase();

      if (selected == "shopowner" || selected == "shop_owner") {
        selected = "shop owner";
      }

      if (dbRole != selected) {
        await authService.signOut();
        _showSnackBar(
          "Wrong identity selected! Your role is '$dbRole'.",
          color: Colors.red,
        );
        return;
      }

      // ------------------ 6. Save Session ------------------
      await _saveSessionLocally(role: dbRole, email: email, userId: uid);

      _showSnackBar("Login Successful 🎉", color: Colors.green);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      _showSnackBar("Login failed: $e", color: Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Save session
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

  // -------------------------------------------------------------------------
  // UI (UNCHANGED)
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.isDark;

    final logo = isDark
        ? 'assets/image/logo_dark1.png'
        : 'assets/image/logo_light1.png';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _loginHeader(logo, isDark),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _inputField(_emailCtrl, "Email", Icons.email_outlined),
                    const SizedBox(height: 25),
                    _inputField(
                      _passCtrl,
                      "Password",
                      Icons.lock_outline,
                      obscure: true,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _loading ? null : _loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignUpPage(role: widget.selectedRole),
                        ),
                      ),
                      child: const Text.rich(
                        TextSpan(
                          text: "Don’t have an account? ",
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: "Signup",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- LOGIN UI DESIGN ----------------
  Widget _loginHeader(String logo, bool isDark) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _LoginCurvePainter(isDark)),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Image.asset(logo, height: 130),
            ),
          ),
          const Positioned(
            left: 20,
            bottom: 10,
            child: Text(
              "Login",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(icon),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              obscureText: obscure,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, {Color color = Colors.black87}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}

class _LoginCurvePainter extends CustomPainter {
  final bool isDark;
  _LoginCurvePainter(this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white70 : Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path();
    path.moveTo(0, size.height);
    path.cubicTo(
      size.width * .5,
      size.height,
      size.width * .5,
      size.height * .6,
      size.width,
      size.height * .6,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
