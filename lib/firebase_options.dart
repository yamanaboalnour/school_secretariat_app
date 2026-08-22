import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _storageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  static FirebaseOptions get currentPlatform {
    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.windows) {
      throw UnsupportedError(
        'Firebase غير مهيأ لهذه المنصة. استخدم إعدادات Firebase الرسمية.',
      );
    }
    if (_apiKey.isEmpty ||
        _appId.isEmpty ||
        _messagingSenderId.isEmpty ||
        _projectId.isEmpty) {
      throw StateError(
        'أضف FIREBASE_API_KEY وFIREBASE_APP_ID و'
        'FIREBASE_MESSAGING_SENDER_ID وFIREBASE_PROJECT_ID عبر dart-define.',
      );
    }
    return FirebaseOptions(
      apiKey: _apiKey,
      appId: _appId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      storageBucket: _storageBucket.isEmpty ? null : _storageBucket,
    );
  }
}
