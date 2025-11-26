// lib/tibbnews/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sevices/supabase_services.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> initialData;
  const EditProfilePage({super.key, required this.initialData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _bloodCtrl;
  late TextEditingController _lastDonateCtrl;
  late TextEditingController _healthCtrl;
  late TextEditingController _homeCtrl;
  late TextEditingController _officeCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _emergencyCtrl;
  late TextEditingController _notesCtrl;

  PlatformFile? _pickedImage;
  String? _initialAvatar;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameCtrl = TextEditingController(text: data['name'] ?? '');
    _bioCtrl = TextEditingController(text: data['bio'] ?? '');
    _mobileCtrl = TextEditingController(
      text: data['mobile'] ?? data['contact'] ?? '',
    );
    _bloodCtrl = TextEditingController(text: data['blood_group'] ?? '');
    _lastDonateCtrl = TextEditingController(
      text: data['last_donate_date'] ?? '',
    );
    _healthCtrl = TextEditingController(text: data['health_condition'] ?? '');
    _homeCtrl = TextEditingController(text: data['home_address'] ?? '');
    _officeCtrl = TextEditingController(text: data['office_address'] ?? '');
    _dobCtrl = TextEditingController(text: data['dob'] ?? '');
    _emergencyCtrl = TextEditingController(
      text: data['emergency_contact'] ?? '',
    );
    _notesCtrl = TextEditingController(text: data['notes'] ?? '');
    _initialAvatar = (data['avatar_url'] ?? data['profile_picture'] ?? '')
        .toString();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _mobileCtrl.dispose();
    _bloodCtrl.dispose();
    _lastDonateCtrl.dispose();
    _healthCtrl.dispose();
    _homeCtrl.dispose();
    _officeCtrl.dispose();
    _dobCtrl.dispose();
    _emergencyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() => _pickedImage = res.files.first);
    }
  }

  Future<void> _save() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login required')));
      return;
    }

    setState(() => _loading = true);
    try {
      String? avatarUrl = _initialAvatar;
      if (_pickedImage != null) {
        final url = await SupabaseService.uploadProfilePicture(
          _pickedImage!,
          uid,
        );
        if (url != null) avatarUrl = url;
      }

      // call your service (already present in your codebase)
      final ok = await SupabaseService.updateProfileFull(
        userId: uid,
        name: _nameCtrl.text.trim(),
        contactNumber: _mobileCtrl.text.trim(),
        bloodGroup: _bloodCtrl.text.trim(),
        lastDonateDate: _lastDonateCtrl.text.trim(),
        healthCondition: _healthCtrl.text.trim(),
        homeAddress: _homeCtrl.text.trim(),
        officeAddress: _officeCtrl.text.trim(),
        dob: _dobCtrl.text.trim(),
        emergencyContact: _emergencyCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
        avatarUrl: avatarUrl,
      );

      if (ok == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile saved')));
        Navigator.pop(context, true);
      } else {
        throw 'Save failed';
      }
    } catch (e) {
      debugPrint("Save profile error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _field(TextEditingController c, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _pickedImage != null
        ? Image.memory(_pickedImage!.bytes!, fit: BoxFit.cover).image
        : (_initialAvatar != null && _initialAvatar!.isNotEmpty
              ? NetworkImage(_initialAvatar!)
              : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundImage: avatar,
                    child: avatar == null
                        ? const Icon(Icons.person, size: 54)
                        : null,
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _field(_nameCtrl, 'Name'),
            _field(_bioCtrl, 'Bio', maxLines: 2),
            _field(_mobileCtrl, 'Contact Number'),
            _field(_bloodCtrl, 'Blood Group'),
            _field(_lastDonateCtrl, 'Last Donate Date (YYYY-MM-DD)'),
            _field(_healthCtrl, 'Health Condition', maxLines: 3),
            _field(_homeCtrl, 'Home Address'),
            _field(_officeCtrl, 'Office Address'),
            _field(_dobCtrl, 'Date of Birth (YYYY-MM-DD)'),
            _field(_emergencyCtrl, 'Emergency Contact'),
            _field(_notesCtrl, 'Notes', maxLines: 3),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
