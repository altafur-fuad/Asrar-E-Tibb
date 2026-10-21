import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../pages/homepage.dart';
import '../services/supabase_auth_helper.dart';
import 'identityscreen.dart';
import '../admin/adminhomepage.dart';

/// Introductory splash screen that performs authoritative session validation
/// before navigating to protected or authenticated app routes.
class IntroPage extends StatefulWidget {
  final SupabaseAuthService? authService;
  final Duration delay;

  const IntroPage({
    super.key,
    this.authService,
    this.delay = const Duration(seconds: 3),
  });

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
      duration: widget.delay,
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
    Future.delayed(widget.delay, _checkSession);
  }

  /// Authoritatively validates current session with the server.
  /// Never trusts SharedPreferences as proof of administrator privileges.
  Future<void> _checkSession() async {
    final authService = widget.authService ?? SupabaseAuthService();

    try {
      final validation = await authService.validateCurrentSession();

      if (!mounted) return;

      switch (validation.status) {
        case AuthStatus.authenticated:
          if (validation.isBlocked) {
            await authService.signOutAndClearLocalState();
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const IdentitySelectionScreen()),
            );
            return;
          }

          // Authoritative server-verified admin check
          if (validation.isAdmin) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_role', 'admin');
            if (validation.email != null) {
              await prefs.setString('user_email', validation.email!);
            }
            if (validation.userId != null) {
              await prefs.setString('user_id', validation.userId!);
            }

            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AdminHomePage(authService: widget.authService),
              ),
            );
            return;
          }

          // Normal authenticated user (Patient, Doctor, Pharmacist, Shop Owner)
          final verifiedRole = validation.role ?? 'patient';
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_role', verifiedRole);
          if (validation.email != null) {
            await prefs.setString('user_email', validation.email!);
          }
          if (validation.userId != null) {
            await prefs.setString('user_id', validation.userId!);
          }

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(authService: widget.authService),
            ),
          );
          return;

        case AuthStatus.blocked:
          await authService.signOutAndClearLocalState();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account has been suspended. Please contact support.'),
              backgroundColor: AppColors.danger,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const IdentitySelectionScreen()),
          );
          return;

        case AuthStatus.profileNotFound:
        case AuthStatus.unauthenticated:
        case AuthStatus.networkError:
          // In case of unauthenticated state, missing profile, or invalid session:
          // Purge any stale or spoofed local credentials
          await authService.signOutAndClearLocalState();
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const IdentitySelectionScreen()),
          );
          return;
      }
    } catch (_) {
      // Safe fallback: redirect to identity selection
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const IdentitySelectionScreen()),
      );
    }
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
        ? [AppColors.scaffoldDark, AppColors.surfaceDark, AppColors.scaffoldDark]
        : [AppColors.pageIvory, AppColors.softSage, AppColors.pageIvory];

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
                    _bottomIcon('assets/image/medicine.png'),
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Image.asset(path, height: 32, width: 32, fit: BoxFit.contain),
    );
  }
}
