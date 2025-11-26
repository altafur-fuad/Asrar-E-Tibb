// ---------------------------------------------------------
// lib/sevices/supabase_services.dart   (FINAL OPTION 1)
// ---------------------------------------------------------

import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final _db = Supabase.instance.client;

class SupabaseService {
  static const String postBucket = 'post-images';
  static const String profileBucket = 'profile-pictures';

  // --------------------- UPLOAD POST IMAGE ---------------------
  static Future<String?> uploadPostImage(PlatformFile file) async {
    try {
      if (file.bytes == null) return null;
      final id = const Uuid().v4();
      final ext = file.extension ?? 'jpg';
      final path = 'posts/$id.$ext';

      await _db.storage
          .from(postBucket)
          .uploadBinary(
            path,
            file.bytes!,
            fileOptions: const FileOptions(upsert: false),
          );

      return _db.storage.from(postBucket).getPublicUrl(path);
    } catch (e) {
      debugPrint('uploadPostImage ERROR: $e');
      return null;
    }
  }

  // --------------------- UPLOAD PROFILE PIC ---------------------
  static Future<String?> uploadProfilePicture(
    PlatformFile file,
    String userId,
  ) async {
    try {
      if (file.bytes == null) return null;
      final ext = file.extension ?? 'jpg';
      final path = '$userId/profile.$ext';

      await _db.storage
          .from(profileBucket)
          .uploadBinary(
            path,
            file.bytes!,
            fileOptions: const FileOptions(upsert: true),
          );

      return _db.storage.from(profileBucket).getPublicUrl(path);
    } catch (e) {
      debugPrint('uploadProfilePicture ERROR: $e');
      return null;
    }
  }

  // -------------------------- CREATE POST --------------------------
  static Future<bool> createPost({
    required String userId,
    required String content,
    List<String>? imageUrls,
  }) async {
    try {
      // insert post and return inserted row (id)
      final inserted = await _db
          .from('posts')
          .insert({'user_id': userId, 'content': content})
          .select()
          .single();

      final postId = inserted['id'];

      if (imageUrls != null && imageUrls.isNotEmpty) {
        await _db
            .from('post_images')
            .insert(
              imageUrls
                  .map((url) => {'post_id': postId, 'storage_path': url})
                  .toList(),
            );
      }

      // Optionally: Notify followers here if you have follower logic

      return true;
    } catch (e) {
      debugPrint('createPost ERROR: $e');
      return false;
    }
  }

  // --------------------------- POSTS STREAM ---------------------------
  /// Returns a broadcast stream of posts (including profiles, images, likes with user_id and comments with user_id)
  // --------------------------- POSTS STREAM ---------------------------
  static Stream<List<Map<String, dynamic>>> postsStream() {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();

    Future<void> load() async {
      try {
        final res = await _db
            .from('posts')
            .select('''
            id,
            content,
            created_at,
            updated_at,
            user_id,

            profiles:user_id (
              id,
              name,
              avatar_url,
              role,
              is_verified
            ),

            post_images (storage_path),
            post_likes (id, user_id),
            comments (id, user_id)
          ''')
            .order('created_at', ascending: false);

        final list = List<Map<String, dynamic>>.from(res);

        for (var p in list) {
          p['likes_count'] = (p['post_likes'] as List?)?.length ?? 0;
          p['comments_count'] = (p['comments'] as List?)?.length ?? 0;

          /// FIX: ONLY USE profiles AS users — DO NOT USE users TABLE
          p['users'] = p['profiles'] ?? {};

          final imgs = (p['post_images'] as List?) ?? [];
          p['preview'] = imgs.isNotEmpty ? imgs[0]['storage_path'] : '';
        }

        controller.add(list);
      } catch (e) {
        debugPrint('postsStream ERROR: $e');
        controller.add([]);
      }
    }

    load();

    final channel = _db.channel('public:posts-all');

    void watch(String table) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        callback: (_) => load(),
      );
    }

    // watch tables that affect the feed
    watch('posts');
    watch('post_images');
    watch('post_likes');
    watch('comments');
    watch('profiles'); // ✔ correct
    // ❌ DO NOT WATCH "users" — you don't join it anymore

    channel.subscribe();

    return controller.stream;
  }

  // ------------------------------ LIKE / UNLIKE ------------------------------
  // creates/deletes like and inserts notification when liking someone else's post
  static Future<bool> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      final exists = await _db
          .from('post_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      if (exists == null) {
        await _db.from('post_likes').insert({
          'post_id': postId,
          'user_id': userId,
        });

        // Notification: find post owner and notify (if not self)
        try {
          final post = await _db
              .from('posts')
              .select('id, user_id')
              .eq('id', postId)
              .maybeSingle();

          if (post != null && post['user_id'] != userId) {
            await _db.from('notifications').insert({
              'user_id': post['user_id'],
              'actor_id': userId,
              'type': 'like',
              'message': 'liked your post',
            });
          }
        } catch (e) {
          debugPrint('toggleLike -> notification ERROR: $e');
        }
      } else {
        await _db.from('post_likes').delete().eq('id', exists['id']);
      }

      return true;
    } catch (e) {
      debugPrint('toggleLike ERROR: $e');
      return false;
    }
  }

  // ------------------------------- COMMENT -------------------------------
  // inserts comment and notifies post owner
  static Future<bool> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    try {
      final inserted = await _db
          .from('comments')
          .insert({'post_id': postId, 'user_id': userId, 'content': content})
          .select()
          .maybeSingle();

      // Notification to post owner (if not commenting on own post)
      try {
        final post = await _db
            .from('posts')
            .select('id, user_id')
            .eq('id', postId)
            .maybeSingle();

        if (post != null && post['user_id'] != userId) {
          await _db.from('notifications').insert({
            'user_id': post['user_id'],
            'actor_id': userId,
            'type': 'comment',
            'message': 'commented on your post',
          });
        }
      } catch (e) {
        debugPrint('addComment -> notification ERROR: $e');
      }

      return inserted != null;
    } catch (e) {
      debugPrint('addComment ERROR: $e');
      return false;
    }
  }

  // ----------------------- MERGED PROFILE FETCH -----------------------
  static Future<Map<String, dynamic>?> fetchProfileMerged(String userId) async {
    try {
      final profile = await _db
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      final user = await _db
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (profile == null && user == null) return null;

      final out = <String, dynamic>{};
      if (user != null) out.addAll(user);
      if (profile != null) out.addAll(profile);

      return out;
    } catch (e) {
      debugPrint('fetchProfileMerged ERROR: $e');
      return null;
    }
  }

  // -----------------------------------------------------
  // GET USER POSTS  ✅ (FINAL)
  // -----------------------------------------------------
  static Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    try {
      final res = await _db
          .from('posts')
          .select('''
          id,
          content,
          created_at,
          updated_at,
          user_id,
          profiles:user_id (
            id,
            name,
            avatar_url,
            role,
            is_verified
          ),
          post_images (storage_path),
          post_likes (id, user_id),
          comments (id, user_id)
        ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(res);

      for (var p in list) {
        p['likes_count'] = (p['post_likes'] as List?)?.length ?? 0;
        p['comments_count'] = (p['comments'] as List?)?.length ?? 0;
        p['users'] = p['profiles'] ?? {};
      }

      return list;
    } catch (e) {
      debugPrint("getUserPosts ERROR: $e");
      return [];
    }
  }

  // ------------------------------ EDIT POST ------------------------------
  static Future<bool> editPost({
    required String postId,
    required String userId,
    required String content,
    List<String>? imageUrls,
  }) async {
    try {
      await _db
          .from('posts')
          .update({
            'content': content,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', postId)
          .eq('user_id', userId);

      // remove previous images
      await _db.from('post_images').delete().eq('post_id', postId);

      if (imageUrls != null && imageUrls.isNotEmpty) {
        await _db
            .from('post_images')
            .insert(
              imageUrls
                  .map((u) => {'post_id': postId, 'storage_path': u})
                  .toList(),
            );
      }

      return true;
    } catch (e) {
      debugPrint('editPost ERROR: $e');
      return false;
    }
  }

  // ------------------------------ DELETE OWN POST ------------------------------
  static Future<bool> deleteOwnPost({
    required String postId,
    required String userId,
  }) async {
    try {
      await _db.from('post_images').delete().eq('post_id', postId);
      await _db.from('post_likes').delete().eq('post_id', postId);
      await _db.from('comments').delete().eq('post_id', postId);

      await _db.from('posts').delete().eq('id', postId).eq('user_id', userId);

      return true;
    } catch (e) {
      debugPrint('deleteOwnPost ERROR: $e');
      return false;
    }
  }

  // ------------------------------ ADMIN DELETE POST ------------------------------
  static Future<bool> adminDeletePost(String postId) async {
    try {
      await _db.from('post_images').delete().eq('post_id', postId);
      await _db.from('post_likes').delete().eq('post_id', postId);
      await _db.from('comments').delete().eq('post_id', postId);
      await _db.from('posts').delete().eq('id', postId);
      return true;
    } catch (e) {
      debugPrint('adminDeletePost ERROR: $e');
      return false;
    }
  }

  // ------------------------------ ADMIN DELETE COMMENT ------------------------------
  static Future<bool> adminDeleteComment(String commentId) async {
    try {
      await _db.from('comments').delete().eq('id', commentId);
      return true;
    } catch (e) {
      debugPrint('adminDeleteComment ERROR: $e');
      return false;
    }
  }

  // ------------------------------ NOTIFICATIONS ------------------------------
  static Future<List<Map<String, dynamic>>> fetchNotifications(
    String userId,
  ) async {
    try {
      final res = await _db
          .from('notifications')
          .select('*, actor:actor_id(name, role, is_verified, email)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('fetchNotifications ERROR: $e');
      return [];
    }
  }

  // ------------------------------ ADMIN CHECK ------------------------------
  static Future<bool> isAdmin(String userId) async {
    try {
      final r = await _db
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      // fallback: users table may carry is_admin flag
      if (r != null && r['role'] == 'admin') return true;

      try {
        final u = await _db
            .from('users')
            .select('is_admin, role')
            .eq('id', userId)
            .maybeSingle();
        if (u != null && (u['is_admin'] == true || u['role'] == 'admin')) {
          return true;
        }
      } catch (_) {}

      return false;
    } catch (e) {
      debugPrint('isAdmin ERROR: $e');
      return false;
    }
  }

  // ------------------------------ FIXED LIKE COUNT ------------------------------
  static Future<int> getLikeCount(String postId) async {
    try {
      final res = await _db
          .from('post_likes')
          .select('id')
          .eq('post_id', postId);
      return (res as List).length;
    } catch (_) {
      return 0;
    }
  }

  // -----------------------------------------------------
  // UPDATE FULL PROFILE (FINAL)
  // -----------------------------------------------------
  static Future<bool> updateProfileFull({
    required String userId,
    required String name,
    required String contactNumber,
    required String bloodGroup,
    required String lastDonateDate,
    required String healthCondition,
    required String homeAddress,
    required String officeAddress,
    required String dob,
    required String emergencyContact,
    required String notes,
    String? avatarUrl,
  }) async {
    try {
      final data = {
        'name': name,
        'mobile': contactNumber,
        'blood_group': bloodGroup,
        'last_donate': lastDonateDate,
        'health_condition': healthCondition,
        'home_address': homeAddress,
        'office_address': officeAddress,
        'dob': dob,
        'emergency_contact': emergencyContact,
        'notes': notes,
      };

      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        data['avatar_url'] = avatarUrl;
      }

      await _db.from('profiles').update(data).eq('id', userId);

      return true;
    } catch (e) {
      debugPrint("updateProfileFull ERROR: $e");
      return false;
    }
  }

  // ------------------------------ PAGINATED POSTS ------------------------------
  static Future<List<Map<String, dynamic>>> fetchPaginatedPosts({
    required int limit,
    required int offset,
  }) async {
    try {
      final res = await _db
          .from('posts')
          .select('''
        id, content, created_at, user_id,
        profiles:user_id(id,name,avatar_url,role,is_verified),
        post_images(storage_path),
        post_likes(id,user_id),
        comments(id,user_id)
      ''')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final list = List<Map<String, dynamic>>.from(res);

      for (var p in list) {
        p['likes_count'] = (p['post_likes'] as List?)?.length ?? 0;
        p['comments_count'] = (p['comments'] as List?)?.length ?? 0;
        p['users'] = p['profiles'] ?? p['users'] ?? {};
        final imgs = (p['post_images'] as List?) ?? [];
        p['preview'] = imgs.isNotEmpty ? imgs[0]['storage_path'] : '';
      }

      return list;
    } catch (e) {
      debugPrint('fetchPaginatedPosts ERROR: $e');
      return [];
    }
  }

  // ------------------------------ SCHEDULES (REMINDERS) ------------------------------
  static Future<bool> createSchedule({
    required String userId,
    required String title,
    String? dose,
    String? timeOfDay,
    DateTime? nextRun,
    String? repeat,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'title': title,
        'dose': dose ?? '',
        'time_of_day': timeOfDay ?? '',
        'next_run': nextRun?.toIso8601String(),
        'repeat': repeat ?? '',
      };
      final inserted = await _db
          .from('schedules')
          .insert(data)
          .select()
          .maybeSingle();
      return inserted != null;
    } catch (e) {
      debugPrint('createSchedule ERROR: $e');
      return false;
    }
  }

  static Future<bool> updateSchedule({
    required String scheduleId,
    required String userId,
    String? title,
    String? dose,
    String? timeOfDay,
    DateTime? nextRun,
    String? repeat,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (dose != null) data['dose'] = dose;
      if (timeOfDay != null) data['time_of_day'] = timeOfDay;
      if (nextRun != null) data['next_run'] = nextRun.toIso8601String();
      if (repeat != null) data['repeat'] = repeat;
      data['updated_at'] = DateTime.now().toIso8601String();

      // ignore: unused_local_variable
      final res = await _db
          .from('schedules')
          .update(data)
          .eq('id', scheduleId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      debugPrint('updateSchedule ERROR: $e');
      return false;
    }
  }

  static Future<bool> deleteSchedule(String scheduleId, String userId) async {
    try {
      await _db
          .from('schedules')
          .delete()
          .eq('id', scheduleId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('deleteSchedule ERROR: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchSchedules(
    String userId,
  ) async {
    try {
      final res = await _db
          .from('schedules')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('fetchSchedules ERROR: $e');
      return [];
    }
  }

  static Stream<List<Map<String, dynamic>>> schedulesStream(String userId) {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();

    Future<void> load() async {
      try {
        final list = await fetchSchedules(userId);
        controller.add(list);
      } catch (e) {
        controller.add([]);
      }
    }

    load();

    final channel = _db.channel('public:schedules-$userId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'schedules',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (_) => load(),
    );

    channel.subscribe();

    return controller.stream;
  }

  // ------------------------------ NOTES ------------------------------
  static Future<Map<String, dynamic>?> createNote({
    required String userId,
    String? title,
    required String content,
    bool pinned = false,
  }) async {
    try {
      final inserted = await _db
          .from('notes')
          .insert({
            'user_id': userId,
            'title': title ?? '',
            'content': content,
            'pinned': pinned,
          })
          .select()
          .maybeSingle();
      return inserted == null ? null : Map<String, dynamic>.from(inserted);
    } catch (e) {
      debugPrint('createNote ERROR: $e');
      return null;
    }
  }

  static Future<bool> updateNote({
    required String noteId,
    required String userId,
    String? title,
    String? content,
    bool? pinned,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (pinned != null) data['pinned'] = pinned;
      data['updated_at'] = DateTime.now().toIso8601String();

      await _db
          .from('notes')
          .update(data)
          .eq('id', noteId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('updateNote ERROR: $e');
      return false;
    }
  }

  static Future<bool> deleteNote(String noteId, String userId) async {
    try {
      await _db.from('notes').delete().eq('id', noteId).eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('deleteNote ERROR: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchNotes(String userId) async {
    try {
      final res = await _db
          .from('notes')
          .select('*')
          .eq('user_id', userId)
          .order('pinned', ascending: false)
          .order('updated_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('fetchNotes ERROR: $e');
      return [];
    }
  }

  static Stream<List<Map<String, dynamic>>> notesStream(String userId) {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();

    Future<void> load() async {
      try {
        final list = await fetchNotes(userId);
        controller.add(list);
      } catch (e) {
        controller.add([]);
      }
    }

    load();

    final channel = _db.channel('public:notes-$userId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'notes',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (_) => load(),
    );

    channel.subscribe();

    return controller.stream;
  }

  // ------------------------------ TODOS ------------------------------
  static Future<Map<String, dynamic>?> createTodo({
    required String userId,
    required String text,
  }) async {
    try {
      final inserted = await _db
          .from('todos')
          .insert({'user_id': userId, 'text': text, 'done': false})
          .select()
          .maybeSingle();
      return inserted == null ? null : Map<String, dynamic>.from(inserted);
    } catch (e) {
      debugPrint('createTodo ERROR: $e');
      return null;
    }
  }

  static Future<bool> toggleTodoDone({
    required String todoId,
    required String userId,
    required bool done,
  }) async {
    try {
      await _db
          .from('todos')
          .update({
            'done': done,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', todoId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('toggleTodoDone ERROR: $e');
      return false;
    }
  }

  static Future<bool> deleteTodo(String todoId, String userId) async {
    try {
      await _db.from('todos').delete().eq('id', todoId).eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('deleteTodo ERROR: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchTodos(String userId) async {
    try {
      final res = await _db
          .from('todos')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('fetchTodos ERROR: $e');
      return [];
    }
  }

  static Stream<List<Map<String, dynamic>>> todosStream(String userId) {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();

    Future<void> load() async {
      try {
        final list = await fetchTodos(userId);
        controller.add(list);
      } catch (e) {
        controller.add([]);
      }
    }

    load();

    final channel = _db.channel('public:todos-$userId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'todos',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (_) => load(),
    );

    channel.subscribe();

    return controller.stream;
  }
}
