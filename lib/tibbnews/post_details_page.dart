// ----------------------------------------------------
// lib/tibbnews/post_details_page.dart (FINAL FIXED)
// ----------------------------------------------------

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sevices/supabase_services.dart';
import 'comments_sheet.dart';

class PostDetailsPage extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostDetailsPage({super.key, required this.post});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  late Map<String, dynamic> post;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    _subscribe();
  }

  void _subscribe() {
    final id = post['id'].toString();
    final channel = Supabase.instance.client.channel("public:post_details_$id");

    void reload() async {
      final updated = await Supabase.instance.client
          .from("posts")
          .select('''
            id, content, created_at, user_id,

            profiles:user_id(
              id, name, avatar_url, role, is_verified
            ),

            post_images(storage_path),
            post_likes(id,user_id),
            comments(id,user_id)
          ''')
          .eq("id", id)
          .maybeSingle();

      if (updated != null && mounted) {
        setState(() => post = updated);
      }
    }

    for (final t in [
      "posts",
      "post_images",
      "post_likes",
      "comments",
      "profiles", // FIXED
    ]) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: "public",
        table: t,
        callback: (_) => reload(),
      );
    }

    channel.subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final u = post['profiles'] ?? post['users'] ?? {};
    final images = post['post_images'] ?? [];

    final name = u['name'] ?? "User";
    final avatar = u['avatar_url'];
    final role = u['role'] ?? "";
    final verified = (u['is_verified'] == true) || role == "admin";

    String display = name;
    if (role == "admin") display = "Admin";
    if (role == "doctor" && !display.startsWith("Dr.")) {
      display = "Dr. $display";
    }

    final liked =
        (post['post_likes'] as List?)?.any(
          (e) => e['user_id'] == Supabase.instance.client.auth.currentUser?.id,
        ) ??
        false;

    return Scaffold(
      appBar: AppBar(title: const Text("Post Details")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: (avatar != null && avatar.isNotEmpty)
                    ? NetworkImage(avatar)
                    : const AssetImage("assets/image/pic.png") as ImageProvider,
              ),
              const SizedBox(width: 12),
              Text(
                display,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (verified)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.verified, color: Colors.blue, size: 20),
                ),
            ],
          ),

          const SizedBox(height: 16),

          Text(post['content'] ?? "", style: const TextStyle(fontSize: 16)),

          const SizedBox(height: 12),

          for (var img in images)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Image.network(img['storage_path']),
            ),

          Row(
            children: [
              IconButton(
                onPressed: () async {
                  final u = Supabase.instance.client.auth.currentUser;
                  if (u != null) {
                    await SupabaseService.toggleLike(
                      postId: post['id'].toString(),
                      userId: u.id,
                    );
                  }
                },
                icon: Icon(
                  liked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                  color: liked ? Colors.blue : null,
                ),
              ),
              Text("${post['post_likes']?.length ?? 0}"),

              const SizedBox(width: 18),

              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => CommentsSheet(
                      postId: post['id'].toString(),
                      currentUserId:
                          Supabase.instance.client.auth.currentUser?.id,
                    ),
                  );
                },
                icon: const Icon(Icons.comment_outlined),
              ),
              Text("${post['comments']?.length ?? 0}"),
            ],
          ),
        ],
      ),
    );
  }
}
