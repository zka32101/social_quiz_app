import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend_model.dart';
import '../services/friend_service.dart';

final friendServiceProvider = Provider<FriendService>((ref) {
  return FriendService();
});

/// 友達一覧（FutureProvider。追加・削除後は invalidate して再取得する）
final friendsProvider = FutureProvider<List<Friend>>((ref) async {
  final service = ref.watch(friendServiceProvider);
  return service.getFriends();
});
