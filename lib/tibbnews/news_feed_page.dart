// lib/tibbnews/news_feed_page.dart

import 'package:flutter/material.dart';
import '../sevices/supabase_services.dart';
import 'post_card.dart';
import 'create_post_page.dart'; // ← MUST ADD THIS

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({super.key});

  @override
  State<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(title: const Text("News Feed"), elevation: 0),

      body: Column(
        children: [
          // ----------------------------------------------------------
          //   WHAT'S ON YOUR MIND (CREATE POST SHORTCUT)
          // ----------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage("assets/image/pic.png"),
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

          const SizedBox(height: 10),

          // ----------------------------------------------------------
          //   POSTS STREAM BUILDER
          // ----------------------------------------------------------
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: SupabaseService.postsStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snap.hasData || snap.data!.isEmpty) {
                  return const Center(child: Text("No posts available"));
                }

                final posts = snap.data!;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (_, i) => PostCard(post: posts[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
