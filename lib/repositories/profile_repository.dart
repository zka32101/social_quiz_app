import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile.dart';

class ProfileRepository {
  static const _boxName = 'profiles';
  static const _profileListKey = 'profile_list';
  static const _activeIdKey = 'active_id';

  Box get _box => Hive.box(_boxName);

  List<UserProfile> getAllProfiles() {
    final raw = _box.get(_profileListKey) as String?;
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  UserProfile createProfile(String name, String emoji) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final profile = UserProfile(
      id: id,
      name: name,
      emoji: emoji,
      createdAt: DateTime.now().toIso8601String(),
    );
    final profiles = getAllProfiles()..add(profile);
    _box.put(_profileListKey, jsonEncode(profiles.map((p) => p.toJson()).toList()));
    return profile;
  }

  void deleteProfile(String id) {
    final profiles = getAllProfiles().where((p) => p.id != id).toList();
    _box.put(_profileListKey, jsonEncode(profiles.map((p) => p.toJson()).toList()));
    // Also close/delete the progress box for this profile
    final progressBoxName = 'profile_$id';
    if (Hive.isBoxOpen(progressBoxName)) {
      Hive.box(progressBoxName).deleteFromDisk();
    }
    // Clear active_id if it matched the deleted profile
    if (getActiveProfileId() == id) {
      _box.delete(_activeIdKey);
    }
  }

  String? getActiveProfileId() {
    return _box.get(_activeIdKey) as String?;
  }

  void setActiveProfileId(String id) {
    _box.put(_activeIdKey, id);
  }
}

// Providers

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profilesProvider = Provider<List<UserProfile>>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getAllProfiles();
});

/// アクティブなプロフィールIDを保持する StateProvider
/// プロフィール選択時に更新することで progress を自動的にリフレッシュする
final activeProfileIdProvider = StateProvider<String?>((ref) {
  return Hive.box('profiles').get('active_id') as String?;
});

/// プロフィール用 Hive ボックスを開く
Future<void> openProfileBox(String profileId) async {
  final boxName = 'profile_$profileId';
  if (!Hive.isBoxOpen(boxName)) {
    await Hive.openBox(boxName);
  }
}
