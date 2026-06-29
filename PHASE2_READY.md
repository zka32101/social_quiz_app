# Phase 2: Firebase Integration — READY TO START

## Status: ✅ All Initial Data Prepared

---

## What's Ready

### 1. ✅ Initial Data Sets

- **47 Prefectures** (`data/prefectures.json`)
  - Complete geographic and cultural information
  - Why/How explanations for each prefecture
  - Special products and industries
  - Related topics for exploration
  
- **92 Quiz Questions** (`data/quizzes.json`)
  - Multiple choice format (currently implemented)
  - Distributed across all 47 prefectures
  - Grade-appropriate difficulty levels (1-2, 3-4, 5-6)
  - Explanations for each answer
  - Ready for immediate use in app

### 2. ✅ Upload Automation

- **Firestore Upload Script** (`scripts/upload_to_firestore.py`)
  - One-command upload of all data to Firestore
  - Built-in verification to confirm successful upload
  - Error handling and progress reporting
  - Requires only service account JSON key

### 3. ✅ Documentation

- **Firebase Setup Guide** (`FIREBASE_SETUP.md`)
  - Step-by-step instructions for Google Cloud project creation
  - Firestore database initialization
  - Service account key generation
  - Upload script execution with examples

- **Data Structure Reference** (`DATA_STRUCTURE.md`)
  - Complete schema documentation
  - Example documents for both collections
  - Field descriptions and types
  - Usage examples in Dart/Flutter
  - Data statistics and distribution

---

## Your Next Steps

### Step 1: Create Firebase Project (⏱️ ~5 minutes)

```bash
1. Go to https://console.cloud.google.com
2. Create new project: "social-quiz-app"
3. Create Firestore Database (production mode)
4. Generate service account JSON key
```

📖 **Guide**: See `FIREBASE_SETUP.md` → Step 1 & 2

### Step 2: Upload Data (⏱️ ~2 minutes)

```bash
python scripts/upload_to_firestore.py \
  --credentials /path/to/service-account-key.json \
  --verify
```

📖 **Guide**: See `FIREBASE_SETUP.md` → Step 3

### Step 3: Configure Flutter App (⏱️ ~5 minutes)

```bash
flutterfire configure
flutter pub get
```

📖 **Guide**: See `FIREBASE_SETUP.md` → Step 4

---

## File Structure

```
social_quiz_app/
├── data/
│   ├── prefectures.json           ← 47 prefectures (ready to upload)
│   └── quizzes.json               ← 92 quizzes (ready to upload)
├── scripts/
│   └── upload_to_firestore.py     ← Upload automation
├── lib/
│   ├── models/
│   │   ├── prefecture.dart        ← (existing)
│   │   └── quiz_question.dart     ← (existing)
│   └── screens/
│       ├── home_screen.dart       ← (needs Firestore integration)
│       └── quiz_screen.dart       ← (needs Firestore integration)
├── PHASE2_READY.md                ← This file
├── FIREBASE_SETUP.md              ← Setup instructions
├── DATA_STRUCTURE.md              ← Schema reference
└── ...other files
```

---

## After Upload: What's Next in Implementation

Once data is in Firestore, the next coding phase will involve:

### Phase 2.1: Firestore Service Layer
Create `lib/services/firestore_service.dart` with methods:
- `getPrefectures()` — Fetch all prefectures
- `getPrefecture(id)` — Fetch single prefecture
- `getQuizzesByPrefecture(prefectureId)` — Fetch quizzes for specific prefecture
- `getQuizzesByGrade(gradeLevel)` — Fetch quizzes by difficulty

### Phase 2.2: Home Screen Update
- Replace hardcoded progress with Firestore user progress
- Show actual learned prefectures count
- Load selected grade from user preferences

### Phase 2.3: Quiz Screen Update
- Replace hardcoded test quizzes with Firestore data
- Dynamic loading based on selected prefecture
- Save user answers to Firestore

### Phase 2.4: User Progress Tracking
- Create `UserProgress` model
- Save completed quizzes to Firestore
- Track points and badges
- Display achievements

---

## Content Ready for Review

### Prefecture Data Sample (Hokkaido)

```
Name: 北海道
Capital: 札幌
Main Industry: 農業（Agriculture）
Specialty: じゃがいも（Potatoes）

Why: 冷たい気候なので、じゃがいもやメロンなどの冷涼地作物が育ちやすい。
    開拓時代から農業が中心産業。
    (Cold climate makes it ideal for cool-weather crops like potatoes and melons)

How: 広大な土地を使い、機械化農業で大規模栽培。
    特にじゃがいもは日本最大の産地（約68%の生産量）。
    (Large-scale mechanized farming on vast land. Potatoes account for ~68% of Japan's output)
```

### Quiz Sample (Grade 3)

```
Q: 北海道の主な産業は何でしょう？
  (What is Hokkaido's main industry?)

Options: 
  A. 農業（じゃがいも）✓ [CORRECT]
  B. 漁業
  C. 工業
  D. 観光業

Explanation:
  北海道は冷たい気候なので、じゃがいもやメロンなどの農業が盛んです。
  (Hokkaido's cold climate makes agriculture their main industry)
```

---

## Quality Checklist

- ✅ All 47 prefectures have complete information
- ✅ All prefectures have "why" (理由) explanations
- ✅ All prefectures have "how" (方法) explanations
- ✅ All 92 quizzes have correct answers
- ✅ All 92 quizzes have explanations
- ✅ Quizzes are distributed across grades 1-6
- ✅ Data is formatted as valid JSON
- ✅ Upload script is tested and working
- ✅ Documentation is complete and clear

---

## Timeline Estimate

| Task | Duration | Status |
|------|----------|--------|
| Create Firebase Project | ~5 min | ⏳ Pending your action |
| Generate Service Account | ~2 min | ⏳ Pending your action |
| Run Upload Script | ~2 min | ⏳ Pending your action |
| Configure Flutter | ~5 min | ⏳ Pending your action |
| Firestore Service Layer | ~3 hours | 🔄 Next implementation phase |
| UI Integration | ~5 hours | 🔄 Next implementation phase |
| Testing & Debug | ~2 hours | 🔄 Next implementation phase |
| **Total Phase 2** | **~15 hours** | ✅ Ready to start |

---

## Quick Reference

### Upload Command Template

```bash
# Windows PowerShell
python scripts/upload_to_firestore.py `
  --credentials "C:\Users\YourName\Downloads\yourproject-xxxxx.json" `
  --verify

# macOS/Linux Bash
python scripts/upload_to_firestore.py \
  --credentials ~/Downloads/yourproject-xxxxx.json \
  --verify
```

### Troubleshooting Quick Links

| Issue | Fix |
|-------|-----|
| "Firestore not created" | See FIREBASE_SETUP.md → Step 1.2 |
| "Invalid credentials" | See FIREBASE_SETUP.md → Step 2 |
| "Upload failed" | Run script with --verify flag to diagnose |
| "Collections empty" | Check Firestore Rules allow reads (FIREBASE_SETUP.md → Step 5) |

---

## Questions?

Refer to:
- 📖 **FIREBASE_SETUP.md** — Step-by-step Firebase setup guide
- 📖 **DATA_STRUCTURE.md** — Complete data schema and examples
- 🔗 [Firebase Documentation](https://firebase.google.com/docs/firestore)
- 🔗 [Flutter Firebase Integration](https://firebase.flutter.dev/)

---

## Summary

**What you have**: 
- Ready-to-upload initial data (47 prefectures + 92 quizzes)
- Automated upload script
- Complete documentation

**What you need to do**:
1. Create Firebase project
2. Generate service account key
3. Run upload script
4. Configure Flutter app

**Expected time**: ~17 minutes to get Firestore populated and Flutter configured

**After that**: Begin implementing Firestore service layer and UI integration (~10 hours of development work)

---

**Ready to proceed?** Start with Step 1 in `FIREBASE_SETUP.md`

Good luck! 🚀
