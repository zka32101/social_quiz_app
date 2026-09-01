/// パフォーマンス最適化ユーティリティ

/// キャッシュバスター - 定期的な古いデータクリア
class CacheManager {
  static const int maxCacheAgeHours = 24;
  static const int maxNotifications = 100;
  static const int maxSessionHistory = 1000;

  /// キャッシュが古いかチェック（時間ベース）
  static bool isCacheExpired(DateTime cacheTime, {int hours = maxCacheAgeHours}) {
    final now = DateTime.now();
    return now.difference(cacheTime).inHours > hours;
  }

  /// 古いセッション履歴をクリア（保持期間: 30日）
  static List<T> pruneOldSessions<T extends {DateTime createdAt}>(
    List<T> sessions, {
    int retentionDays = 30,
  }) {
    final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));
    return sessions.where((s) => s.createdAt.isAfter(cutoffDate)).toList();
  }
}

/// クエリ最適化 - 大量データの効率的な処理
class QueryOptimizer {
  /// リストを効率的にフィルタリング（Oの計算量最小化）
  static List<T> efficientWhere<T>(
    List<T> items,
    bool Function(T) test,
  ) {
    return items.where(test).toList();
  }

  /// 大量データからページング用データを取得
  static List<T> paginate<T>(List<T> items, int page, int pageSize) {
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, items.length);

    if (startIndex >= items.length) return [];
    return items.sublist(startIndex, endIndex);
  }

  /// 重複を削除しながしながらソート
  static List<T> distinctAndSort<T extends Comparable<T>>(
    List<T> items, {
    required int Function(T a, T b) compare,
  }) {
    final set = <T>{};
    set.addAll(items);
    final list = set.toList();
    list.sort(compare);
    return list;
  }
}

/// メモリ最適化
class MemoryOptimizer {
  /// 大きなリストを処理（チャンク処理で避ける）
  static Iterable<List<T>> chunk<T>(List<T> list, int size) sync* {
    for (int i = 0; i < list.length; i += size) {
      final end = (i + size).clamp(0, list.length);
      yield list.sublist(i, end);
    }
  }

  /// 不要なデータをクリア
  static void clearIfNeeded<T>(List<T>? list, {int maxSize = 1000}) {
    if (list != null && list.length > maxSize) {
      list.removeRange(maxSize, list.length);
    }
  }
}

/// レート制限（API呼び出しなど）
class RateLimiter {
  final Map<String, DateTime> _lastCall = {};
  final int delayMilliseconds;

  RateLimiter({this.delayMilliseconds = 1000});

  /// 最後の呼び出しから十分な時間経過したか
  bool canProceed(String key) {
    final lastCall = _lastCall[key];
    if (lastCall == null) {
      _lastCall[key] = DateTime.now();
      return true;
    }

    if (DateTime.now().difference(lastCall).inMilliseconds >= delayMilliseconds) {
      _lastCall[key] = DateTime.now();
      return true;
    }

    return false;
  }

  /// キャッシュをクリア
  void clear() {
    _lastCall.clear();
  }
}

/// ストリーム最適化 - 不要な再構築を防ぐ
class StreamOptimizer {
  /// 連続した同じ値をフィルタリング
  static Stream<T> distinctUntilChanged<T>(Stream<T> stream) {
    return stream.distinct();
  }

  /// ストリーム出力をスロットル（N秒ごとに1回のみ）
  static Stream<T> throttle<T>(Stream<T> stream, Duration duration) async* {
    var lastEmit = DateTime.now().subtract(duration);

    await for (final item in stream) {
      if (DateTime.now().difference(lastEmit) >= duration) {
        yield item;
        lastEmit = DateTime.now();
      }
    }
  }
}
