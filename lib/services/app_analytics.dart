import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// 利用状況の計測(どの画面で離れたかを知るため)。
/// 送るのは画面の名前だけ。氏名・ID・広告IDなど個人を特定する値は送らない。
/// Firebase が使えない場合(初期化失敗・未設定)は、何もせず静かに終わる。
class AppAnalytics {
  AppAnalytics._();

  /// Navigator / GoRouter に渡す。画面名のある遷移だけを記録する。
  static final NavigatorObserver observer = _ScreenObserver();

  static Future<void> logScreen(String? name) async {
    if (name == null || name.isEmpty || name == '/') return;
    try {
      await FirebaseAnalytics.instance.logScreenView(screenName: name);
    } catch (e) {
      if (kDebugMode) debugPrint('[Analytics] 画面記録をスキップ: $e');
    }
  }
}

class _ScreenObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) AppAnalytics.logScreen(route.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute is PageRoute) AppAnalytics.logScreen(newRoute.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute is PageRoute) {
      AppAnalytics.logScreen(previousRoute.settings.name);
    }
  }
}
