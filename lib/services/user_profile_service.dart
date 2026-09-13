import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Update the isNamePublic setting in Firestore
  ///
  /// This setting is synced to the users/{userId} document so that
  /// ranking entries can read it to determine if the user's name should
  /// be displayed in rankings.
  Future<void> updateNamePublicSetting(bool isNamePublic) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).set({
      'isNamePublic': isNamePublic,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
