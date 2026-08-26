# R8/ProGuard rules for release builds (isMinifyEnabled = true).
#
# This app doesn't use runtime reflection for JSON/DB serialization
# (no @HiveType/TypeAdapter classes, no json_serializable codegen — Hive is
# used only for primitive key/value storage, and JSON is decoded manually
# via dart:convert), so the usual "my model classes got obfuscated and
# fromJson broke" failure mode for R8 doesn't apply here.
#
# The rules below are the standard, widely-documented keep rules for the
# native/Java-side plugins this app uses that are known to need them.
# Most modern Flutter plugins (Firebase, RevenueCat, etc.) already ship
# their own consumer ProGuard rules bundled in their AAR, so this file is
# a conservative safety net on top of those, not a replacement for them.

# Flutter embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase (firebase_core / firebase_auth / cloud_firestore / firebase_messaging /
# firebase_remote_config) — keep model classes constructed via reflection.
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Core (referenced by the Flutter engine's deferred-components
# support even when unused; missing classes here are a common R8 failure
# mode for Flutter apps that enable minification).
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Hive (box storage only in this app, but keep its runtime classes safe regardless)
-keep class hive.** { *; }
-dontwarn hive.**
