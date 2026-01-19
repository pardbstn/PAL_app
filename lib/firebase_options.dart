// File generated manually for Firebase configuration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD7Ln2IRAQpeqMKllJQns0p4b87-Ew7IU8',
    appId: '1:944944117072:web:2e079eae2512b578fe6855',
    messagingSenderId: '944944117072',
    projectId: 'ptmate-1a542',
    authDomain: 'ptmate-1a542.firebaseapp.com',
    storageBucket: 'ptmate-1a542.firebasestorage.app',
    measurementId: 'G-5XMZZTBTEP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD7Ln2IRAQpeqMKllJQns0p4b87-Ew7IU8',
    appId: '1:944944117072:android:fe6855', // TODO: Firebase Console에서 Android 앱 ID 확인 필요
    messagingSenderId: '944944117072',
    projectId: 'ptmate-1a542',
    storageBucket: 'ptmate-1a542.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD7Ln2IRAQpeqMKllJQns0p4b87-Ew7IU8',
    appId: '1:944944117072:ios:a226ab80f705c6dcfe6855',
    messagingSenderId: '944944117072',
    projectId: 'ptmate-1a542',
    storageBucket: 'ptmate-1a542.firebasestorage.app',
    iosBundleId: 'com.pal.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD7Ln2IRAQpeqMKllJQns0p4b87-Ew7IU8',
    appId: '1:944944117072:ios:a226ab80f705c6dcfe6855',
    messagingSenderId: '944944117072',
    projectId: 'ptmate-1a542',
    storageBucket: 'ptmate-1a542.firebasestorage.app',
    iosBundleId: 'com.pal.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD7Ln2IRAQpeqMKllJQns0p4b87-Ew7IU8',
    appId: '1:944944117072:web:2e079eae2512b578fe6855',
    messagingSenderId: '944944117072',
    projectId: 'ptmate-1a542',
    authDomain: 'ptmate-1a542.firebaseapp.com',
    storageBucket: 'ptmate-1a542.firebasestorage.app',
    measurementId: 'G-5XMZZTBTEP',
  );
}
