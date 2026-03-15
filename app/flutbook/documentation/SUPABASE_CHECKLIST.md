# 📋 Supabase Backend Setup Checklist

**Quick reference guide for setting up Phase 7 sync backend**

---

## ✅ Pre-Setup Checklist

- [ ] Have a Supabase account (create at supabase.com)
- [ ] Have a Supabase project created
- [ ] Have project URL and anon key copied
- [ ] Have access to Flutter project files
- [ ] Have access to Supabase SQL Editor

**Note:** Audio files are NOT synced or backed up. Only metadata (audiobook info, playback positions, reading lists) is synced.

---

## 🚀 Setup Steps (10-15 minutes)

### Step 1: Update Environment Files (2 min)

**File: `.env.development`**
```env
SUPABASE_URL=https://YOUR-PROJECT-ID.supabase.co
SUPABASE_ANON_KEY=YOUR-ANON-KEY-HERE
```

**File: `.env.staging`** (same values)
```env
SUPABASE_URL=https://YOUR-PROJECT-ID.supabase.co
SUPABASE_ANON_KEY=YOUR-ANON-KEY-HERE
```

**File: `.env.production`** (same values for now)
```env
SUPABASE_URL=https://YOUR-PROJECT-ID.supabase.co
SUPABASE_ANON_KEY=YOUR-ANON-KEY-HERE
```

---

### Step 2: Run SQL Setup Script (10 min)

1. Open Supabase Dashboard
2. Go to **SQL Editor** (left sidebar)
3. Click **"New Query"**
4. Copy SQL from `SUPABASE_SETUP_COMPLETE.md`
5. Paste into editor
6. Click **"Run"**
7. Wait for success message

**Expected Output:**
```
Success. No rows returned
```

---

### Step 3: Verify Setup (3 min)

**Check Tables:**
```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';
```

**Expected (4 tables):**
- ✅ audiobooks
- ✅ playback_sessions
- ✅ reading_lists
- ✅ reading_list_items

---

### Step 4: Test in Flutter App (5 min)

1. **Rebuild Flutter app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Login to app** (use existing auth)

3. **Test Library Sync:**
   - Go to Settings → Sync
   - Tap "Sync Now"
   - Should show "Synced" status

4. **Test Playback Sync:**
   - Play an audiobook for 1 minute
   - Go to Settings → Sync
   - Enable "Playback Position Sync"
   - Should show last sync time

---

## 🎯 What Each Feature Does

### Task 7.1: Library Sync
- **What:** Sync audiobook library across devices
- **Table:** `audiobooks`
- **UI:** Settings → Sync → "Sync Now"
- **Test:** Add book on Device A → Sync on Device B

### Task 7.2: Playback Position Sync
- **What:** Remember where you left off
- **Table:** `playback_sessions`
- **UI:** Settings → Sync → "Enable Playback Sync"
- **Test:** Play on Device A → Resume on Device B at same position

### Task 7.3: Reading Lists
- **What:** Create custom audiobook lists
- **Tables:** `reading_lists`, `reading_list_items`
- **UI:** Library → Add to List
- **Test:** Create list on Device A → See on Device B

### Task 7.5: Offline Queue
- **What:** Queue operations when offline
- **Storage:** Local Isar database (no backend needed)
- **UI:** Settings → Sync → Shows pending count
- **Test:** Enable airplane mode → Add book → Disable airplane mode → Sync

---

## ⚠️ Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| "User not authenticated" | Check login, verify `.env` credentials |
| "Permission denied" | Re-run SQL script, check RLS policies |
| Sync button greyed out | Check internet connection |
| No tables in database | Run SQL script in SQL Editor |

---

## 📊 Database Schema Overview

```
audiobooks
├── id (UUID, PK)
├── user_id (UUID, FK → auth.users)
├── title, author, album
├── file_path, duration_ms, total_size
├── last_played_at, completed
└── created_at, updated_at

playback_sessions
├── id (UUID, PK)
├── user_id (UUID, FK → auth.users)
├── audiobook_id (UUID, FK → audiobooks)
├── current_position_ms, playback_speed
├── sleep_timer_active, sleep_timer_duration_ms
└── last_played_at, created_at, updated_at

reading_lists
├── id (UUID, PK)
├── user_id (UUID, FK → auth.users)
├── name, description
└── created_at, updated_at

reading_list_items
├── id (UUID, PK)
├── list_id (UUID, FK → reading_lists)
├── audiobook_file_path (TEXT)
└── added_at
```

---

## 🔐 Security

- ✅ Row Level Security (RLS) enabled on ALL tables
- ✅ Users can ONLY see their own data
- ✅ `user_id` automatically set from auth

---

## 📝 Next Steps After Setup

1. **Test all sync features** with 2+ devices
2. **Monitor database usage** in Supabase Dashboard
3. **Enable Supabase Realtime** for instant sync (optional enhancement)

---

## 📚 Documentation Files

- `SUPABASE_SETUP_COMPLETE.md` - Complete setup guide with SQL script
- `PHASE_7_VERIFICATION_AND_SETUP.md` - Verification + setup (older version)
- `CURRENT_PROGRESS.txt` - Overall project status

---

**Estimated Total Time:** 10-15 minutes
**Difficulty:** Easy (copy-paste SQL)
**Status:** Ready to start

---

**Last Updated:** March 15, 2026
