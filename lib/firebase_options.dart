import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCjpHo46GeJzN_TMINl1eaMNJet3QFXr_U',
    appId: '1:906257233334:android:6a2f351f128021f01ffd17',
    messagingSenderId: '906257233334',
    projectId: 'kore1-6b58e',
    storageBucket: 'kore1-6b58e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyIOSApiKey1234567890',
    appId: '1:123456789:ios:abcdef1234567890abcdef',
    messagingSenderId: '123456789',
    projectId: 'social-quiz-app-dummy',
    storageBucket: 'social-quiz-app-dummy.appspot.com',
    iosBundleId: 'com.example.socialQuizApp',
  );
}
