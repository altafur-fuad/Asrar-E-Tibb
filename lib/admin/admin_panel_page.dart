// ------------------------------------------------------------
// admin_panel_page.dart  (FULL MERGED & FIXED VERSION)
// ------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_themes.dart';
import '../theme_controller.dart';
import '../tibbnews/post_details_page.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final _supabase = Supabase.instance.client;

  bool _loading = true;
  String _searchQuery = "";

  // DATA SOURCES
  Map<String, dynamic> _analytics = {};
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _comments = [];

  RealtimeChannel? _channel;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initRealtime();
    _loadAll();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    try {
      _channel?.unsubscribe();
    } catch (_) {}
    super.dispose();
  }

  // ----------------------------------------------------------
  // REALTIME SUBSCRIPTION
  // ----------------------------------------------------------
  void _initRealtime() {
    try {
      _channel = _supabase.channel("public:admin-panel");

      const watch = [
        "users",
        "profiles",
        "posts",
        "post_images",
        "post_likes",
        "comments",
      ];

      for (final t in watch) {
        _channel!.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: "public",
          table: t,
          callback: (_) => _loadAll(),
        );
      }

      _channel!.subscribe();
    } catch (e) {
      debugPrint("Realtime ERROR: $e");
    }
  }

  // ----------------------------------------------------------
  // LOAD EVERYTHING
  // ----------------------------------------------------------
  Future<void> _loadAll() async {
    setState(() => _loading = true);

    try {
      await Future.wait([
        _loadAnalytics(),
        _loadUsers(),
        _loadPosts(),
        _loadComments(),
      ]);
    } catch (e) {
      debugPrint("LOAD ALL ERROR: $e");
    }

    if (mounted) setState(() => _loading = false);
  }

  // ----------------------------------------------------------
  // LOAD ANALYTICS
  // ----------------------------------------------------------
  Future<void> _loadAnalytics() async {
    try {
      final users = await _supabase.from("users").select("id");
      final posts = await _supabase.from("posts").select("id");
      final comments = await _supabase.from("comments").select("id");
      final likes = await _supabase.from("post_likes").select("id");
      final admins = await _supabase
          .from("users")
          .select("id")
          .eq("is_admin", true);

      if (!mounted) return;

      _analytics = {
        "total_users": users.length,
        "total_posts": posts.length,
        "total_comments": comments.length,
        "total_likes": likes.length,
        "total_admins": admins.length,
      };
    } catch (e) {
      debugPrint("Analytics ERR: $e");
    }
  }

  // ----------------------------------------------------------
  // LOAD USERS
  // ----------------------------------------------------------
  Future<void> _loadUsers() async {
    try {
      final usersRes = await _supabase
          .from("users")
          .select()
          .order("created_at");
      final profilesRes = await _supabase.from("profiles").select();

      final profilesById = {for (var p in profilesRes) p["id"].toString(): p};

      final merged = usersRes.map<Map<String, dynamic>>((u) {
        final profile = profilesById[u["id"]] ?? {};
        return {
          ...u,
          "display_name":
              profile["name"] ?? u["name"] ?? u["email"] ?? "Unknown",
          "avatar_url": profile["avatar_url"] ?? "",
          "is_verified": profile["is_verified"] ?? u["verified"] ?? false,
          "profile": profile,
        };
      }).toList();

      final filtered = _searchQuery.isEmpty
          ? merged
          : merged.where((u) {
              final q = _searchQuery.toLowerCase();
              return (u["display_name"] ?? "")
                      .toString()
                      .toLowerCase()
                      .contains(q) ||
                  (u["email"] ?? "").toString().toLowerCase().contains(q) ||
                  (u["role"] ?? "").toString().toLowerCase().contains(q);
            }).toList();

      if (mounted) _users = filtered;
    } catch (e) {
      debugPrint("Users ERR: $e");
      if (mounted) _users = [];
    }
  }

  // ----------------------------------------------------------
  // LOAD POSTS
  // ----------------------------------------------------------
  Future<void> _loadPosts() async {
    try {
      final res = await _supabase
          .from("posts")
          .select("""
              *,
              post_images(storage_path),
              profiles:user_id(id,name,avatar_url,role,is_verified)
            """)
          .order("created_at", ascending: false);

      final posts = List<Map<String, dynamic>>.from(res);

      for (var p in posts) {
        final imgs = p["post_images"] as List?;
        p["preview"] = imgs != null && imgs.isNotEmpty
            ? imgs[0]["storage_path"]
            : "";
      }

      if (mounted) _posts = posts;
    } catch (e) {
      debugPrint("Posts ERR: $e");
      if (mounted) _posts = [];
    }
  }

  // ----------------------------------------------------------
  // LOAD COMMENTS
  // ----------------------------------------------------------
  Future<void> _loadComments() async {
    try {
      final res = await _supabase
          .from("comments")
          .select("""
            *,
            profiles:user_id(id,name,avatar_url,role,is_verified),
            posts:post_id(id,content)
          """)
          .order("created_at", ascending: false);

      if (mounted) _comments = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Comments ERR: $e");
      if (mounted) _comments = [];
    }
  }

  // ----------------------------------------------------------
  // DELETE POST
  // ----------------------------------------------------------
  Future<bool> _deletePost(String id) async {
    try {
      await _supabase.from("post_images").delete().eq("post_id", id);
      await _supabase.from("post_likes").delete().eq("post_id", id);
      await _supabase.from("comments").delete().eq("post_id", id);
      await _supabase.from("posts").delete().eq("id", id);
      await _loadPosts();
      return true;
    } catch (e) {
      debugPrint("DeletePost ERR: $e");
      return false;
    }
  }

  // ----------------------------------------------------------
  // DELETE COMMENT
  // ----------------------------------------------------------
  Future<bool> _deleteComment(String id) async {
    try {
      await _supabase.from("comments").delete().eq("id", id);
      await _loadComments();
      return true;
    } catch (e) {
      debugPrint("DeleteComment ERR: $e");
      return false;
    }
  }

  // ----------------------------------------------------------
  // UI WIDGETS — POSTS
  // ----------------------------------------------------------
  Widget _postTile(Map<String, dynamic> p) {
    final user = p["profiles"] ?? {};
    final verified = user["is_verified"] == true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: p["preview"] != ""
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  p["preview"],
                  width: 55,
                  height: 55,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.article, size: 48),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user["name"] ?? "User",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (verified)
              const Icon(Icons.verified, color: Colors.blue, size: 16),
          ],
        ),
        subtitle: Text(
          p["content"] != null && p["content"].length > 70
              ? p["content"].substring(0, 70) + "..."
              : p["content"] ?? "",
        ),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(value: "view", child: Text("View")),
            const PopupMenuItem(
              value: "delete",
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
          onSelected: (v) async {
            if (v == "view") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PostDetailsPage(post: p)),
              );
            } else if (v == "delete") {
              final ok = await _deletePost(p["id"].toString());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? "Post deleted" : "Failed to delete"),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // UI WIDGETS — COMMENTS
  // ----------------------------------------------------------
  Widget _commentTile(Map<String, dynamic> c) {
    final user = c["profiles"] ?? {};

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: (user["avatar_url"] ?? "") != ""
              ? NetworkImage(user["avatar_url"])
              : null,
          child: (user["avatar_url"] ?? "") == ""
              ? Text((user["name"] ?? "U")[0])
              : null,
        ),
        title: Text(
          "${user["name"] ?? "User"} • ${user["role"] ?? ''}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c["content"] ?? ""),
            if (c["posts"] != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "Post: ${c["posts"]["content"]}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: "delete",
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
          onSelected: (v) async {
            if (v == "delete") {
              final ok = await _deleteComment(c["id"].toString());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ok ? "Comment deleted" : "Failed")),
              );
            }
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // UI — TABS
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  // BEAUTIFUL ANALYTICS TAB (Premium Dashboard Style)
  // ----------------------------------------------------------
  Widget _analyticsTab(BuildContext context) {
    final theme = Theme.of(context);

    Widget statCard({
      required String title,
      required String value,
      required IconData icon,
      required Color color,
    }) {
      return Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodyMedium!.color!.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Analytics Dashboard",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          // GRID CARDS
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            children: [
              statCard(
                title: "Total Users",
                value: "${_analytics['total_users'] ?? 0}",
                icon: Icons.people_alt,
                color: Colors.blueAccent,
              ),
              statCard(
                title: "Total Posts",
                value: "${_analytics['total_posts'] ?? 0}",
                icon: Icons.post_add,
                color: Colors.greenAccent.shade700,
              ),
              statCard(
                title: "Total Comments",
                value: "${_analytics['total_comments'] ?? 0}",
                icon: Icons.comment,
                color: Colors.orangeAccent.shade700,
              ),
              statCard(
                title: "Total Likes",
                value: "${_analytics['total_likes'] ?? 0}",
                icon: Icons.thumb_up_alt,
                color: Colors.pinkAccent,
              ),
            ],
          ),

          // ADMIN INFO CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.teal.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 40,
                  color: Colors.teal,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Admins", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      "${_analytics['total_admins'] ?? 0}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _stat(String title, dynamic num, IconData i) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(i, color: Colors.blue),
        title: Text(title),
        trailing: Text(
          num.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _usersTab(BuildContext ctx) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Search users...",
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 350), () {
                setState(() => _searchQuery = v);
                _loadUsers();
              });
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadUsers,
            child: ListView(children: _users.map((u) => _userTile(u)).toList()),
          ),
        ),
      ],
    );
  }

  Widget _userTile(Map<String, dynamic> u) {
    final verified = u["is_verified"] == true || u["is_admin"] == true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: u["avatar_url"] != ""
              ? NetworkImage(u["avatar_url"])
              : null,
          child: u["avatar_url"] == ""
              ? Text((u["display_name"] ?? "U")[0])
              : null,
        ),
        title: Row(
          children: [
            Expanded(child: Text(u["display_name"])),
            if (verified)
              const Icon(Icons.verified, color: Colors.blue, size: 16),
          ],
        ),
        subtitle: Text("${u["role"]} • ${u["email"]}"),
      ),
    );
  }

  Widget _postsTab() {
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView(children: _posts.map(_postTile).toList()),
    );
  }

  Widget _commentsTab() {
    return RefreshIndicator(
      onRefresh: _loadComments,
      child: ListView(children: _comments.map(_commentTile).toList()),
    );
  }

  // ----------------------------------------------------------
  // MAIN UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final themeCtrl = Provider.of<ThemeController?>(context);
    final isDark = themeCtrl?.isDark ?? false;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Panel"),
          backgroundColor: isDark
              ? AppThemes.dark.appBarTheme.backgroundColor
              : AppThemes.light.appBarTheme.backgroundColor,
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => themeCtrl!.toggleTheme(!isDark),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Analytics", icon: Icon(Icons.dashboard)),
              Tab(text: "Users", icon: Icon(Icons.people)),
              Tab(text: "Posts", icon: Icon(Icons.article)),
              Tab(text: "Comments", icon: Icon(Icons.comment)),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _analyticsTab(context),
                  _usersTab(context),
                  _postsTab(),
                  _commentsTab(),
                ],
              ),
      ),
    );
  }
}

// ------------------------------------------------------------
// USER DETAILS PAGE
// ------------------------------------------------------------
class AdminUserDetails extends StatelessWidget {
  final Map<String, dynamic> user;
  const AdminUserDetails({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Provider.of<ThemeController?>(context);
    final isDark = themeCtrl?.isDark ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details"),
        backgroundColor: isDark
            ? AppThemes.dark.appBarTheme.backgroundColor
            : AppThemes.light.appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: user["avatar_url"] != ""
                  ? NetworkImage(user["avatar_url"])
                  : null,
              child: user["avatar_url"] == ""
                  ? Text((user["display_name"] ?? "U")[0])
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user["display_name"] ?? "",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(user["email"] ?? ""),
            const SizedBox(height: 10),
            Text("Role: ${user["role"]}"),
          ],
        ),
      ),
    );
  }
}
