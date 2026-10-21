import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asrarpages/app_colors.dart';
import 'package:asrarpages/app_themes.dart';
import 'package:asrarpages/widgets/widgets.dart';

void main() {
  group('AppColors & Tokens Tests', () {
    test('Verified brand color token values', () {
      expect(AppColors.brandForest, const Color(0xFF064E3B));
      expect(AppColors.brandGreen, const Color(0xFF0B6B4B));
      expect(AppColors.brandFresh, const Color(0xFF23845B));
      expect(AppColors.pageIvory, const Color(0xFFF7F7F2));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.ink, const Color(0xFF12231D));
      expect(AppColors.softSage, const Color(0xFFE6F0EA));
      expect(AppColors.accentAmber, const Color(0xFFE6B84B));
      expect(AppColors.danger, const Color(0xFFB42318));
    });

    test('Backward compatibility alias in AppThemes', () {
      expect(AppThemes.primaryBlue, AppColors.brandGreen);
      expect(AppThemes.brandForest, AppColors.brandForest);
      expect(AppThemes.brandGreen, AppColors.brandGreen);
    });

    test('ThemeData light and dark color schemes verify correct tokens', () {
      final lightTheme = AppThemes.light;
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.scaffoldBackgroundColor, AppColors.pageIvory);
      expect(lightTheme.colorScheme.primary, AppColors.brandGreen);
      expect(lightTheme.colorScheme.surface, AppColors.surface);

      final darkTheme = AppThemes.dark;
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.scaffoldBackgroundColor, AppColors.scaffoldDark);
      expect(darkTheme.colorScheme.primary, AppColors.brandFresh);
      expect(darkTheme.colorScheme.surface, AppColors.surfaceDark);
    });
  });

  group('BrandButton Widget Tests', () {
    testWidgets('Renders text and triggers onPressed callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BrandButton(
              text: 'Explore Medicines',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Explore Medicines'), findsOneWidget);
      await tester.tap(find.byType(BrandButton));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('Shows CircularProgressIndicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BrandButton(
              text: 'Submitting',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submitting'), findsNothing);
    });

    testWidgets('Renders icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BrandButton(
              text: 'Add to Cart',
              icon: Icons.shopping_bag_outlined,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
    });
  });

  group('StatusPill Widget Tests', () {
    testWidgets('Renders label and icon with sage variant', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusPill(
              label: 'Syrup',
              icon: Icons.water_drop_rounded,
              variant: StatusPillVariant.sage,
            ),
          ),
        ),
      );

      expect(find.text('Syrup'), findsOneWidget);
      expect(find.byIcon(Icons.water_drop_rounded), findsOneWidget);
    });

    testWidgets('Responds to onTap when interactive', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusPill(
              label: 'Verified',
              variant: StatusPillVariant.fresh,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Verified'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('SearchTextField Widget Tests', () {
    testWidgets('Renders hint and receives input text', (tester) async {
      String query = '';
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTextField(
              controller: controller,
              hintText: 'Search brand or generic...',
              onChanged: (val) => query = val,
            ),
          ),
        ),
      );

      expect(find.text('Search brand or generic...'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Paracetamol');
      await tester.pump();

      expect(query, 'Paracetamol');
      expect(controller.text, 'Paracetamol');

      // Clear button should now be visible
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(controller.text, isEmpty);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });
  });

  group('MedicineImageBadge Widget Tests', () {
    testWidgets('Renders deterministic dosage-form icon and monogram for Tablet', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MedicineImageBadge(
              brandName: 'Napa Extra',
              dosageForm: 'Tablet',
            ),
          ),
        ),
      );

      // Should render medication icon for Tablet
      expect(find.byIcon(Icons.medication_rounded), findsOneWidget);
      // Should show monogram 'NE' in background
      expect(find.text('NE'), findsOneWidget);
    });

    testWidgets('Renders syrup droplet icon for Syrup dosage form', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MedicineImageBadge(
              brandName: 'A-Cold',
              dosageForm: 'Syrup',
            ),
          ),
        ),
      );

      // Should render water droplet for Syrup
      expect(find.byIcon(Icons.water_drop_rounded), findsOneWidget);
      // Monogram for A-Cold
      expect(find.text('AC'), findsOneWidget);
    });

    testWidgets('Renders vaccines icon for Injection', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MedicineImageBadge(
              brandName: 'A-Clox',
              dosageForm: 'Injection',
              size: 80,
              showDosageLabel: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.vaccines_rounded), findsOneWidget);
      expect(find.text('Injection'), findsOneWidget);
    });
  });
}
