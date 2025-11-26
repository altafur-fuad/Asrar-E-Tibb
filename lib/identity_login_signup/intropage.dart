// lib/identity_login_signup/intropage.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/homepage.dart';
import 'identityscreen.dart';
import '../admin/adminhomepage.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconFadeAnimation;
  late Animation<Offset> _iconSlideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );
    _iconFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );
    _iconSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
          ),
        );

    _controller.forward();
    Future.delayed(const Duration(seconds: 3), _checkSession);
  }

  Future<void> _checkSession() async {
    final supabase = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();

    final session = supabase.auth.currentSession;
    final role = prefs.getString('user_role');
    final email = prefs.getString('user_email');
    final userId = prefs.getString('user_id');

    // 1) If admin saved locally -> go to AdminHomePage
    if (role != null && role == 'admin' && email != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomePage()),
      );
      return;
    }

    // 2) If Supabase session exists and userId present -> go Home
    if (session != null && userId != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
      return;
    }

    // 3) If no supabase session but local user_id exists (expired session), try silent refresh
    if (userId != null && session == null) {
      // We didn't save refresh token; but still allow local path to home to avoid user locked out.
      // It's better to route to Home and let app handle missing session features.
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
      return;
    }

    // 4) Default -> Identity selection
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const IdentitySelectionScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? [Colors.black, Colors.blueGrey.shade900, Colors.black]
        : [Colors.white, Colors.blue.shade50, Colors.blueGrey.shade200];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    Image.asset(
                      isDark
                          ? 'assets/image/logo_dark1.png'
                          : 'assets/image/logo_light1.png',
                      height: 150,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
            SlideTransition(
              position: _iconSlideAnimation,
              child: FadeTransition(
                opacity: _iconFadeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _bottomIcon('assets/image/pic.png'),
                    _bottomIcon('assets/image/logo.png'),
                    _bottomIcon('assets/image/heart.png'),
                    _bottomIcon('assets/image/ll.png'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomIcon(String path) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Image.asset(path, height: 30, width: 30, fit: BoxFit.contain),
    );
  }
}
