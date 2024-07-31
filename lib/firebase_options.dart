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
    apiKey: 'AIzaSyBT0-xoxzy9hE3kUcE9eN0ONZx9X7QFsjo',
    appId: '1:880473771126:web:dfa51e5fb4d528637c2357',
    messagingSenderId: '880473771126',
    projectId: 'agoravideocallapp-9c3c6',
    authDomain: 'agoravideocallapp-9c3c6.firebaseapp.com',
    storageBucket: 'agoravideocallapp-9c3c6.appspot.com',
    measurementId: 'G-VJ4BXNQKMD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB__d8L3DTIC7V6LllliBcaPqcFSjsN0LU',
    appId: '1:880473771126:android:69379463fca35e627c2357',
    messagingSenderId: '880473771126',
    projectId: 'agoravideocallapp-9c3c6',
    storageBucket: 'agoravideocallapp-9c3c6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBTBj-RQhmZVB5WFf3ZH7m_euGEHBwwdGg',
    appId: '1:880473771126:ios:28c649551f4d8eef7c2357',
    messagingSenderId: '880473771126',
    projectId: 'agoravideocallapp-9c3c6',
    storageBucket: 'agoravideocallapp-9c3c6.appspot.com',
    iosBundleId: 'com.example.agoraVideoVoiceCallApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBTBj-RQhmZVB5WFf3ZH7m_euGEHBwwdGg',
    appId: '1:880473771126:ios:28c649551f4d8eef7c2357',
    messagingSenderId: '880473771126',
    projectId: 'agoravideocallapp-9c3c6',
    storageBucket: 'agoravideocallapp-9c3c6.appspot.com',
    iosBundleId: 'com.example.agoraVideoVoiceCallApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBT0-xoxzy9hE3kUcE9eN0ONZx9X7QFsjo',
    appId: '1:880473771126:web:267795414553a3237c2357',
    messagingSenderId: '880473771126',
    projectId: 'agoravideocallapp-9c3c6',
    authDomain: 'agoravideocallapp-9c3c6.firebaseapp.com',
    storageBucket: 'agoravideocallapp-9c3c6.appspot.com',
    measurementId: 'G-BN0VE438HN',
  );
}