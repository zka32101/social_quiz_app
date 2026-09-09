import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend_model.dart';

/// 友達関係を管理するサービス
///
/// users/{userId} ドキュメントは本人のみ読み書き可能なため、友達を検索・
/// 追加する際は誰でも読み取れる leaderboards/global/entries/{userId} を
/// 参照して displayName・grade を取得する（公開用の最小限の情報のみ）。
/// 友達一覧自体は users/{userId}/friends/{friendUserId} に保存し、
/// 本人のみ読み書きできる（firestore.rules 参照）。
class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _friendsRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friends');
  }

  /// 自分の招待用ユーザーID（友達に共有してもらう文字列）
  String? get myUserId => _auth.currentUser?.uid;

  /// 友達一覧を取得
  Future<List<Friend>> getFriends() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _friendsRef(userId).get();
    return snapshot.docs.map((doc) => Friend.fromFirestore(doc)).toList();
  }

  /// 招待コード（ユーザーID）を指定して友達を追加
  ///
  /// - 自分自身のIDは追加不可
  /// - 相手のランキングエントリ（公開情報）が存在しない場合は追加不可
  /// 戻り値: 追加した Friend。失敗時は例外を投げる（呼び出し側でメッセージ表示）
  Future<Friend> addFriendByUserId(String friendUserId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw FriendServiceException('ログインが必要です');
    }

    final trimmedId = friendUserId.trim();
    if (trimmedId.isEmpty) {
      throw FriendServiceException('招待コードを入力してください');
    }
    if (trimmedId == userId) {
      throw FriendServiceException('自分自身は追加できません');
    }

    // 公開ランキングエントリから相手の情報を取得（存在確認も兼ねる）
    final entryDoc = await _firestore
        .collection('leaderboards/global/entries')
        .doc(trimmedId)
        .get();

    if (!entryDoc.exists) {
      throw FriendServiceException('見つかりませんでした。招待コードを確認してください');
    }

    final data = entryDoc.data() ?? {};
    final displayName = data['displayName'] as String? ?? '名無しさん';
    final grade = data['grade'] as int?;

    final friend = Friend(
      friendUserId: trimmedId,
      displayName: displayName,
      grade: grade,
      addedAt: DateTime.now(),
    );

    await _friendsRef(userId).doc(trimmedId).set(friend.toFirestore());
    return friend;
  }

  /// 友達を削除
  Future<void> removeFriend(String friendUserId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _friendsRef(userId).doc(friendUserId).delete();
  }
}

class FriendServiceException implements Exception {
  final String message;
  FriendServiceException(this.message);

  @override
  String toString() => message;
}
