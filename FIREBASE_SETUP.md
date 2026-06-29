# Firebase Setup Guide

## Overview

This guide will help you set up Firebase and upload the initial data (47 prefectures + 92 quizzes) to your Firestore database.

## Step 1: Create a Firebase Project

### 1.1 Access Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Click on "Select a Project" at the top
3. Click "NEW PROJECT"
4. Enter project name: `social-quiz-app` (or your preferred name)
5. Click "CREATE"

### 1.2 Enable Firestore

1. In the Google Cloud Console, search for "Firestore" in the search bar
2. Click on "Firestore" in the results
3. Click "Create Database"
4. Choose "Start in production mode"
5. Select your region (e.g., `asia-northeast1` for Japan, `us-central1` for US)
6. Click "Create"
7. Wait for Firestore to initialize (this may take a few minutes)

## Step 2: Create a Service Account

### 2.1 Generate Service Account Key

1. In Google Cloud Console, go to **IAM & Admin** → **Service Accounts**
2. Click "Create Service Account"
3. Service account name: `firestore-upload` (or any name you prefer)
4. Click "Create and Continue"
5. Grant the following role: **Editor** (allows full access)
6. Click "Continue"
7. Click "Create Key" → **JSON** → **Create**
8. A JSON file will be downloaded automatically
9. Save this file securely — you'll use it in the next step

**⚠️ Important**: Keep this JSON key file safe. Never commit it to Git or share it publicly.

## Step 3: Upload Data to Firestore

### 3.1 Prerequisites

You'll need Python 3.7+ and the Firebase Admin SDK:

```bash
pip install firebase-admin
```

### 3.2 Prepare the Upload

1. Navigate to the project directory:
```bash
cd social_quiz_app
```

2. Verify that the data files exist:
   - `data/prefectures.json` (47 prefectures)
   - `data/quizzes.json` (92 quizzes)

### 3.3 Run the Upload Script

```bash
python scripts/upload_to_firestore.py \
  --credentials /path/to/your/downloaded/service-account-key.json \
  --verify
```

**Example** (Windows):
```bash
python scripts/upload_to_firestore.py `
  --credentials "C:\Users\YourName\Downloads\social-quiz-app-xxxxx.json" `
  --verify
```

**Example** (macOS/Linux):
```bash
python scripts/upload_to_firestore.py \
  --credentials ~/Downloads/social-quiz-app-xxxxx.json \
  --verify
```

### 3.4 Expected Output

If successful, you'll see:
```
✓ Connected to Firestore

📍 Uploading 47 prefectures...
  ✓ 北海道
  ✓ 青森
  ... (more prefectures)
✓ Successfully uploaded 47 prefectures

❓ Uploading 92 quizzes...
  ✓ hokkaido: 4 quizzes
  ✓ aomori: 2 quizzes
  ... (more prefectures)
✓ Successfully uploaded 92 quizzes

✓ Verifying upload...
  ✓ Prefectures in Firestore: 47
  ✓ Quizzes in Firestore: 92

✓ Data verification successful!

==================================================
✓ Upload completed successfully!
==================================================
```

## Step 4: Configure Flutter App

### 4.1 Add Firebase to Flutter

1. Install the Firebase CLI:
```bash
npm install -g firebase-tools
```

2. In the project directory, run:
```bash
flutterfire configure
```

3. This will:
   - Prompt you to select your Firebase project (`social-quiz-app`)
   - Create `google-services.json` (Android)
   - Create `GoogleService-Info.plist` (iOS)
   - Update `pubspec.yaml` with Firebase dependencies

### 4.2 Update pubspec.yaml

Make sure these dependencies are included:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.10.0
  cloud_firestore: ^4.8.0
  provider: ^6.0.0
  # ... other dependencies
```

Then run:
```bash
flutter pub get
```

## Step 5: Verify Firestore Rules (Optional)

For security, set up Firestore Rules. Go to Firestore Console → Rules and update:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow public read access to prefectures and quizzes
    match /prefectures/{document=**} {
      allow read: if true;
      allow write: if false;
    }
    match /quizzes/{document=**} {
      allow read: if true;
      allow write: if false;
    }
    
    // Allow authenticated users to read/write their own progress
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

## Step 6: Next Steps

Once data is uploaded, the Flutter app is ready for:

1. **Integration with Firestore** — Update `HomeScreen` and `QuizScreen` to fetch data from Firestore instead of hardcoded values
2. **User Progress Tracking** — Save user answers and progress to Firestore
3. **Authentication** — Add Google/Apple login (optional)
4. **Additional Features**:
   - Location-based distance display
   - Character/image collections
   - Video/site reference integration

## Troubleshooting

### Issue: "Missing scopes: [datastore]"

**Solution**: The service account doesn't have permission. Go to Google Cloud Console → IAM & Admin → Service Accounts → Click on your account → Add role "Editor"

### Issue: "Firestore database not found"

**Solution**: Make sure Firestore is created in your project. Check Google Cloud Console → Firestore → Database. If not created, follow Step 1.2.

### Issue: "Invalid credentials.json"

**Solution**: Make sure the JSON file path is correct and it's a valid service account key downloaded from Google Cloud Console.

### Issue: "Collections are empty" after upload

**Solution**: 
1. Check data files exist: `data/prefectures.json` and `data/quizzes.json`
2. Verify Firestore rules allow reads/writes (temporarily set to `allow read, write: if true;`)
3. Run upload again with `--verify` flag

## File Structure

```
social_quiz_app/
├── data/
│   ├── prefectures.json       ← 47 prefectures
│   └── quizzes.json           ← 92 quizzes
├── scripts/
│   └── upload_to_firestore.py ← Upload script
├── lib/
│   ├── models/
│   │   ├── prefecture.dart
│   │   └── quiz_question.dart
│   └── screens/
│       ├── home_screen.dart
│       └── quiz_screen.dart
└── FIREBASE_SETUP.md          ← This file
```

## Next Implementation: Flutter Integration

Once data is in Firestore, the next step is updating the Flutter app:

1. **Update HomeScreen**: Fetch user progress from Firestore
2. **Update QuizScreen**: Load quizzes from Firestore instead of hardcoded data
3. **Add UserProgress model**: Track which prefectures/quizzes user completed
4. **Add Firestore Service layer**: Create `services/firestore_service.dart` with methods like:
   - `getPrefectures()`
   - `getQuizzes(prefectureId)`
   - `getUserProgress(userId)`
   - `updateUserProgress(userId, progress)`

These steps will be handled in Phase 2 implementation.

---

**Questions?** Refer to:
- [Firebase Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Flutter Firebase Integration](https://firebase.flutter.dev/)
