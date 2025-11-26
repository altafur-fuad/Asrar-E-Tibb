// lib/tibbnews/edit_post_page.dart

import 'package:asrarpages/sevices/supabase_services.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPostPage extends StatefulWidget {
  final Map<String, dynamic> post;
  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final TextEditingController _ctrl = TextEditingController();
  List<PlatformFile> _picked = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.post['content'] ?? '';
  }

  Future<void> _pickImages() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true,
    );
    if (res != null) {
      setState(() => _picked = res.files);
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'Login required';

      // Upload selected images
      List<String> urls = [];
      for (final f in _picked) {
        if (f.bytes == null) continue;

        final url = await SupabaseService.uploadPostImage(f);
        if (url != null) urls.add(url);
      }

      // Save post changes
      final ok = await SupabaseService.editPost(
        postId: widget.post['id'].toString(),
        userId: user.id,
        content: _ctrl.text.trim(),
        imageUrls: urls.isEmpty ? null : urls,
      );

      if (ok) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        throw "Save failed";
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              maxLines: 6,
              decoration: const InputDecoration(hintText: 'Write...'),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.photo),
                  label: const Text('Change Images'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => setState(() => _picked.clear()),
                  child: const Text('Clear Selected'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (_picked.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _picked.length,
                  itemBuilder: (_, i) {
                    final f = _picked[i];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.memory(
                        f.bytes!,
                        width: 120,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
