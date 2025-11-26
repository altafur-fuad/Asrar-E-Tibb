// lib/pages/profile_settings_page.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_themes.dart';

// adjust these imports to match your project paths
import '../sevices/supabase_auth_hepler.dart';
import '../sevices/supabase_services.dart';
import 'package:asrarpages/identity_login_signup/identityscreen.dart';

class ProfileSettingsPage extends StatefulWidget {
  final Map<String, dynamic>? profile;
  const ProfileSettingsPage({super.key, this.profile});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameC;
  late TextEditingController emailC;
  late TextEditingController mobileC;
  late TextEditingController bloodC;
  late TextEditingController lastDonateC;
  late TextEditingController homeC;
  late TextEditingController officeC;
  late TextEditingController dobC;
  late TextEditingController emergencyC;
  late TextEditingController notesC;

  PlatformFile? pickedFile; // file picked from FilePicker
  String? avatarUrl; // existing or uploaded url
  bool saving = false;
  String? userId;

  final _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    final p = widget.profile ?? <String, dynamic>{};

    nameC = TextEditingController(text: p['name'] ?? p['full_name'] ?? '');
    emailC = TextEditingController(
      text: p['email'] ?? _client.auth.currentUser?.email ?? '',
    );
    mobileC = TextEditingController(text: p['mobile'] ?? p['contact'] ?? '');
    bloodC = TextEditingController(text: p['blood_group'] ?? '');
    lastDonateC = TextEditingController(text: p['last_donate'] ?? '');
    homeC = TextEditingController(text: p['home_address'] ?? '');
    officeC = TextEditingController(text: p['office_address'] ?? '');
    dobC = TextEditingController(text: p['dob'] ?? '');
    emergencyC = TextEditingController(text: p['emergency_contact'] ?? '');
    notesC = TextEditingController(text: p['notes'] ?? '');
    avatarUrl = p['avatar_url'] as String?;

    userId =
        SupabaseAuthService().currentSession?.user.id ??
        _client.auth.currentUser?.id;
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    mobileC.dispose();
    bloodC.dispose();
    lastDonateC.dispose();
    homeC.dispose();
    officeC.dispose();
    dobC.dispose();
    emergencyC.dispose();
    notesC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() {
        pickedFile = res.files.first;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not found.')));
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      String? uploadedUrl = avatarUrl;

      // If user picked a new image, upload it
      if (pickedFile != null) {
        final url = await SupabaseService.uploadProfilePicture(
          pickedFile!,
          userId!,
        );
        if (url != null && url.isNotEmpty) {
          uploadedUrl = url;
        } else {
          // upload failed — show message but still try to save other fields
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image upload failed (continuing).'),
            ),
          );
        }
      }

      final ok = await SupabaseService.updateProfileFull(
        userId: userId!,
        name: nameC.text.trim(),
        contactNumber: mobileC.text.trim(),
        bloodGroup: bloodC.text.trim(),
        lastDonateDate: lastDonateC.text.trim(),
        healthCondition: notesC.text.trim(), // optionally map differently
        homeAddress: homeC.text.trim(),
        officeAddress: officeC.text.trim(),
        dob: dobC.text.trim(),
        emergencyContact: emergencyC.text.trim(),
        notes: notesC.text.trim(),
        avatarUrl: uploadedUrl,
      );

      if (ok) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
        Navigator.pop(
          context,
          true,
        ); // return to previous screen and indicate success
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Update failed.')));
      }
    } catch (e) {
      debugPrint('save profile error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => saving = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await SupabaseAuthService().signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const IdentitySelectionScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  Future<void> _deleteAccountPlaceholder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Account'),
        content: const Text(
          'Permanently delete account? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show placeholder — implement actual DB + auth deletion as needed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account deletion not implemented.')),
    );
  }

  Widget _avatarPreview() {
    if (pickedFile != null) {
      return CircleAvatar(
        radius: 48,
        backgroundImage: MemoryImage(pickedFile!.bytes!),
      );
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 48,
        backgroundImage: NetworkImage(avatarUrl!),
      );
    } else {
      return const CircleAvatar(
        radius: 48,
        child: Icon(Icons.person, size: 40),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: AppThemes.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _avatarPreview(),
                    InkWell(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.edit,
                          color: AppThemes.primaryBlue,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Name
              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Email (readonly)
              TextFormField(
                controller: emailC,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 12),

              // Contact
              TextFormField(
                controller: mobileC,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Blood group, last donate
              TextFormField(
                controller: bloodC,
                decoration: const InputDecoration(
                  labelText: 'Blood Group',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: lastDonateC,
                decoration: const InputDecoration(
                  labelText: 'Last Donate Date',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Home / Office
              TextFormField(
                controller: homeC,
                decoration: const InputDecoration(
                  labelText: 'Home Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: officeC,
                decoration: const InputDecoration(
                  labelText: 'Office Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // DOB / Emergency
              TextFormField(
                controller: dobC,
                decoration: const InputDecoration(
                  labelText: 'DOB',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emergencyC,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Notes / Health condition
              TextFormField(
                controller: notesC,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes / Health Condition',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: saving ? null : _saveProfile,
                  icon: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ),

              const SizedBox(height: 12),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.orange),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.orange),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Delete account (placeholder)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _deleteAccountPlaceholder,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete Account'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
