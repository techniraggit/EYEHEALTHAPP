// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyBzlHOD330uFswT-xlTfeirQKE6qfrgIlA',
    appId: '1:513781665335:web:1a5acd95569ba69c10b9b2',
    messagingSenderId: '513781665335',
    projectId: 'eye-health-application',
    authDomain: 'eye-health-application.firebaseapp.com',
    storageBucket: 'eye-health-application.appspot.com',
    measurementId: 'G-1T0N97WQR4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJN2md56_PLTHX_YN8FdB0wtWYZLOV0v8',
    appId: '1:513781665335:android:53a2bc55c510e19110b9b2',
    messagingSenderId: '513781665335',
    projectId: 'eye-health-application',
    storageBucket: 'eye-health-application.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAEhR3eaBYRiAQX0O5zdez3U0VkxzJvenI',
    appId: '1:513781665335:ios:b876ab4114aefb4810b9b2',
    messagingSenderId: '513781665335',
    projectId: 'eye-health-application',
    storageBucket: 'eye-health-application.appspot.com',
    iosBundleId: 'com.example.projectNew',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAEhR3eaBYRiAQX0O5zdez3U0VkxzJvenI',
    appId: '1:513781665335:ios:b876ab4114aefb4810b9b2',
    messagingSenderId: '513781665335',
    projectId: 'eye-health-application',
    storageBucket: 'eye-health-application.appspot.com',
    iosBundleId: 'com.example.projectNew',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBzlHOD330uFswT-xlTfeirQKE6qfrgIlA',
    appId: '1:513781665335:web:5463baff283f06a510b9b2',
    messagingSenderId: '513781665335',
    projectId: 'eye-health-application',
    authDomain: 'eye-health-application.firebaseapp.com',
    storageBucket: 'eye-health-application.appspot.com',
    measurementId: 'G-2PX0F5J0PC',
  );
}