import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/homepage.dart';
import '../sevices/supabase_auth_hepler.dart';
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
  late String _selectedRole;

  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final List<String> genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.role;
  }

  bool get isAdminSignupAttempt =>
      _selectedRole.toLowerCase().trim() == "admin";

  String getTableName() {
    switch (_selectedRole.toLowerCase()) {
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

  // --------------------------- FINAL SIGNUP LOGIC ---------------------------
  Future<void> _signup() async {
    if (isAdminSignupAttempt) {
      _snack("You cannot create an admin account manually!", err: true);
      return;
    }

    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      _snack("Please fill all required fields", err: true);
      return;
    }

    if (password != _confirmPassCtrl.text.trim()) {
      _snack("Passwords do not match", err: true);
      return;
    }

    setState(() => loading = true);

    try {
      // 1. Supabase Auth user create
      final authRes = await authService.signUp(email, password);

      if (authRes.user == null) throw "Signup failed.";

      final uid = authRes.user!.id;
      final emailVerified = authRes.user!.emailConfirmedAt != null;

      // Doctor prefix
      final finalName = _selectedRole.toLowerCase() == "doctor"
          ? "Dr. $name"
          : name;

      // Fix shop owner naming
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

      // 3. Insert into role table
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

      _snack("Signup Successful!", color: Colors.green);

      if (!mounted) return;

      // 5. GO TO HOME
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      _snack("Signup failed: $e", err: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // -------------------- ROLE SPECIFIC FIELD DATA --------------------
  Map<String, dynamic> _buildRoleData(String email) {
    switch (_selectedRole.toLowerCase()) {
      case 'patient':
        return {
          "name": _nameCtrl.text,
          "email": email,
          "mobile": _mobileCtrl.text,
          "gender": _gender,
          "dob": _dob?.toIso8601String(),
          "blood_group": _bloodGroup,
        };

      case 'doctor':
        return {
          "name": _nameCtrl.text,
          "email": email,
          "mobile": _mobileCtrl.text,
          "specialist": _specialistCtrl.text,
          "licence": _licenceCtrl.text,
          "workplace": _workplaceCtrl.text,
          "dob": _dob?.toIso8601String(),
        };

      case 'pharmacist':
        return {
          "name": _nameCtrl.text,
          "email": email,
          "mobile": _mobileCtrl.text,
          "workplace": _workplaceCtrl.text,
          "dob": _dob?.toIso8601String(),
        };

      case 'shop owner':
        return {
          "name": _nameCtrl.text,
          "email": email,
          "mobile": _mobileCtrl.text,
          "shop_name": _shopNameCtrl.text,
          "dob": _dob?.toIso8601String(),
        };

      default:
        return {
          "name": _nameCtrl.text,
          "email": email,
          "mobile": _mobileCtrl.text,
          "dob": _dob?.toIso8601String(),
        };
    }
  }

  // --------------------------- UI ---------------------------
  void _snack(String msg, {bool err = false, Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color ?? (err ? Colors.red : Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _topHeader(),
            Expanded(child: _formSection()),
          ],
        ),
      ),
    );
  }

  Widget _topHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final logo = isDark
        ? 'assets/image/logo_dark1.png'
        : 'assets/image/logo_light1.png';

    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _SignUpCurvePainter(isDark)),
          ),

          // ---- Logo at top center ----
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Image.asset(logo, height: 130),
            ),
          ),

          // ---- Page title ----
          Positioned(
            left: 20,
            bottom: 10,
            child: Text(
              "Sign up as $_selectedRole",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _field(_nameCtrl, "Name", Icons.person),
            _field(_emailCtrl, "Email", Icons.email),
            ..._roleSpecificFields(),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: loading ? null : _signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
            ),

            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginPage(selectedRole: _selectedRole),
                  ),
                );
              },
              child: const Text(
                "Already have an account? Login",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _roleSpecificFields() {
    switch (_selectedRole.toLowerCase()) {
      case 'patient':
        return [
          _field(_mobileCtrl, "Mobile", Icons.phone),
          _dropdownGender(),
          _dropdownBloodGroup(),
          _dobField(),
          _passwordFields(),
        ];

      case 'doctor':
        return [
          _field(_mobileCtrl, "Mobile", Icons.phone),
          _field(_specialistCtrl, "Specialist", Icons.healing),
          _field(_licenceCtrl, "Licence No", Icons.badge),
          _field(_workplaceCtrl, "Workplace", Icons.work),
          _dobField(),
          _passwordFields(),
        ];

      case 'pharmacist':
        return [
          _field(_mobileCtrl, "Mobile", Icons.phone),
          _field(_workplaceCtrl, "Workplace", Icons.store),
          _dobField(),
          _passwordFields(),
        ];

      case 'shop owner':
        return [
          _field(_mobileCtrl, "Mobile", Icons.phone),
          _field(_shopNameCtrl, "Shop Name", Icons.storefront),
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
        _field(_passwordCtrl, "Password", Icons.lock),
        _field(_confirmPassCtrl, "Confirm Password", Icons.lock),
      ],
    );
  }

  Widget _dobField() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _pickDOB,
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(
                      text: _dob == null
                          ? ""
                          : _dob!.toLocal().toString().split(" ")[0],
                    ),
                    decoration: const InputDecoration(
                      labelText: "Date of Birth",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
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
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.people),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                initialValue: _gender,
                hint: const Text("Select Gender"),
                items: genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _dropdownBloodGroup() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.bloodtype),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                initialValue: _bloodGroup,
                hint: const Text("Select Blood Group"),
                items: bloodGroups
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) => setState(() => _bloodGroup = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: c,
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ----------------------- Curve Design -----------------------
class _SignUpCurvePainter extends CustomPainter {
  final bool isDark;

  _SignUpCurvePainter(this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white70 : Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path();
    path.moveTo(0, size.height * 0.85);

    path.cubicTo(
      size.width * 0.3,
      size.height * 0.8,
      size.width * 0.6,
      size.height * 0.4,
      size.width,
      size.height * 0.45,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
