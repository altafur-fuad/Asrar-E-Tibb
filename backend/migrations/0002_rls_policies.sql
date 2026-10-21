-- ==============================================================================
-- Migration 0002: Row Level Security Policies for Core, Identity & Personal Tables (CORRECTED)
-- Purpose:
--   1. Enable RLS on all 14 existing tables across the project.
--   2. Strict owner isolation on personal health data (schedules, notes, todos).
--   3. Identity row protection for users, profiles, and role tables (patients, doctors, etc.).
--   4. Dual author/admin moderation on community tables (posts, comments, post_images, post_likes).
--   5. Fix admin moderation delete permission on post_likes.
-- Author: Asrar-e-Tibb Security Gate (Stage 2 Review)
-- Date: 2026-10-21
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Identity & Profile Tables (public.users, public.profiles)
-- ------------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.profiles ENABLE ROW LEVEL SECURITY;

-- public.users
DROP POLICY IF EXISTS "users_select_policy" ON public.users;
CREATE POLICY "users_select_policy" ON public.users
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "users_insert_policy" ON public.users;
CREATE POLICY "users_insert_policy" ON public.users
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "users_update_policy" ON public.users;
CREATE POLICY "users_update_policy" ON public.users
  FOR UPDATE TO authenticated
  USING (auth.uid() = id OR public.is_admin(auth.uid()))
  WITH CHECK (auth.uid() = id OR public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "users_delete_policy" ON public.users;
CREATE POLICY "users_delete_policy" ON public.users
  FOR DELETE TO authenticated
  USING (public.is_admin(auth.uid()));

-- public.profiles
DROP POLICY IF EXISTS "profiles_select_policy" ON public.profiles;
CREATE POLICY "profiles_select_policy" ON public.profiles
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "profiles_insert_policy" ON public.profiles;
CREATE POLICY "profiles_insert_policy" ON public.profiles
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_update_policy" ON public.profiles;
CREATE POLICY "profiles_update_policy" ON public.profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = id OR public.is_admin(auth.uid()))
  WITH CHECK (auth.uid() = id OR public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "profiles_delete_policy" ON public.profiles;
CREATE POLICY "profiles_delete_policy" ON public.profiles
  FOR DELETE TO authenticated
  USING (public.is_admin(auth.uid()));


-- ------------------------------------------------------------------------------
-- 2. Role-Specific Extension Tables (patients, doctors, pharmacists, shop_owners)
-- ------------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.pharmacists ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.shop_owners ENABLE ROW LEVEL SECURITY;

-- Macro DO block to configure role tables safely if they exist
DO $$
DECLARE
  t text;
  tables text[] := ARRAY['patients', 'doctors', 'pharmacists', 'shop_owners'];
BEGIN
  FOREACH t IN ARRAY tables LOOP
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = t) THEN
      EXECUTE format('DROP POLICY IF EXISTS "%s_select" ON public.%I;', t, t);
      EXECUTE format('CREATE POLICY "%s_select" ON public.%I FOR SELECT TO authenticated USING (true);', t, t);

      EXECUTE format('DROP POLICY IF EXISTS "%s_insert" ON public.%I;', t, t);
      EXECUTE format('CREATE POLICY "%s_insert" ON public.%I FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id OR auth.uid() = auth_id);', t, t);

      EXECUTE format('DROP POLICY IF EXISTS "%s_update" ON public.%I;', t, t);
      EXECUTE format('CREATE POLICY "%s_update" ON public.%I FOR UPDATE TO authenticated USING (auth.uid() = user_id OR auth.uid() = auth_id OR public.is_admin(auth.uid())) WITH CHECK (auth.uid() = user_id OR auth.uid() = auth_id OR public.is_admin(auth.uid()));', t, t);

      EXECUTE format('DROP POLICY IF EXISTS "%s_delete" ON public.%I;', t, t);
      EXECUTE format('CREATE POLICY "%s_delete" ON public.%I FOR DELETE TO authenticated USING (auth.uid() = user_id OR auth.uid() = auth_id OR public.is_admin(auth.uid()));', t, t);
    END IF;
  END LOOP;
END $$;


-- ------------------------------------------------------------------------------
-- 3. Strict Personal Health Data (schedules, notes, todos)
-- ------------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.todos ENABLE ROW LEVEL SECURITY;

-- Schedules
DROP POLICY IF EXISTS "schedules_select_policy" ON public.schedules;
CREATE POLICY "schedules_select_policy" ON public.schedules
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "schedules_insert_policy" ON public.schedules;
CREATE POLICY "schedules_insert_policy" ON public.schedules
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "schedules_update_policy" ON public.schedules;
CREATE POLICY "schedules_update_policy" ON public.schedules
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "schedules_delete_policy" ON public.schedules;
CREATE POLICY "schedules_delete_policy" ON public.schedules
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- Notes
DROP POLICY IF EXISTS "notes_select_policy" ON public.notes;
CREATE POLICY "notes_select_policy" ON public.notes
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "notes_insert_policy" ON public.notes;
CREATE POLICY "notes_insert_policy" ON public.notes
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "notes_update_policy" ON public.notes;
CREATE POLICY "notes_update_policy" ON public.notes
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "notes_delete_policy" ON public.notes;
CREATE POLICY "notes_delete_policy" ON public.notes
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- Todos
DROP POLICY IF EXISTS "todos_select_policy" ON public.todos;
CREATE POLICY "todos_select_policy" ON public.todos
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "todos_insert_policy" ON public.todos;
CREATE POLICY "todos_insert_policy" ON public.todos
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "todos_update_policy" ON public.todos;
CREATE POLICY "todos_update_policy" ON public.todos
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "todos_delete_policy" ON public.todos;
CREATE POLICY "todos_delete_policy" ON public.todos
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);


-- ------------------------------------------------------------------------------
-- 4. Community & Moderation (posts, comments, post_images, post_likes, notifications)
-- ------------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.post_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.notifications ENABLE ROW LEVEL SECURITY;

-- Posts: Public Read, Author Create/Edit, Author OR Admin Delete
DROP POLICY IF EXISTS "posts_select_policy" ON public.posts;
CREATE POLICY "posts_select_policy" ON public.posts
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "posts_insert_policy" ON public.posts;
CREATE POLICY "posts_insert_policy" ON public.posts
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "posts_update_policy" ON public.posts;
CREATE POLICY "posts_update_policy" ON public.posts
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "posts_delete_policy" ON public.posts;
CREATE POLICY "posts_delete_policy" ON public.posts
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id OR public.is_admin(auth.uid()));

-- Comments: Public Read, Author Create/Edit, Author OR Admin Delete
DROP POLICY IF EXISTS "comments_select_policy" ON public.comments;
CREATE POLICY "comments_select_policy" ON public.comments
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "comments_insert_policy" ON public.comments;
CREATE POLICY "comments_insert_policy" ON public.comments
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "comments_update_policy" ON public.comments;
CREATE POLICY "comments_update_policy" ON public.comments
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "comments_delete_policy" ON public.comments;
CREATE POLICY "comments_delete_policy" ON public.comments
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id OR public.is_admin(auth.uid()));

-- Post Likes: Read All, Insert Own, Delete Own OR Admin Delete
DROP POLICY IF EXISTS "likes_select_policy" ON public.post_likes;
CREATE POLICY "likes_select_policy" ON public.post_likes
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "likes_insert_policy" ON public.post_likes;
CREATE POLICY "likes_insert_policy" ON public.post_likes
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "likes_delete_policy" ON public.post_likes;
CREATE POLICY "likes_delete_policy" ON public.post_likes
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id OR public.is_admin(auth.uid()));

-- Post Images: Read All, Insert Authenticated, Delete Author OR Admin
DROP POLICY IF EXISTS "post_images_select_policy" ON public.post_images;
CREATE POLICY "post_images_select_policy" ON public.post_images
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "post_images_insert_policy" ON public.post_images;
CREATE POLICY "post_images_insert_policy" ON public.post_images
  FOR INSERT TO authenticated
  WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "post_images_delete_policy" ON public.post_images;
CREATE POLICY "post_images_delete_policy" ON public.post_images
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.posts
      WHERE posts.id = post_images.post_id
        AND (posts.user_id = auth.uid() OR public.is_admin(auth.uid()))
    )
  );

-- Notifications: Read Own, Insert Authenticated Actor, Update Own (mark read), Delete Own
DROP POLICY IF EXISTS "notifications_select_policy" ON public.notifications;
CREATE POLICY "notifications_select_policy" ON public.notifications
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "notifications_insert_policy" ON public.notifications;
CREATE POLICY "notifications_insert_policy" ON public.notifications
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = actor_id);

DROP POLICY IF EXISTS "notifications_update_policy" ON public.notifications;
CREATE POLICY "notifications_update_policy" ON public.notifications
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "notifications_delete_policy" ON public.notifications;
CREATE POLICY "notifications_delete_policy" ON public.notifications
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);
