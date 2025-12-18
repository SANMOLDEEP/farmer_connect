// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ✅ CORRECTED - Using values from your google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCpFzQdtf_zV9EwTAfxiJd1lNZ1MsbTLeY',
    appId: '1:681717152867:android:cb79b3b22e6a9c70d84c56',
    messagingSenderId: '681717152867',
    projectId: 'kisanseva-ac3dc',
    storageBucket: 'kisanseva-ac3dc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',  // You'll need to get this from Firebase Console for iOS
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '681717152867',
    projectId: 'kisanseva-ac3dc',
    storageBucket: 'kisanseva-ac3dc.firebasestorage.app',
    iosBundleId: 'com.example.kisansevaMo',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',  // You'll need to get this from Firebase Console for Web
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: '681717152867',
    projectId: 'kisanseva-ac3dc',
    authDomain: 'kisanseva-ac3dc.firebaseapp.com',
    storageBucket: 'kisanseva-ac3dc.firebasestorage.app',
  );
}