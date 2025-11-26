import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sevices/supabase_services.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifs();
  }

  Future<void> _loadNotifs() async {
    setState(() => _loading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final res = await SupabaseService.fetchNotifications(user.id);

      setState(() => _list = res);
    } catch (e) {
      print('notif err: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
          ? const Center(child: Text("No notifications yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _list.length,
              itemBuilder: (_, i) {
                final n = _list[i];
                final actor = n['actor'] ?? {};
                final name = actor['name'] ?? 'Someone';
                final role = actor['role'] ?? '';
                final email = (actor['email'] ?? '').toString().toLowerCase();
                
                // Check for specific admin emails: ADMIN and ASRAR-E
                final adminEmails = ['admin@app.xo', 'asraretibb@gmail.com'];
                final isAdminEmail = adminEmails.contains(email);
                final isVerified = actor['is_verified'] == true || role == "admin" || isAdminEmail;

                String text = "";
                if (n['type'] == "like") {
                  text = "$name liked your post";
                } else if (n['type'] == "comment") {
                  text = "$name commented on your post";
                } else {
                  text = n['message'] ?? 'Notification';
                }

                return Card(
                  color: isDark ? const Color(0xFF242526) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage("assets/image/pic.png"),
                    ),
                    title: Row(
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        if (isVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      n["created_at"] ?? "",
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
