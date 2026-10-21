import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_colors.dart';
import '../pages/homepage.dart';
import '../services/supabase_auth_helper.dart';
import '../widgets/brand_button.dart';
import '../widgets/status_pill.dart';
import 'loginpage.dart';

class SignUpPage extends StatefulWidget {
  final String role;
  const SignUpPage({super.key, required this.role});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final supabase = Supabase.instance.client;
  final authService = SupabaseAuthService();

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _specialistCtrl = TextEditingController();
  final _licenceCtrl = TextEditingController();
  final _workplaceCtrl = TextEditingController();
  final _shopNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  String? _gender;
  String? _bloodGroup;
  DateTime? _dob;

  bool loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late String _selectedRole;

  final List<String> bloodGroups = const [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final List<String> genders = const ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.role;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _specialistCtrl.dispose();
    _licenceCtrl.dispose();
    _workplaceCtrl.dispose();
    _shopNameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  bool get isAdminSignupAttempt =>
      _selectedRole.toLowerCase().trim() == "admin";

  String getTableName() {
    switch (_selectedRole.toLowerCase().trim()) {
      case 'patient':
        return 'patients';
      case 'doctor':
        return 'doctors';
      case 'pharmacist':
        return 'pharmacists';
      case 'shop owner':
      case 'shopowner':
        return 'shop_owners';
      default:
        return 'users';
    }
  }

  // --------------------------- SIGNUP LOGIC ---------------------------
  Future<void> _signup() async {
    if (isAdminSignupAttempt) {
      _snack("Administrator accounts cannot be created via public registration.", err: true);
      return;
    }

    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      _snack("Please fill in all required fields.", err: true);
      return;
    }

    if (password.length < 6) {
      _snack("Password must be at least 6 characters.", err: true);
      return;
    }

    if (password != _confirmPassCtrl.text.trim()) {
      _snack("Passwords do not match.", err: true);
      return;
    }

    setState(() => loading = true);

    try {
      // 1. Supabase Auth user creation
      final authRes = await authService.signUp(email, password);

      if (authRes.user == null) throw "Registration failed.";

      final uid = authRes.user!.id;
      final emailVerified = authRes.user!.emailConfirmedAt != null;

      // Doctor title prefix
      final finalName = _selectedRole.toLowerCase() == "doctor"
          ? "Dr. $name"
          : name;

      // Fix shop owner naming convention
      String normalizedRole = _selectedRole.toLowerCase().trim();
      if (normalizedRole == "shopowner" || normalizedRole == "shop_owner") {
        normalizedRole = "shop owner";
      }

      // 2. Insert into users table
      await supabase.from("users").upsert({
        "id": uid,
        "name": finalName,
        "email": email,
        "mobile": _mobileCtrl.text.trim(),
        "role": normalizedRole,
        "dob": _dob?.toIso8601String(),
        "verified": emailVerified,
        "is_blocked": false,
      });

      // 3. Insert into role-specific table
      await supabase.from(getTableName()).upsert({
        "user_id": uid,
        "auth_id": uid,
        ..._buildRoleData(email),
      });

      // 4. Save session locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_id", uid);
      await prefs.setString("user_email", email);
      await prefs.setString("user_role", normalizedRole);

      _snack("Account created successfully!");

      if (!mounted) return;

      // 5. Navigate to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      final msg = e.toString().replaceFirst("Exception: ", "");
      _snack(msg, err: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // -------------------- ROLE SPECIFIC FIELD DATA --------------------
  Map<String, dynamic> _buildRoleData(String email) {
    switch (_selectedRole.toLowerCase().trim()) {
      case 'patient':
        return {
          "name": _nameCtrl.text.trim(),
          "email": email,
          "mobile": _mobileCtrl.text.trim(),
          "gender": _gender,
          "dob": _dob?.toIso8601String(),
          "blood_group": _bloodGroup,
        };

      case 'doctor':
        return {
          "name": _nameCtrl.text.trim(),
          "email": email,
          "mobile": _mobileCtrl.text.trim(),
          "specialist": _specialistCtrl.text.trim(),
          "licence": _licenceCtrl.text.trim(),
          "workplace": _workplaceCtrl.text.trim(),
          "dob": _dob?.toIso8601String(),
        };

      case 'pharmacist':
        return {
          "name": _nameCtrl.text.trim(),
          "email": email,
          "mobile": _mobileCtrl.text.trim(),
          "workplace": _workplaceCtrl.text.trim(),
          "dob": _dob?.toIso8601String(),
        };

      case 'shop owner':
        return {
          "name": _nameCtrl.text.trim(),
          "email": email,
          "mobile": _mobileCtrl.text.trim(),
          "shop_name": _shopNameCtrl.text.trim(),
          "dob": _dob?.toIso8601String(),
        };

      default:
        return {
          "name": _nameCtrl.text.trim(),
          "email": email,
          "mobile": _mobileCtrl.text.trim(),
          "dob": _dob?.toIso8601String(),
        };
    }
  }

  void _snack(String msg, {bool err = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: err ? AppColors.danger : AppColors.brandForest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(logo, height: 95),
                const SizedBox(height: 12),
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Registering as: ",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : AppColors.mutedText,
                      ),
                    ),
                    StatusPill(
                      label: _selectedRole,
                      variant: StatusPillVariant.sage,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _field(_nameCtrl, "Full Name", Icons.person_outline),
                _field(_emailCtrl, "Email Address", Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                ..._roleSpecificFields(),
                const SizedBox(height: 12),

                // Submit Button
                BrandButton(
                  text: "Create Account",
                  isLoading: loading,
                  icon: Icons.person_add_outlined,
                  isFullWidth: true,
                  onPressed: loading ? null : _signup,
                ),
                const SizedBox(height: 20),

                // Link to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: isDark ? Colors.white60 : AppColors.mutedText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LoginPage(selectedRole: _selectedRole),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: AppColors.brandGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _roleSpecificFields() {
    switch (_selectedRole.toLowerCase().trim()) {
      case 'patient':
        return [
          _field(_mobileCtrl, "Mobile Number", Icons.phone_outlined,
              keyboardType: TextInputType.phone),
          _dropdownGender(),
          _dropdownBloodGroup(),
          _dobField(),
          _passwordFields(),
        ];

      case 'doctor':
        return [
          _field(_mobileCtrl, "Mobile Number", Icons.phone_outlined,
              keyboardType: TextInputType.phone),
          _field(_specialistCtrl, "Medical Specialty", Icons.healing_outlined),
          _field(_licenceCtrl, "BMDC Licence Number", Icons.badge_outlined),
          _field(_workplaceCtrl, "Hospital / Clinic Workplace", Icons.work_outline),
          _dobField(),
          _passwordFields(),
        ];

      case 'pharmacist':
        return [
          _field(_mobileCtrl, "Mobile Number", Icons.phone_outlined,
              keyboardType: TextInputType.phone),
          _field(_workplaceCtrl, "Pharmacy / Hospital Workplace", Icons.store_outlined),
          _dobField(),
          _passwordFields(),
        ];

      case 'shop owner':
        return [
          _field(_mobileCtrl, "Mobile Number", Icons.phone_outlined,
              keyboardType: TextInputType.phone),
          _field(_shopNameCtrl, "Shop / Enterprise Name", Icons.storefront_outlined),
          _dobField(),
          _passwordFields(),
        ];

      default:
        return [_passwordFields()];
    }
  }

  Widget _passwordFields() {
    return Column(
      children: [
        _field(
          _passwordCtrl,
          "Password",
          Icons.lock_outline,
          obscure: _obscurePassword,
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
        ),
        _field(
          _confirmPassCtrl,
          "Confirm Password",
          Icons.lock_outline,
          obscure: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword);
            },
          ),
        ),
      ],
    );
  }

  Widget _dobField() {
    final dateText = _dob == null
        ? ""
        : "${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: _pickDOB,
        child: AbsorbPointer(
          child: TextFormField(
            controller: TextEditingController(text: dateText),
            decoration: InputDecoration(
              labelText: "Date of Birth",
              hintText: "Select your date of birth",
              prefixIcon: const Icon(Icons.calendar_today_outlined),
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
        ),
      ),
    );
  }

  Future<void> _pickDOB() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Widget _dropdownGender() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Gender",
          prefixIcon: const Icon(Icons.people_outline),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        initialValue: _gender,
        hint: const Text("Select Gender"),
        items: genders
            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
            .toList(),
        onChanged: (v) => setState(() => _gender = v),
      ),
    );
  }

  Widget _dropdownBloodGroup() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Blood Group",
          prefixIcon: const Icon(Icons.bloodtype_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        initialValue: _bloodGroup,
        hint: const Text("Select Blood Group"),
        items: bloodGroups
            .map((b) => DropdownMenuItem(value: b, child: Text(b)))
            .toList(),
        onChanged: (v) => setState(() => _bloodGroup = v),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
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
    );
  }
}
