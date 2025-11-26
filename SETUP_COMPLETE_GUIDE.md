# Complete Setup Guide for Asrar-e-Tibb App

## ✅ What Has Been Completed

### 1. **Supabase Integration**
- ✅ Supabase connection configured in `main.dart`
- ✅ All database services implemented in `lib/sevices/supabase_services.dart`
- ✅ Authentication with role-based login/signup
- ✅ Real-time updates for posts, comments, and likes

### 2. **TibbNews System (Facebook-style)**
- ✅ Create Post (text + image)
- ✅ Edit Post (own posts only)
- ✅ Delete Post (own posts + admin can delete any)
- ✅ Like Post (toggle like/unlike)
- ✅ Comment System (add, view, delete own comments)
- ✅ Post Details Page
- ✅ Profile Navigation (click username → open profile)
- ✅ Admin can delete any post & any comment
- ✅ Posts shown in reverse chronological order
- ✅ Post Card with:
  - User profile image
  - User name + blue tick if verified
  - Content
  - Image(s)
  - Like count
  - Comment count
  - Timestamp (formatted)

### 3. **Profile System (Dynamic + Editable)**
- ✅ Dynamic ProfilePage(userId) showing:
  - Profile image
  - Name
  - Role
  - Verified badge
  - Bio
  - All posts by the user
- ✅ EditProfilePage with:
  - Change name
  - Change bio
  - Change profile picture (Supabase Storage)
  - Update users table

### 4. **Admin Panel (Full Control)**
- ✅ AdminDashboard with tabs:
  - Analytics Dashboard (total users, posts, blocked users, verified users)
  - User Management (search, block/unblock, verify, view details)
  - Post Management (view all posts, delete any)
  - Comment Management (view all comments, delete any)
- ✅ Theme edit access (already implemented)
- ✅ Analytics with real-time data

### 5. **Login & Signup**
- ✅ Role-based authentication
- ✅ Proper role validation
- ✅ Admin login support
- ✅ Blocked user check
- ✅ Session management

## 📋 Supabase Setup Required

### Step 1: Run Database Schema

1. Go to your Supabase Dashboard → SQL Editor
2. Run `supabase_complete_setup.sql` (main schema)
3. Run `supabase_migration_add_profile_fields.sql` (adds bio and profile_picture columns)

### Step 2: Create Storage Buckets

1. Go to Storage in Supabase Dashboard
2. Create two buckets:
   - **Bucket Name**: `post-images`
     - Public: ✅ Yes
     - File size limit: 10MB
     - Allowed MIME types: image/*
   
   - **Bucket Name**: `profile-pictures`
     - Public: ✅ Yes
     - File size limit: 5MB
     - Allowed MIME types: image/*

3. Set Storage Policies:
   - For `post-images`: Allow public read, authenticated insert
   - For `profile-pictures`: Allow public read, authenticated insert/update

### Step 3: Enable Realtime

1. Go to Database → Replication
2. Enable replication for:
   - `posts` table
   - `post_images` table
   - `post_likes` table
   - `comments` table
   - `users` table (for admin panel)

### Step 4: Create Admin User

Run this SQL in SQL Editor:

```sql
-- First, create admin in auth.users (via Supabase Auth UI or API)
-- Then insert into users table:

INSERT INTO public.users (id, name, email, role, is_verified, is_blocked)
VALUES (
  'YOUR_ADMIN_AUTH_USER_ID',  -- Replace with actual auth user ID
  'Admin',
  'admin@example.com',  -- Replace with admin email
  'admin',
  true,
  false
);
```

Or use the Supabase Auth UI to create an admin user, then update the users table.

### Step 5: Update RLS Policies (if needed)

The schema includes RLS policies, but verify:
- Users can read their own data
- Users can update their own data
- Anyone can read posts/comments (public feed)
- Only post owners can edit/delete their posts
- Admins can delete any post/comment (you may need to add admin policies)

## 🚀 Running the App

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Verify Supabase Connection**:
   - Check `lib/main.dart` - Supabase URL and anon key are already configured
   - Make sure they match your Supabase project

3. **Run the App**:
   ```bash
   flutter run
   ```

## 📱 Features Overview

### For Regular Users:
- Login/Signup with role selection
- Create, edit, delete own posts
- Like and comment on posts
- View profiles (click on username)
- Edit own profile (name, bio, profile picture)
- View notifications

### For Admins:
- All regular user features
- Admin Panel access (from menu)
- View analytics dashboard
- Manage users (search, block/unblock, verify)
- Manage posts (view all, delete any)
- Manage comments (view all, delete any)
- Delete any post or comment

## 🔧 Key Files Modified/Created

### New Files:
- `lib/tibbnews/edit_post_page.dart` - Edit posts
- `lib/tibbnews/user_profile_page.dart` - Dynamic user profiles
- `lib/tibbnews/edit_profile_page.dart` - Edit profile
- `supabase_migration_add_profile_fields.sql` - Database migration

### Modified Files:
- `lib/sevices/supabase_services.dart` - Enhanced with all new methods
- `lib/tibbnews/poast_card.dart` - Complete rewrite with all features
- `lib/tibbnews/comments_sheet.dart` - Added admin delete
- `lib/tibbnews/profile_page.dart` - Now uses UserProfilePage
- `lib/admin/admin_panel_page.dart` - Complete rewrite with analytics
- `pubspec.yaml` - Added intl package

## ⚠️ Important Notes

1. **Storage Buckets**: Must be created in Supabase Dashboard
2. **Realtime**: Must be enabled for tables mentioned above
3. **Admin User**: Must be created manually (see Step 4)
4. **Profile Fields**: Run the migration SQL to add `bio` and `profile_picture` columns
5. **RLS Policies**: The schema includes basic policies, but you may need to add admin-specific policies for full admin control

## 🐛 Troubleshooting

### Posts not showing?
- Check Realtime is enabled for `posts` table
- Verify RLS policies allow public read

### Profile picture not uploading?
- Check `profile-pictures` bucket exists and is public
- Verify storage policies allow authenticated uploads

### Admin features not working?
- Verify user role is 'admin' in users table
- Check `isAdmin()` method in SupabaseService

### Like/Comment counts not updating?
- Check Realtime is enabled for `post_likes` and `comments` tables
- Verify the stream subscriptions are active

## 📝 Next Steps (Optional Enhancements)

1. Add notifications when someone likes/comments on your post
2. Add post sharing functionality
3. Add hashtags and mentions
4. Add image compression before upload
5. Add post reporting feature
6. Add user following system

---

**All features requested have been implemented! 🎉**

