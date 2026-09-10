import 'package:cloud_firestore/cloud_firestore.dart';

/// 友達エントリ（users/{uid}/friends/{friendUserId} に保存）
class Friend {
  final String friendUserId;
  final String displayName;
  final int? grade;
  final DateTime addedAt;

  const Friend({
    required this.friendUserId,
    required this.displayName,
    this.grade,
    required this.addedAt,
  });

  factory Friend.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Friend(
      friendUserId: doc.id,
      displayName: data['displayName'] as String? ?? '名無しさん',
      grade: data['grade'] as int?,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'friendUserId': friendUserId,
    'displayName': displayName,
    'grade': grade,
    'addedAt': FieldValue.serverTimestamp(),
  };
}
