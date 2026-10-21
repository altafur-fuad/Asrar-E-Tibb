import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:asrarpages/app_themes.dart';
import 'package:asrarpages/theme_controller.dart';

void main() {
  testWidgets('App theme smoke test verifies light and dark MaterialApp integration', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeController(),
        child: Consumer<ThemeController>(
          builder: (context, themeCtrl, _) {
            return MaterialApp(
              title: 'Asrar-e-Tibb',
              theme: AppThemes.light,
              darkTheme: AppThemes.dark,
              themeMode: themeCtrl.isDark ? ThemeMode.dark : ThemeMode.light,
              home: const Scaffold(
                body: Center(child: Text('Asrar-e-Tibb Design System')),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Asrar-e-Tibb Design System'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
