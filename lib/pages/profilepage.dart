// lib/pages/profile_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../sevices/supabase_services.dart';
// ignore: unused_import
import '../sevices/supabase_auth_hepler.dart';
import '../app_themes.dart';
import 'profile_settings_page.dart';
import '../tibbnews/post_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> posts = [];
  bool loading = true;

  final client = Supabase.instance.client;
  late String userId;

  static const String coverImagePath =
      '/mnt/data/4264a975-7848-499c-89c1-49136a30ead5.jpg';

  @override
  void initState() {
    super.initState();
    userId = client.auth.currentUser!.id;
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);
    final profile = await SupabaseService.fetchProfileMerged(userId);
    final userPosts = await SupabaseService.getUserPosts(userId);

    setState(() {
      user = profile;
      posts = userPosts;
      loading = false;
    });
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

  Widget _miniStat(String count, String label) {
    return Row(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Profile not found')),
      );
    }

    final avatar = (user!['avatar_url'] ?? '').toString();
    final name = (user!['name'] ?? '').toString();
    final bio = (user!['bio'] ?? '').toString();
    final postsCount = posts.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppThemes.primaryBlue,
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final changed = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileSettingsPage(profile: user),
                ),
              );
              if (changed == true) _loadAll();
            },
          ),
        ],
      ),
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

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isNotEmpty ? name : 'No name',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  bio.isNotEmpty ? bio : '—',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                _miniStat('$postsCount', 'posts'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 70),

              // ---------------- ABOUT ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      'Personal details',
                      editable: true,
                      onEdit: () async {
                        final changed = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileSettingsPage(profile: user),
                          ),
                        );
                        if (changed == true) _loadAll();
                      },
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
}
