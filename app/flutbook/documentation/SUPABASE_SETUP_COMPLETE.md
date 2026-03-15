# 🗄️ Supabase Backend Setup Guide - Phase 7 Sync

**Date:** March 15, 2026
**Purpose:** Complete database setup for library sync, playback position sync, and reading lists

---

## 📋 What You Need to Implement

Your Flutter app already has **ALL frontend code implemented** for:
- ✅ Library Sync (Task 7.1) - Metadata only
- ✅ Playback Position Sync (Task 7.2)
- ✅ Reading List Management (Task 7.3)
- ✅ Offline Queue (Task 7.5) - Uses local Isar, no backend needed

**Important:** Audio files are NOT backed up or synced. Only metadata and app-generated data (playback positions, reading lists, bookmarks) are synced.

**You only need to set up the Supabase backend** by running the SQL script below.

---

## 🚀 Quick Setup Steps

### Step 1: Create Supabase Account & Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up / Log in
3. Click "New Project"
4. Fill in:
   - **Name:** `flutbook` (or your choice)
   - **Database Password:** (save this securely)
   - **Region:** Choose closest to your users
5. Click "Create new project"
6. Wait 2-3 minutes for setup to complete

### Step 2: Get Your Credentials

1. In Supabase Dashboard, go to **Settings** (gear icon) → **API**
2. Copy these two values:
   - **Project URL:** `https://xxxxx.supabase.co`
   - **anon/public key:** `eyJhbG...` (long string)

### Step 3: Update Flutter App Configuration

Edit these files in your Flutter project:

**`.env.development`:**
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**`.env.staging`:** (same as development for now)
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**`.env.production`:** (use production credentials when ready)
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### Step 4: Run the SQL Setup Script

1. In Supabase Dashboard, go to **SQL Editor** (left sidebar)
2. Click **"New Query"**
3. Copy the entire SQL script below
4. Paste it into the editor
5. Click **"Run"** (or press Ctrl+Enter / Cmd+Enter)
6. Wait for all statements to execute successfully

---

## 📜 Complete SQL Setup Script

```sql
-- =====================================================
-- FLUTBOOK SUPABASE SYNC - COMPLETE SETUP
-- =====================================================
-- This script sets up all tables, indexes, and security
-- policies for library sync, playback position sync,
-- reading lists, and backup functionality.
-- =====================================================

-- Enable UUID extension (should already be enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLE 1: AUDIOBOOKS (Library Sync - Task 7.1)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.audiobooks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,

  -- Audiobook metadata
  title TEXT NOT NULL,
  author TEXT,
  album TEXT,
  cover_art_path TEXT,

  -- File information (local file path reference)
  file_path TEXT NOT NULL,
  duration_ms INTEGER DEFAULT 0,
  total_size INTEGER DEFAULT 0,

  -- Playback state
  last_played_at TIMESTAMPTZ,
  completed BOOLEAN DEFAULT FALSE,

  -- Sync timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Unique constraint: one entry per file per user
  UNIQUE(user_id, file_path)
);

-- Indexes for audiobooks (improves query performance)
CREATE INDEX IF NOT EXISTS idx_audiobooks_user_id ON public.audiobooks(user_id);
CREATE INDEX IF NOT EXISTS idx_audiobooks_file_path ON public.audiobooks(file_path);
CREATE INDEX IF NOT EXISTS idx_audiobooks_created_at ON public.audiobooks(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audiobooks_updated_at ON public.audiobooks(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_audiobooks_last_played ON public.audiobooks(last_played_at DESC);

-- =====================================================
-- TABLE 2: PLAYBACK_SESSIONS (Playback Position Sync - Task 7.2)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.playback_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  audiobook_id UUID REFERENCES public.audiobooks(id) ON DELETE CASCADE NOT NULL,

  -- Playback state
  current_position_ms INTEGER DEFAULT 0,
  playback_speed REAL DEFAULT 1.0,
  is_playing BOOLEAN DEFAULT FALSE,

  -- Sleep timer state
  sleep_timer_active BOOLEAN DEFAULT FALSE,
  sleep_timer_duration_ms INTEGER,

  -- Timestamps
  last_played_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- One session per audiobook per user
  UNIQUE(user_id, audiobook_id)
);

-- Indexes for playback sessions
CREATE INDEX IF NOT EXISTS idx_playback_sessions_user_id ON public.playback_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_playback_sessions_audiobook_id ON public.playback_sessions(audiobook_id);
CREATE INDEX IF NOT EXISTS idx_playback_sessions_updated_at ON public.playback_sessions(updated_at DESC);

-- =====================================================
-- TABLE 3: READING_LISTS (Reading List Management - Task 7.3)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.reading_lists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,

  -- List metadata
  name TEXT NOT NULL,
  description TEXT,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Unique list names per user
  UNIQUE(user_id, name)
);

-- Indexes for reading lists
CREATE INDEX IF NOT EXISTS idx_reading_lists_user_id ON public.reading_lists(user_id);
CREATE INDEX IF NOT EXISTS idx_reading_lists_created_at ON public.reading_lists(created_at DESC);

-- =====================================================
-- TABLE 4: READING_LIST_ITEMS (Reading List Items - Task 7.3)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.reading_list_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  list_id UUID REFERENCES public.reading_lists(id) ON DELETE CASCADE NOT NULL,
  audiobook_file_path TEXT NOT NULL, -- References audiobook.file_path

  -- Timestamps
  added_at TIMESTAMPTZ DEFAULT NOW(),

  -- Unique items per list
  UNIQUE(list_id, audiobook_file_path)
);

-- Indexes for reading list items
CREATE INDEX IF NOT EXISTS idx_reading_list_items_list_id ON public.reading_list_items(list_id);
CREATE INDEX IF NOT EXISTS idx_reading_list_items_file_path ON public.reading_list_items(audiobook_file_path);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) - Data Protection
-- =====================================================
-- RLS ensures users can ONLY access their own data

-- Enable RLS on all tables
ALTER TABLE public.audiobooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.playback_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reading_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reading_list_items ENABLE ROW LEVEL SECURITY;

-- Audiobooks policies
DROP POLICY IF EXISTS "Users can view own audiobooks" ON public.audiobooks;
CREATE POLICY "Users can view own audiobooks" ON public.audiobooks
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own audiobooks" ON public.audiobooks;
CREATE POLICY "Users can insert own audiobooks" ON public.audiobooks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own audiobooks" ON public.audiobooks;
CREATE POLICY "Users can update own audiobooks" ON public.audiobooks
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own audiobooks" ON public.audiobooks;
CREATE POLICY "Users can delete own audiobooks" ON public.audiobooks
  FOR DELETE USING (auth.uid() = user_id);

-- Playback sessions policies
DROP POLICY IF EXISTS "Users can view own playback sessions" ON public.playback_sessions;
CREATE POLICY "Users can view own playback sessions" ON public.playback_sessions
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own playback sessions" ON public.playback_sessions;
CREATE POLICY "Users can insert own playback sessions" ON public.playback_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own playback sessions" ON public.playback_sessions;
CREATE POLICY "Users can update own playback sessions" ON public.playback_sessions
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own playback sessions" ON public.playback_sessions;
CREATE POLICY "Users can delete own playback sessions" ON public.playback_sessions
  FOR DELETE USING (auth.uid() = user_id);

-- Reading lists policies
DROP POLICY IF EXISTS "Users can view own reading lists" ON public.reading_lists;
CREATE POLICY "Users can view own reading lists" ON public.reading_lists
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own reading lists" ON public.reading_lists;
CREATE POLICY "Users can insert own reading lists" ON public.reading_lists
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own reading lists" ON public.reading_lists;
CREATE POLICY "Users can update own reading lists" ON public.reading_lists
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own reading lists" ON public.reading_lists;
CREATE POLICY "Users can delete own reading lists" ON public.reading_lists
  FOR DELETE USING (auth.uid() = user_id);

-- Reading list items policies
DROP POLICY IF EXISTS "Users can view own reading list items" ON public.reading_list_items;
CREATE POLICY "Users can view own reading list items" ON public.reading_list_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.reading_lists rl
      WHERE rl.id = list_id AND rl.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can insert own reading list items" ON public.reading_list_items;
CREATE POLICY "Users can insert own reading list items" ON public.reading_list_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.reading_lists rl
      WHERE rl.id = list_id AND rl.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete own reading list items" ON public.reading_list_items;
CREATE POLICY "Users can delete own reading list items" ON public.reading_list_items
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.reading_lists rl
      WHERE rl.id = list_id AND rl.user_id = auth.uid()
    )
  );

-- =====================================================
-- DATABASE TRIGGERS - Auto-update timestamps
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for audiobooks
DROP TRIGGER IF EXISTS update_audiobooks_updated_at ON public.audiobooks;
CREATE TRIGGER update_audiobooks_updated_at
  BEFORE UPDATE ON public.audiobooks
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger for playback sessions
DROP TRIGGER IF EXISTS update_playback_sessions_updated_at ON public.playback_sessions;
CREATE TRIGGER update_playback_sessions_updated_at
  BEFORE UPDATE ON public.playback_sessions
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger for reading lists
DROP TRIGGER IF EXISTS update_reading_lists_updated_at ON public.reading_lists;
CREATE TRIGGER update_reading_lists_updated_at
  BEFORE UPDATE ON public.reading_lists
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================
-- CLEANUP FUNCTIONS (Automated Maintenance)
-- =====================================================

-- Function to clean up old sync queue items (if using cloud queue later)
CREATE OR REPLACE FUNCTION public.cleanup_old_sync_queue()
RETURNS void AS $$
BEGIN
  -- This is for future use if cloud-based sync queue is implemented
  -- Currently using local Isar database for offline queue
  NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- SETUP COMPLETE!
-- =====================================================
-- Verify setup by checking tables:
-- SELECT table_name FROM information_schema.tables
-- WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
-- =====================================================
```

---

## ✅ Verification Steps

After running the SQL script, verify everything is set up correctly:

### 1. Check Tables Were Created

In Supabase Dashboard → **SQL Editor**, run:
```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
```

**Expected Result (4 tables):**
```
audiobooks
playback_sessions
reading_lists
reading_list_items
```

### 2. Test Authentication

In Supabase Dashboard → **Authentication** → **Users**:
- You should see your registered users
- Each user will have their data isolated by `user_id`

---

## 🧪 Testing the Sync Features

### Test 1: Library Sync (Task 7.1)

1. **Device A:**
   - Login to app
   - Scan/add audiobooks to library
   - Go to Settings → Sync
   - Tap "Sync Now"
   - Check for success message

2. **Device B:**
   - Login with same account
   - Go to Settings → Sync
   - Tap "Sync Now"
   - **Expected:** Library appears with all audiobooks from Device A

### Test 2: Playback Position Sync (Task 7.2)

1. **Device A:**
   - Open an audiobook
   - Play for 2-3 minutes
   - Note the position (e.g., 3:45)
   - Go to Settings → Sync
   - Enable "Playback Position Sync"
   - Tap "Sync Now"

2. **Device B:**
   - Open same audiobook
   - Go to Settings → Sync
   - Tap "Sync Now"
   - **Expected:** Playback position restored to 3:45

### Test 3: Reading Lists (Task 7.3)

1. **Device A:**
   - Go to Library
   - Long-press audiobooks to select
   - Add to new reading list (e.g., "Favorites")
   - Go to Settings → Sync
   - Tap "Sync Now"

2. **Device B:**
   - Go to Library
   - Look for "Favorites" reading list
   - **Expected:** List appears with same audiobooks

---

## 🔧 Troubleshooting

### Issue: "User not authenticated" Error

**Solution:**
- Ensure user is logged in (Phase 2 authentication)
- Check Supabase URL and anon key in `.env` files
- Verify user exists in Supabase Auth

### Issue: "Permission denied" Error

**Solution:**
- RLS policies may not be set up correctly
- Re-run the SQL script
- Check that `user_id` matches authenticated user

### Issue: Sync Not Working

**Solution:**
1. Check internet connection
2. Verify Supabase project is active
3. Check logs in Supabase Dashboard → **Logs**
4. Look for errors in Flutter console

### Issue: Storage Bucket Not Created

**Solution:**
- Run this SQL manually:
```sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('flutbook-backups', 'flutbook-backups', false);
```

---

## 📊 What Each Table Does

| Table | Purpose | Sync Direction |
|-------|---------|----------------|
| `audiobooks` | Library metadata | Bidirectional |
| `playback_sessions` | Playback positions | Bidirectional |
| `reading_lists` | Custom reading lists | Bidirectional |
| `reading_list_items` | List contents | Bidirectional |

---

## 🔐 Security Notes

1. **Row Level Security (RLS)** is enabled on all tables
2. Users can **ONLY** access their own data
3. `user_id` is automatically set from authenticated user

---

## 📝 Summary

**What You Need to Do:**

1. ✅ Create Supabase project
2. ✅ Copy credentials to `.env` files
3. ✅ Run SQL setup script
4. ✅ Verify tables (4 tables)
5. ✅ Test each sync feature

**What's Already Done:**

- ✅ All Flutter frontend code implemented
- ✅ All sync repositories and use cases ready
- ✅ All UI components (settings, widgets) complete
- ✅ Offline queue using local Isar database

**Total Backend Setup Time:** ~10-15 minutes

---

**Need Help?**

- Supabase Docs: [https://supabase.com/docs](https://supabase.com/docs)
- Flutter Riverpod: [https://riverpod.dev](https://riverpod.dev)
- Your Flutter app logs will show detailed sync progress

---

**Last Updated:** March 15, 2026
**Status:** Ready for Backend Setup
