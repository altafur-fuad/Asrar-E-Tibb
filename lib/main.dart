import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// imports
import 'farmacia/cart_provider.dart';
import 'identity_login_signup/intropage.dart';
import 'theme_controller.dart';
import 'app_themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with error handling
  try {
    await Supabase.initialize(
      url: 'https://ynssqrpfbeavuynxcwxj.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inluc3NxcnBmYmVhdnV5bnhjd3hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1NTUwOTgsImV4cCI6MjA3OTEzMTA5OH0.dbgLfkSmqWizHqu_cM2ySPj0eAqpnNT7Nkrygs3Lh8A',
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Supabase initialization failed: $e');
    // App will still run, but Supabase features won't work
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asrar-e-Tibb',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeController.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const IntroPage(),
    );
  }
}
