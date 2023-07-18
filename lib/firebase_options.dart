// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAn056BbehHDlw-ZcC2cTPFmIyXZbsk6fY',
    appId: '1:736361702202:web:9538f19013d1d818cf2603',
    messagingSenderId: '736361702202',
    projectId: 'trytest-73b95',
    authDomain: 'trytest-73b95.firebaseapp.com',
    databaseURL: 'https://trytest-73b95-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'trytest-73b95.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_WNZ3NN-rCs5oDyA87ohtr3toHR4P0Cw',
    appId: '1:736361702202:android:fad841912990ee04cf2603',
    messagingSenderId: '736361702202',
    projectId: 'trytest-73b95',
    databaseURL: 'https://trytest-73b95-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'trytest-73b95.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB8t5wyNwphjdYD_jmKwab0syv2bQMItlI',
    appId: '1:736361702202:ios:924cc43f21ee1d40cf2603',
    messagingSenderId: '736361702202',
    projectId: 'trytest-73b95',
    databaseURL: 'https://trytest-73b95-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'trytest-73b95.appspot.com',
    iosClientId: '736361702202-r244dot4261q3aql9je1hnh0b4j95s4n.apps.googleusercontent.com',
    iosBundleId: 'com.example.trytest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB8t5wyNwphjdYD_jmKwab0syv2bQMItlI',
    appId: '1:736361702202:ios:924cc43f21ee1d40cf2603',
    messagingSenderId: '736361702202',
    projectId: 'trytest-73b95',
    databaseURL: 'https://trytest-73b95-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'trytest-73b95.appspot.com',
    iosClientId: '736361702202-r244dot4261q3aql9je1hnh0b4j95s4n.apps.googleusercontent.com',
    iosBundleId: 'com.example.trytest',
  );
}