import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents the discrete authentication and authorization states
/// supported by the application.
enum AuthStatus {
  /// User has an active, valid Supabase session with a verified profile.
  authenticated,

  /// User is not logged in or session has expired.
  unauthenticated,

  /// User exists and is logged in, but has been blocked by an administrator.
  blocked,

  /// User is authenticated in Supabase Auth, but no record exists in the public database.
  profileNotFound,

  /// Verification failed due to network connectivity or server error.
  networkError,
}

/// Structured outcome of an authoritative server session validation.
class SessionValidationResult {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? role;
  final bool isBlocked;
  final String? errorMessage;

  const SessionValidationResult({
    required this.status,
    this.userId,
    this.email,
    this.role,
    this.isBlocked = false,
    this.errorMessage,
  });

  /// Authoritative check: Returns true only when the user is authenticated,
  /// verified as 'admin' in the database, and is NOT blocked.
  bool get isAdmin =>
      status == AuthStatus.authenticated &&
      role?.toLowerCase().trim() == 'admin' &&
      !isBlocked;

  /// Returns true if the user has an active, non-blocked session.
  bool get isValid => status == AuthStatus.authenticated && !isBlocked;

  @override
  String toString() {
    return 'SessionValidationResult(status: $status, role: $role, isBlocked: $isBlocked)';
  }
}

/// Centralized service handling Supabase authentication lifecycle,
/// authoritative server-side role resolution, and session persistence.
class SupabaseAuthService {
  final SupabaseClient? _client;

  SupabaseAuthService([this._client]);

  SupabaseClient get client {
    if (_client != null) return _client;
    return Supabase.instance.client;
  }

  // --------------------------- SESSION GETTERS ---------------------------

  Session? get currentSession {
    try {
      return client.auth.currentSession;
    } catch (_) {
      return null;
    }
  }

  User? get currentUser {
    try {
      return client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  bool get isAuthenticated => currentSession != null && currentUser != null;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // --------------------------- SIGN UP ---------------------------
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final res = await client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );
      return res;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains("already registered") || msg.contains("duplicate")) {
        throw Exception("This email address is already registered.");
      }
      if (msg.contains("password")) {
        throw Exception("Password must be at least 6 characters.");
      }
      if (msg.contains("invalid email")) {
        throw Exception("Please provide a valid email address.");
      }
      throw Exception(e.message);
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (err.contains("already") || err.contains("duplicate")) {
        throw Exception("This email is already registered.");
      }
      if (err.contains("password")) {
        throw Exception("Password must be at least 6 characters.");
      }
      throw Exception("Registration failed. Please check your network connection.");
    }
  }

  // --------------------------- LOGIN ---------------------------
  Future<AuthResponse> login(String email, String password) async {
    try {
      final res = await client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );
      return res;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains("invalid login credentials") ||
          msg.contains("invalid_grant") ||
          msg.contains("invalid email or password")) {
        throw Exception("Incorrect email address or password.");
      }
      if (msg.contains("email not confirmed")) {
        throw Exception("Please verify your email before logging in.");
      }
      throw Exception(e.message);
    } catch (_) {
      throw Exception("Login failed. Please check your network connection.");
    }
  }

  // --------------------------- LOGOUT ---------------------------
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      debugPrint("signOut exception: $e");
    }
  }

  /// Clears server session and purges all locally cached credentials
  /// in [SharedPreferences] to prevent stale or spoofed privilege persistence.
  Future<void> signOutAndClearLocalState() async {
    await signOut();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_role');
      await prefs.remove('user_email');
      await prefs.remove('user_id');
    } catch (e) {
      debugPrint("clearLocalState exception: $e");
    }
  }

  // ------------------- AUTHORITATIVE SESSION VALIDATION -------------------

  /// Validates the current session against the server database.
  /// Never trusts locally stored preferences as proof of authentication or role.
  Future<SessionValidationResult> validateCurrentSession() async {
    final session = currentSession;
    final user = currentUser;

    if (session == null || user == null) {
      return const SessionValidationResult(
        status: AuthStatus.unauthenticated,
      );
    }

    final uid = user.id;
    final email = user.email;

    try {
      // 1. Authoritative check: Query users table
      final userRow = await client
          .from('users')
          .select('id, role, is_blocked, email')
          .eq('id', uid)
          .maybeSingle();

      if (userRow != null) {
        final isBlocked = userRow['is_blocked'] == true;
        final rawRole = userRow['role']?.toString().toLowerCase().trim() ?? 'patient';

        if (isBlocked) {
          return SessionValidationResult(
            status: AuthStatus.blocked,
            userId: uid,
            email: email,
            role: rawRole,
            isBlocked: true,
            errorMessage: 'Account is blocked by an administrator.',
          );
        }

        return SessionValidationResult(
          status: AuthStatus.authenticated,
          userId: uid,
          email: email,
          role: rawRole,
          isBlocked: false,
        );
      }

      // 2. Fallback check: Query profiles table if users row was not populated
      try {
        final profileRow = await client
            .from('profiles')
            .select('id, role')
            .eq('id', uid)
            .maybeSingle();

        if (profileRow != null) {
          final rawRole = profileRow['role']?.toString().toLowerCase().trim() ?? 'patient';
          return SessionValidationResult(
            status: AuthStatus.authenticated,
            userId: uid,
            email: email,
            role: rawRole,
            isBlocked: false,
          );
        }
      } catch (_) {}

      // Profile was not found in either table
      return SessionValidationResult(
        status: AuthStatus.profileNotFound,
        userId: uid,
        email: email,
        errorMessage: 'User profile not found in database.',
      );
    } on PostgrestException catch (e) {
      debugPrint('validateCurrentSession PostgrestException: ${e.message}');
      return SessionValidationResult(
        status: AuthStatus.networkError,
        userId: uid,
        email: email,
        errorMessage: e.message,
      );
    } catch (e) {
      debugPrint('validateCurrentSession error: $e');
      return SessionValidationResult(
        status: AuthStatus.networkError,
        userId: uid,
        email: email,
        errorMessage: 'Network error while verifying session.',
      );
    }
  }

  /// Asynchronously verifies whether the current authenticated user
  /// has verified administrator privileges in the authoritative database.
  Future<bool> verifyAdminPrivileges() async {
    final result = await validateCurrentSession();
    return result.isAdmin;
  }
}
