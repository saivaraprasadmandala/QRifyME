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
    apiKey: 'AIzaSyDPxaWguBt60IKlGuP3HqsSm_Fhb8Kfojs',
    appId: '1:873988135049:web:623155b3ac84cfc230ce58',
    messagingSenderId: '873988135049',
    projectId: 'event-tracker-d2259',
    authDomain: 'event-tracker-d2259.firebaseapp.com',
    storageBucket: 'event-tracker-d2259.appspot.com',
    measurementId: 'G-YT16RQ0SPR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCeB7rCYF7I9zFd4V8Beo3BgBRPVaYo7TY',
    appId: '1:873988135049:android:bdd0752cee62b2c130ce58',
    messagingSenderId: '873988135049',
    projectId: 'event-tracker-d2259',
    storageBucket: 'event-tracker-d2259.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBgd0f5R8vPcXzDAQ5mhVSRYrhs98N1ZIY',
    appId: '1:873988135049:ios:b184eed997c054c330ce58',
    messagingSenderId: '873988135049',
    projectId: 'event-tracker-d2259',
    storageBucket: 'event-tracker-d2259.appspot.com',
    iosClientId: '873988135049-ngjtltmisduu8cto3co1ot87f3u2ol0m.apps.googleusercontent.com',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBgd0f5R8vPcXzDAQ5mhVSRYrhs98N1ZIY',
    appId: '1:873988135049:ios:b184eed997c054c330ce58',
    messagingSenderId: '873988135049',
    projectId: 'event-tracker-d2259',
    storageBucket: 'event-tracker-d2259.appspot.com',
    iosClientId: '873988135049-ngjtltmisduu8cto3co1ot87f3u2ol0m.apps.googleusercontent.com',
    iosBundleId: 'com.example.app',
  );
}
