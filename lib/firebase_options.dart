import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBYDGOHarramDyrCbXALjDi-RophBo3k8I',
    appId: '1:140008748323:web:8bf7ad31800c9164c40896',
    messagingSenderId: '140008748323',
    projectId: 'personal-finance-app-93904',
    storageBucket: 'personal-finance-app-93904.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBYDGOHarramDyrCbXALjDi-RophBo3k8I',
    appId: '1:140008748323:web:8bf7ad31800c9164c40896',
    messagingSenderId: '140008748323',
    projectId: 'personal-finance-app-93904',
    storageBucket: 'personal-finance-app-93904.firebasestorage.app',
  );
}