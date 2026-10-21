import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:asrarpages/admin/adminhomepage.dart';
import 'package:asrarpages/app_themes.dart';
import 'package:asrarpages/identity_login_signup/identityscreen.dart';
import 'package:asrarpages/identity_login_signup/intropage.dart';
import 'package:asrarpages/pages/homepage.dart';
import 'package:asrarpages/services/supabase_auth_helper.dart';
import 'package:asrarpages/theme_controller.dart';

/// Test mock implementation of [SupabaseAuthService] allowing controlled
/// simulation of server-side session and role validation states.
class MockSupabaseAuthService extends SupabaseAuthService {
  final SessionValidationResult mockResult;
  bool clearedLocalState = false;

  MockSupabaseAuthService(this.mockResult);

  @override
  Future<SessionValidationResult> validateCurrentSession() async {
    return mockResult;
  }

  @override
  Future<bool> verifyAdminPrivileges() async {
    return mockResult.isAdmin;
  }

  @override
  Future<void> signOutAndClearLocalState() async {
    clearedLocalState = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
  }
}

Widget createTestApp(Widget home) {
  return ChangeNotifierProvider(
    create: (_) => ThemeController(),
    child: MaterialApp(
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      home: home,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionValidationResult Unit Tests', () {
    test('isAdmin is true ONLY when authenticated, role is admin, and not blocked', () {
      const validAdmin = SessionValidationResult(
        status: AuthStatus.authenticated,
        userId: 'admin-1',
        email: 'admin@asraretibb.com',
        role: 'admin',
        isBlocked: false,
      );
      expect(validAdmin.isAdmin, isTrue);
      expect(validAdmin.isValid, isTrue);
    });

    test('isAdmin is false if admin is blocked', () {
      const blockedAdmin = SessionValidationResult(
        status: AuthStatus.blocked,
        userId: 'admin-blocked',
        email: 'blocked@asraretibb.com',
        role: 'admin',
        isBlocked: true,
      );
      expect(blockedAdmin.isAdmin, isFalse);
      expect(blockedAdmin.isValid, isFalse);
    });

    test('isAdmin is false if unauthenticated even if role string is admin', () {
      const unauthAdmin = SessionValidationResult(
        status: AuthStatus.unauthenticated,
        role: 'admin',
      );
      expect(unauthAdmin.isAdmin, isFalse);
      expect(unauthAdmin.isValid, isFalse);
    });

    test('isAdmin is false for normal roles (patient, doctor, pharmacist, shop owner)', () {
      for (final role in ['patient', 'doctor', 'pharmacist', 'shop owner']) {
        final result = SessionValidationResult(
          status: AuthStatus.authenticated,
          userId: 'user-1',
          email: '$role@test.com',
          role: role,
          isBlocked: false,
        );
        expect(result.isAdmin, isFalse, reason: 'Role $role should not have admin access');
        expect(result.isValid, isTrue);
      }
    });
  });

  group('IntroPage & Admin Vulnerability Tests', () {
    testWidgets('Forged local admin preference in SharedPreferences DOES NOT grant admin access', (tester) async {
      // 1. Simulate an attacker setting local storage role to 'admin'
      SharedPreferences.setMockInitialValues({
        'user_role': 'admin',
        'user_email': 'hacker@malicious.com',
        'user_id': 'forged-admin-uuid',
      });

      // 2. Server validation returns unauthenticated (no valid Supabase session)
      final mockAuth = MockSupabaseAuthService(
        const SessionValidationResult(status: AuthStatus.unauthenticated),
      );

      // 3. Launch IntroPage with immediate execution
      await tester.pumpWidget(
        createTestApp(
          IntroPage(
            authService: mockAuth,
            delay: Duration.zero,
          ),
        ),
      );

      // Pump to let Future.delayed execute and navigation complete
      await tester.pump();
      await tester.pumpAndSettle();

      // 4. Assert that AdminHomePage is NOT rendered
      expect(find.byType(AdminHomePage), findsNothing);

      // 5. Assert that unauthenticated navigation routes to IdentitySelectionScreen
      expect(find.byType(IdentitySelectionScreen), findsOneWidget);

      // 6. Assert that local forged credentials were completely purged
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_role'), isNull);
      expect(prefs.getString('user_email'), isNull);
      expect(prefs.getString('user_id'), isNull);
      expect(mockAuth.clearedLocalState, isTrue);
    });

    testWidgets('Active session with patient role routes to HomePage and corrects forged admin local preference', (tester) async {
      // Attacker tried to forge admin in preferences
      SharedPreferences.setMockInitialValues({
        'user_role': 'admin',
        'user_email': 'patient@asraretibb.com',
        'user_id': 'patient-id-123',
      });

      // Server returns authoritative role as 'patient'
      final mockAuth = MockSupabaseAuthService(
        const SessionValidationResult(
          status: AuthStatus.authenticated,
          userId: 'patient-id-123',
          email: 'patient@asraretibb.com',
          role: 'patient',
          isBlocked: false,
        ),
      );

      await tester.pumpWidget(
        createTestApp(
          IntroPage(
            authService: mockAuth,
            delay: Duration.zero,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Must NOT route to AdminHomePage
      expect(find.byType(AdminHomePage), findsNothing);

      // Must route to normal HomePage
      expect(find.byType(HomePage), findsOneWidget);

      // SharedPreferences user_role must be overwritten with server truth 'patient'
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_role'), equals('patient'));
    });

    testWidgets('Authoritative server-verified admin routes to AdminHomePage', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final mockAuth = MockSupabaseAuthService(
        const SessionValidationResult(
          status: AuthStatus.authenticated,
          userId: 'admin-verified-id',
          email: 'admin@asraretibb.com',
          role: 'admin',
          isBlocked: false,
        ),
      );

      await tester.pumpWidget(
        createTestApp(
          IntroPage(
            authService: mockAuth,
            delay: Duration.zero,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(AdminHomePage), findsOneWidget);
      expect(find.byType(IdentitySelectionScreen), findsNothing);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_role'), equals('admin'));
    });

    testWidgets('Blocked user is rejected and routed to IdentitySelectionScreen', (tester) async {
      SharedPreferences.setMockInitialValues({
        'user_role': 'patient',
        'user_email': 'blocked@asraretibb.com',
        'user_id': 'blocked-id',
      });

      final mockAuth = MockSupabaseAuthService(
        const SessionValidationResult(
          status: AuthStatus.blocked,
          userId: 'blocked-id',
          email: 'blocked@asraretibb.com',
          role: 'patient',
          isBlocked: true,
          errorMessage: 'Account is suspended.',
        ),
      );

      await tester.pumpWidget(
        createTestApp(
          IntroPage(
            authService: mockAuth,
            delay: Duration.zero,
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(AdminHomePage), findsNothing);
      expect(find.byType(HomePage), findsNothing);
      expect(find.byType(IdentitySelectionScreen), findsOneWidget);
      expect(mockAuth.clearedLocalState, isTrue);
    });
  });

  group('IdentitySelectionScreen Role Tests', () {
    testWidgets('Renders all four permitted roles and never includes Admin', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        createTestApp(const IdentitySelectionScreen()),
      );
      await tester.pumpAndSettle();

      // Must find the four valid roles
      expect(find.text('Patient'), findsOneWidget);
      expect(find.text('Doctor'), findsOneWidget);
      expect(find.text('Pharmacist'), findsOneWidget);
      expect(find.text('Shop Owner'), findsOneWidget);

      // Must NEVER display Admin in public role selection
      expect(find.text('Admin'), findsNothing);
      expect(find.text('Administrator'), findsNothing);
    });

    testWidgets('Selecting a role updates selection and enables continue buttons', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        createTestApp(const IdentitySelectionScreen()),
      );
      await tester.pumpAndSettle();

      // Tap on Doctor card
      await tester.tap(find.text('Doctor'));
      await tester.pumpAndSettle();

      expect(find.text('Sign In as Doctor'), findsOneWidget);
    });
  });

  group('HomePage Lifecycle & Defect Tests', () {
    testWidgets('HomePageInternal renders standalone without _HomePageState direct instantiation', (tester) async {
      SharedPreferences.setMockInitialValues({'user_role': 'patient'});

      await tester.pumpWidget(
        createTestApp(const HomePageInternal()),
      );
      await tester.pumpAndSettle();

      // Verifies dignified greeting copy
      expect(find.text('Assalamu Alaikum'), findsOneWidget);
      expect(find.text('Welcome to Asrar-e-Tibb'), findsOneWidget);

      // Unprofessional greeting must be absent
      expect(find.text('Hello  broo'), findsNothing);
      expect(find.text('Hello Admin 😎'), findsNothing);
    });

    testWidgets('Direct unauthenticated navigation to AdminHomePage is rejected', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final mockAuth = MockSupabaseAuthService(
        const SessionValidationResult(status: AuthStatus.unauthenticated),
      );

      await tester.pumpWidget(
        createTestApp(
          AdminHomePage(authService: mockAuth),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Must be ejected to HomePage
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
