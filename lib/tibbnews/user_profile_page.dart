// lib/tibbnews/user_profile_page.dart

import 'package:asrarpages/tibbnews/create_post_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../sevices/supabase_services.dart';
import 'post_card.dart';
import 'edit_profile_page.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> posts = [];
  bool loading = true;
  bool isOwnProfile = false;
  late TabController _tabController;

  static const String coverImagePath =
      '/mnt/data/4264a975-7848-499c-89c1-49136a30ead5.jpg';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
    _checkIfOwnProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkIfOwnProfile() async {
    final current = Supabase.instance.client.auth.currentUser;
    if (current != null) {
      setState(() {
        isOwnProfile = current.id == widget.userId;
      });
    }
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);
    try {
      final profile = await SupabaseService.fetchProfileMerged(widget.userId);
      final userPosts = await SupabaseService.getUserPosts(widget.userId);
      if (mounted) {
        setState(() {
          user = profile;
          posts = userPosts;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  // ignore: unused_element
  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return iso;
    }
  }

  Widget _actionButton(String text, {VoidCallback? onTap, Color? color}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User not found')),
      );
    }

    final role = (user!['role'] ?? '').toString();
    final isAdmin = role == 'admin' || (user!['is_admin'] == true);
    final verified = (user!['is_verified'] == true) || isAdmin;
    final avatar = (user!['avatar_url'] ?? user!['profile_picture'] ?? '')
        .toString();
    final name = (user!['name'] ?? '').toString();
    final bio = (user!['bio'] ?? '').toString();
    final postsCount = posts.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ---------------- COVER + HEADER ----------------
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.network(
                      coverImagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/image/banner1.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // ---- Profile Card ----
                  Positioned(
                    left: 6,
                    bottom: -50,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundImage: avatar.isNotEmpty
                                ? NetworkImage(avatar)
                                : const AssetImage('assets/image/pic.png')
                                      as ImageProvider,
                          ),
                          const SizedBox(width: 12),

                          // ---- Name + Bio ----
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name.isNotEmpty ? name : 'No name',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (verified)
                                      const Icon(
                                        Icons.verified,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  bio.isNotEmpty ? bio : '—',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [_miniStat('$postsCount', 'posts')],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // ---- Edit buttons only for own profile ----
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (isOwnProfile)
                                _actionButton(
                                  'Edit profile',
                                  onTap: () async {
                                    final changed = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditProfilePage(initialData: user!),
                                      ),
                                    );
                                    if (changed == true) _loadAll();
                                  },
                                  color: const Color.fromARGB(255, 23, 44, 55),
                                ),

                              const SizedBox(height: 8),

                              if (isOwnProfile)
                                _actionButton(
                                  'Add to story',
                                  onTap: () {},
                                  color: const Color.fromARGB(255, 25, 44, 58),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 70),

              // ---------------- Tabs (All / Photos) ----------------
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _tabFilter('All', active: true),
                    const SizedBox(width: 12),
                    _tabFilter('Photos'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ---------------- ABOUT SECTION ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      'Personal details',
                      editable: isOwnProfile, // ← Only own profile editable
                      onEdit: isOwnProfile
                          ? () async {
                              final changed = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditProfilePage(initialData: user!),
                                ),
                              );
                              if (changed == true) _loadAll();
                            }
                          : null,
                    ),

                    const SizedBox(height: 8),
                    _infoRow(Icons.location_on, user!['home_address'] ?? '—'),
                    const SizedBox(height: 8),
                    _infoRow(Icons.home, user!['office_address'] ?? '—'),
                    const SizedBox(height: 8),
                    _infoRow(
                      Icons.favorite,
                      user!['relationship_status'] ?? '—',
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // ---------------- CREATE POST SHORTCUT ----------------
              if (isOwnProfile)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreatePostPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: avatar.isNotEmpty
                                ? NetworkImage(avatar)
                                : const AssetImage('assets/image/pic.png')
                                      as ImageProvider,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "What's on your mind?",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const Icon(Icons.edit, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // ---------------- POSTS ----------------
              if (posts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No posts yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ListView.builder(
                  itemCount: posts.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, i) => PostCard(post: posts[i]),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String count, String label) {
    return Row(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _tabFilter(String text, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: active ? Colors.white : Colors.grey),
      ),
    );
  }

  Widget _sectionHeader(
    String title, {
    bool editable = false,
    VoidCallback? onEdit,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (editable)
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
      ],
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}
