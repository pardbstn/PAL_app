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
    apiKey: 'AIzaSyDT57R-5SuV9_pET4Amzlf94liMwxd7b-0',
    appId: '1:944944117072:android:baf2d7a2b3f269b0fe6855',
    messagingSenderId: '944944117072',
    projectId: 'ptmate-1a542',
    storageBucket: 'ptmate-1a542.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAAoI7BXJpuUzDzNtvtiJLMZ3aUaNQKgOI',
    appId: '1:944944117072:ios:abaddf36fd67718ffe6855',
    messagingSenderId: '944944117072',
    projectId: 'ptmate-1a542',
    storageBucket: 'ptmate-1a542.firebasestorage.app',
    iosClientId: '944944117072-94ipnautubi9do1b3di8toc5o06cc8nk.apps.googleusercontent.com',
    iosBundleId: 'com.yl.palapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAAoI7BXJpuUzDzNtvtiJLMZ3aUaNQKgOI',
    appId: '1:944944117072:ios:5ceb790c6daefcedfe6855',
    messagingSenderId: '944944117072',
    projectId: 'ptmate-1a542',
    storageBucket: 'ptmate-1a542.firebasestorage.app',
    iosClientId: '944944117072-01fc638110adrcu87g4g4hdcve01m4fl.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterPalApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD7Ln2IRAQpeqMKllJQns0p4b87-Ew7IU8',
    appId: '1:944944117072:web:18d6bda4e8d37c50fe6855',
    messagingSenderId: '944944117072',
    projectId: 'ptmate-1a542',
    authDomain: 'ptmate-1a542.firebaseapp.com',
    storageBucket: 'ptmate-1a542.firebasestorage.app',
    measurementId: 'G-BE1SM9ZVH2',
  );

}