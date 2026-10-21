-- ==============================================================================
-- Migration 0003: Storage Bucket Access Policies (CORRECTED)
-- Purpose:
--   1. Restrict profile-pictures uploads/updates strictly to user-owned root folder (<auth.uid()>/...).
--   2. Restrict post-images uploads to the 'posts/' directory for authenticated users.
--   3. Enable public read access intentionally required for feed & avatar rendering.
--   4. Allow owners to delete their own avatars and administrators to delete post images.
-- Author: Asrar-e-Tibb Security Gate (Stage 2 Review)
-- Date: 2026-10-21
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Profile Pictures Bucket (`profile-pictures`)
-- Upload pattern in Flutter: `<userId>/profile.<ext>` with upsert: true
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "profile_pictures_select" ON storage.objects;
CREATE POLICY "profile_pictures_select" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'profile-pictures');

DROP POLICY IF EXISTS "profile_pictures_insert" ON storage.objects;
CREATE POLICY "profile_pictures_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'profile-pictures' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "profile_pictures_update" ON storage.objects;
CREATE POLICY "profile_pictures_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'profile-pictures' AND
    (storage.foldername(name))[1] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id = 'profile-pictures' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "profile_pictures_delete" ON storage.objects;
CREATE POLICY "profile_pictures_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'profile-pictures' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );


-- ------------------------------------------------------------------------------
-- 2. Post Images Bucket (`post-images`)
-- Upload pattern in Flutter: `posts/<uuid>.<ext>` with upsert: false
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "post_images_select" ON storage.objects;
CREATE POLICY "post_images_select" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'post-images');

DROP POLICY IF EXISTS "post_images_insert" ON storage.objects;
CREATE POLICY "post_images_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'post-images' AND
    (storage.foldername(name))[1] = 'posts' AND
    auth.role() = 'authenticated'
  );

DROP POLICY IF EXISTS "post_images_delete" ON storage.objects;
CREATE POLICY "post_images_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'post-images' AND
    (public.is_admin(auth.uid()) OR auth.role() = 'service_role')
  );
