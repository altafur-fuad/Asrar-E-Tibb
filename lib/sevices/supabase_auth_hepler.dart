import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  SupabaseClient get client => Supabase.instance.client;

  // --------------------------- SIGN UP ---------------------------
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final res = await client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );
      return res;
    } catch (e) {
      final err = e.toString().toLowerCase();

      if (err.contains("invalid email")) {
        throw Exception("Invalid email address.");
      }
      if (err.contains("password")) {
        throw Exception("Password must be at least 6 characters.");
      }
      if (err.contains("already") || err.contains("duplicate")) {
        throw Exception("This email is already registered.");
      }
      throw Exception("Signup failed. Please try again.");
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
    } catch (e) {
      final err = e.toString().toLowerCase();

      if (err.contains("invalid")) {
        throw Exception("Incorrect email or password.");
      }
      if (err.contains("not confirmed")) {
        throw Exception("Please verify your email.");
      }

      throw Exception("Login failed.");
    }
  }

  // --------------------------- LOGOUT ---------------------------
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (_) {}
  }

  Session? get currentSession => client.auth.currentSession;
}
