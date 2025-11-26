import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sevices/supabase_services.dart';

class CommentsSheet extends StatefulWidget {
  final String postId;
  final String? currentUserId;
  const CommentsSheet({super.key, required this.postId, this.currentUserId});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _ctrl = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _fetchComments();

    // Realtime auto refresh - Using new Supabase Realtime API
    final channel = Supabase.instance.client.channel('public:comments-${widget.postId}');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'comments',
      callback: (payload) => _fetchComments(),
    );
    channel.subscribe();
  }

  Future<void> _checkAdmin() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final admin = await SupabaseService.isAdmin(user.id);
      setState(() => _isAdmin = admin);
    }
  }

  // ------------------ Fetch Comments ------------------
  Future<void> _fetchComments() async {
    try {
      final res = await Supabase.instance.client
          .from('comments')
          .select('*, users:user_id(name, role, is_verified)')
          .eq('post_id', widget.postId)
          .order('created_at');

      setState(() {
        _comments = List<Map<String, dynamic>>.from(res as List);
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error loading comments: $e");
    }
  }

  // ------------------ Add Comment ------------------
  Future<void> _addComment() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login required")));
      return;
    }

    final ok = await SupabaseService.addComment(
      postId: widget.postId,
      userId: user.id,
      content: text,
    );

    if (ok) {
      _ctrl.clear();
      await _fetchComments();
    }
  }

  // ------------------ Delete Comment ------------------
  Future<void> _deleteComment(String commentId, bool isOwnComment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isOwnComment ? 'Delete Comment' : 'Delete Comment (Admin)'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = isOwnComment
        ? await Supabase.instance.client
            .from('comments')
            .delete()
            .eq('id', commentId)
            .then((_) => true)
            .catchError((_) => false)
        : await SupabaseService.adminDeleteComment(commentId);

    if (mounted && success) {
      await _fetchComments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              // Top drag bar
              Container(
                width: 60,
                height: 6,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              const Text(
                "Comments",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _comments.length,
                        itemBuilder: (_, i) {
                          final c = _comments[i];
                          final user = c['users'] as Map<String, dynamic>?;
                          final name = user?['name'] ?? 'Unknown User';
                          final role = user?['role'] ?? '';
                          final commentUserId = c['user_id']?.toString() ?? '';
                          final currentUserId = widget.currentUserId ?? '';
                          final isCommentOwner = commentUserId == currentUserId;
                          final userIsAdmin = role == 'admin';
                          final verified = user?['is_verified'] == true || userIsAdmin;
                          final canDelete = isCommentOwner || _isAdmin;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: const AssetImage(
                                'assets/image/pic.png',
                              ),
                              child: userIsAdmin
                                  ? const Icon(
                                      Icons.admin_panel_settings,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        userIsAdmin ? 'Admin' : name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (verified) const SizedBox(width: 4),
                                      if (verified)
                                        const Icon(
                                          Icons.verified,
                                          color: Colors.blue,
                                          size: 16,
                                        ),
                                    ],
                                  ),
                                ),
                                if (canDelete)
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                    onPressed: () => _deleteComment(
                                      c['id'].toString(),
                                      isCommentOwner,
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Text(c['content'] ?? ''),
                          );
                        },
                      ),
              ),

              const Divider(),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        decoration: const InputDecoration(
                          hintText: "Write a comment...",
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _addComment,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
