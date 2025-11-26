// ----------------------------------------------------
// lib/tibbnews/post_card.dart (FINAL VERSION WITH TRUNCATE)
// ----------------------------------------------------

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sevices/supabase_services.dart';
import 'comments_sheet.dart';
import 'edit_post_page.dart';
import 'post_details_page.dart';
import 'user_profile_page.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Map<String, dynamic> post;
  bool liked = false;
  int likes = 0;
  int comments = 0;
  bool isOwn = false;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    post = widget.post;

    likes = post['likes_count'] ?? 0;
    comments = post['comments_count'] ?? 0;

    _prepare();
  }

  Future<void> _prepare() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final postUser = post['user_id']?.toString() ?? "";
    isOwn = postUser == user.id;

    final likedBefore = await Supabase.instance.client
        .from("post_likes")
        .select()
        .eq("post_id", post['id'].toString())
        .eq("user_id", user.id)
        .maybeSingle();

    liked = likedBefore != null;

    isAdmin = await SupabaseService.isAdmin(user.id);

    if (mounted) setState(() {});
  }

  Future<void> _toggleLike() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await SupabaseService.toggleLike(
      postId: post['id'].toString(),
      userId: user.id,
    );

    likes = await SupabaseService.getLikeCount(post['id'].toString());
    liked = !liked;

    if (mounted) setState(() {});
  }

  // ---------------- SHORT TEXT (20–30 WORDS) ----------------
  String _shortText(String text, {int wordLimit = 25}) {
    final words = text.split(" ");
    if (words.length <= wordLimit) return text;
    return "${words.take(wordLimit).join(" ")} ...";
  }

  String _timeAgo(String? t) {
    if (t == null) return "";
    final dt = DateTime.tryParse(t);
    if (dt == null) return "";

    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 60) return "Just now";
    if (d.inMinutes < 60) return "${d.inMinutes}m ago";
    if (d.inHours < 24) return "${d.inHours}h ago";
    if (d.inDays < 7) return "${d.inDays}d ago";

    return "${dt.day}/${dt.month}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final u = post['users'] ?? {};
    final name = u['name'] ?? "User";
    final avatar = u['avatar_url'];
    final role = u['role'] ?? "";
    final verified = (u['is_verified'] == true) || role == "admin";

    String display = name;

    if (role == "doctor" && !display.startsWith("Dr.")) {
      display = "Dr. $display";
    }

    final List images = post['post_images'] ?? [];

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- HEADER ----------------
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        UserProfilePage(userId: post['user_id'].toString()),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: (avatar != null && avatar.isNotEmpty)
                    ? NetworkImage(avatar)
                    : const AssetImage("assets/image/pic.png") as ImageProvider,
                child: role == "admin"
                    ? const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),

            title: Row(
              children: [
                Expanded(
                  child: Text(
                    display,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (verified)
                  const Icon(Icons.verified, color: Colors.blue, size: 18),
              ],
            ),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (role == "admin")
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(top: 4, bottom: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "Admin",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                Text(
                  _timeAgo(post['created_at']),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),

            trailing: (isOwn || isAdmin)
                ? PopupMenuButton(
                    itemBuilder: (_) => [
                      if (isOwn)
                        const PopupMenuItem(value: "edit", child: Text("Edit")),
                      if (isOwn)
                        const PopupMenuItem(
                          value: "delete",
                          child: Text("Delete"),
                        ),
                      if (isAdmin && !isOwn)
                        const PopupMenuItem(
                          value: "admin_delete",
                          child: Text("Delete (Admin)"),
                        ),
                    ],
                    onSelected: (value) {
                      if (value == "edit") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditPostPage(post: post),
                          ),
                        );
                      } else if (value == "delete") {
                        SupabaseService.deleteOwnPost(
                          postId: post['id'].toString(),
                          userId: Supabase.instance.client.auth.currentUser!.id,
                        );
                      } else if (value == "admin_delete") {
                        SupabaseService.adminDeletePost(post['id'].toString());
                      }
                    },
                  )
                : null,
          ),

          // ---------------- SHORT CONTENT (20–30 words) ----------------
          if ((post['content'] ?? "").isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _shortText(post['content'], wordLimit: 25), // 20–30 words only
                style: const TextStyle(fontSize: 15),
              ),
            ),

          // ---------------- IMAGES ----------------
          if (images.isNotEmpty)
            SizedBox(
              height: 280,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (_, i) {
                  final url = images[i]['storage_path'];
                  return Image.network(url, fit: BoxFit.cover);
                },
              ),
            ),

          // ---------------- ACTIONS ----------------
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggleLike,
                  icon: Icon(
                    liked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                    color: liked ? Colors.blue : null,
                  ),
                ),
                Text("$likes"),
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
                Text("$comments"),

                const Spacer(),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailsPage(post: post),
                      ),
                    );
                  },
                  child: const Text("View Details"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
