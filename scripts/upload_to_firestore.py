#!/usr/bin/env python3
"""
Firestore Data Upload Script
Uploads prefecture and quiz data from JSON files to Firestore database.

Usage:
    python upload_to_firestore.py --credentials path/to/service-account-key.json

Before running:
    1. Create a Firebase project in Google Cloud Console
    2. Initialize Firestore Database (production mode)
    3. Create a service account and download the JSON key
    4. Set the path to that key in the --credentials argument
"""

import json
import argparse
import sys
from pathlib import Path
from typing import Dict, List, Any, Optional

try:
    import firebase_admin
    from firebase_admin import credentials
    from firebase_admin import firestore
except ImportError:
    print("❌ Firebase Admin SDK not installed.")
    print("Install it with: pip install firebase-admin")
    sys.exit(1)


class FirestoreUploader:
    """Handles uploading data to Firestore."""

    def __init__(self, credentials_path: str):
        """
        Initialize Firestore connection.

        Args:
            credentials_path: Path to service account JSON key
        """
        try:
            cred = credentials.Certificate(credentials_path)
            firebase_admin.initialize_app(cred)
            self.db = firestore.client()
            print("✓ Connected to Firestore")
        except Exception as e:
            print(f"❌ Failed to initialize Firebase: {e}")
            sys.exit(1)

    def upload_prefectures(self, prefectures_file: str) -> bool:
        """
        Upload prefecture data to Firestore.

        Args:
            prefectures_file: Path to prefectures.json

        Returns:
            True if successful, False otherwise
        """
        try:
            with open(prefectures_file, 'r', encoding='utf-8') as f:
                prefectures = json.load(f)

            print(f"\n📍 Uploading {len(prefectures)} prefectures...")

            for prefecture in prefectures:
                doc_id = prefecture['id']
                self.db.collection('prefectures').document(doc_id).set(prefecture)
                print(f"  ✓ {prefecture['name']}")

            print(f"✓ Successfully uploaded {len(prefectures)} prefectures")
            return True

        except FileNotFoundError:
            print(f"❌ File not found: {prefectures_file}")
            return False
        except json.JSONDecodeError:
            print(f"❌ Invalid JSON in {prefectures_file}")
            return False
        except Exception as e:
            print(f"❌ Error uploading prefectures: {e}")
            return False

    def upload_quizzes(self, quizzes_file: str) -> bool:
        """
        Upload quiz data to Firestore.

        Args:
            quizzes_file: Path to quizzes.json

        Returns:
            True if successful, False otherwise
        """
        try:
            with open(quizzes_file, 'r', encoding='utf-8') as f:
                quizzes = json.load(f)

            print(f"\n❓ Uploading {len(quizzes)} quizzes...")

            # Group quizzes by prefecture for progress tracking
            quizzes_by_prefecture = {}
            for quiz in quizzes:
                prefecture = quiz.get('prefectureId', 'unknown')
                if prefecture not in quizzes_by_prefecture:
                    quizzes_by_prefecture[prefecture] = 0
                quizzes_by_prefecture[prefecture] += 1

            for quiz in quizzes:
                doc_id = quiz['id']
                self.db.collection('quizzes').document(doc_id).set(quiz)

            # Print summary by prefecture
            for prefecture in sorted(quizzes_by_prefecture.keys()):
                count = quizzes_by_prefecture[prefecture]
                print(f"  ✓ {prefecture}: {count} quizzes")

            print(f"✓ Successfully uploaded {len(quizzes)} quizzes")
            return True

        except FileNotFoundError:
            print(f"❌ File not found: {quizzes_file}")
            return False
        except json.JSONDecodeError:
            print(f"❌ Invalid JSON in {quizzes_file}")
            return False
        except Exception as e:
            print(f"❌ Error uploading quizzes: {e}")
            return False

    def verify_upload(self) -> bool:
        """
        Verify that data was uploaded correctly.

        Returns:
            True if verification passed, False otherwise
        """
        try:
            print("\n✓ Verifying upload...")

            # Check prefectures
            prefectures = self.db.collection('prefectures').stream()
            prefecture_count = sum(1 for _ in prefectures)
            print(f"  ✓ Prefectures in Firestore: {prefecture_count}")

            # Check quizzes
            quizzes = self.db.collection('quizzes').stream()
            quiz_count = sum(1 for _ in quizzes)
            print(f"  ✓ Quizzes in Firestore: {quiz_count}")

            if prefecture_count > 0 and quiz_count > 0:
                print("\n✓ Data verification successful!")
                return True
            else:
                print("\n❌ Data verification failed - collections are empty")
                return False

        except Exception as e:
            print(f"❌ Error verifying data: {e}")
            return False


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Upload prefecture and quiz data to Firestore'
    )
    parser.add_argument(
        '--credentials',
        required=True,
        help='Path to Firebase service account JSON key'
    )
    parser.add_argument(
        '--prefectures',
        default='data/prefectures.json',
        help='Path to prefectures.json (default: data/prefectures.json)'
    )
    parser.add_argument(
        '--quizzes',
        default='data/quizzes.json',
        help='Path to quizzes.json (default: data/quizzes.json)'
    )
    parser.add_argument(
        '--verify',
        action='store_true',
        help='Verify data after upload'
    )

    args = parser.parse_args()

    # Verify credentials file exists
    if not Path(args.credentials).exists():
        print(f"❌ Credentials file not found: {args.credentials}")
        sys.exit(1)

    # Initialize uploader
    uploader = FirestoreUploader(args.credentials)

    # Upload data
    success = True
    success = uploader.upload_prefectures(args.prefectures) and success
    success = uploader.upload_quizzes(args.quizzes) and success

    # Verify if requested
    if args.verify and success:
        success = uploader.verify_upload()

    if success:
        print("\n" + "="*50)
        print("✓ Upload completed successfully!")
        print("="*50)
        sys.exit(0)
    else:
        print("\n" + "="*50)
        print("❌ Upload failed - check errors above")
        print("="*50)
        sys.exit(1)


if __name__ == '__main__':
    main()
