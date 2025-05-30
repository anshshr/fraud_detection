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
    apiKey: 'AIzaSyCmNCIUpRubTB9FZK3hp9W3D2YbOkNUV9c',
    appId: '1:63428814218:web:d9dcd78a9fd3fe27129473',
    messagingSenderId: '63428814218',
    projectId: 'frauddetection-9a31d',
    authDomain: 'frauddetection-9a31d.firebaseapp.com',
    storageBucket: 'frauddetection-9a31d.firebasestorage.app',
    measurementId: 'G-6CG131D7T7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBbhRK9DYTVsbMf6pAy3z1PNDjHPZIu2SE',
    appId: '1:63428814218:android:f1e6a70400941d74129473',
    messagingSenderId: '63428814218',
    projectId: 'frauddetection-9a31d',
    storageBucket: 'frauddetection-9a31d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAxpTg4s1vDKaAMyGCe5O3bX_wOGt1FFRE',
    appId: '1:63428814218:ios:1889487bdebe75f9129473',
    messagingSenderId: '63428814218',
    projectId: 'frauddetection-9a31d',
    storageBucket: 'frauddetection-9a31d.firebasestorage.app',
    androidClientId: '63428814218-1rr2g8no3h5uui73lsf0o2e9omo1hkmn.apps.googleusercontent.com',
    iosClientId: '63428814218-k5apica7r12dssa14qa6skraq5i2p21u.apps.googleusercontent.com',
    iosBundleId: 'com.example.fraudDetection',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAxpTg4s1vDKaAMyGCe5O3bX_wOGt1FFRE',
    appId: '1:63428814218:ios:1889487bdebe75f9129473',
    messagingSenderId: '63428814218',
    projectId: 'frauddetection-9a31d',
    storageBucket: 'frauddetection-9a31d.firebasestorage.app',
    androidClientId: '63428814218-1rr2g8no3h5uui73lsf0o2e9omo1hkmn.apps.googleusercontent.com',
    iosClientId: '63428814218-k5apica7r12dssa14qa6skraq5i2p21u.apps.googleusercontent.com',
    iosBundleId: 'com.example.fraudDetection',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCmNCIUpRubTB9FZK3hp9W3D2YbOkNUV9c',
    appId: '1:63428814218:web:e4054c35f22767a8129473',
    messagingSenderId: '63428814218',
    projectId: 'frauddetection-9a31d',
    authDomain: 'frauddetection-9a31d.firebaseapp.com',
    storageBucket: 'frauddetection-9a31d.firebasestorage.app',
    measurementId: 'G-GT2YZND3N8',
  );

}