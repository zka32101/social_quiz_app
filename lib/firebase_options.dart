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
    apiKey: 'AIzaSyDummyAndroidApiKey1234567890',
    appId: '1:123456789:android:abcdef1234567890abcdef',
    messagingSenderId: '123456789',
    projectId: 'social-quiz-app-dummy',
    storageBucket: 'social-quiz-app-dummy.appspot.com',
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
