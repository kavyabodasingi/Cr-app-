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
    apiKey: 'AIzaSyCinDHgC0emxsjHKVRDqBGo7M2i65da48I',
    appId: '1:576736049563:web:0636bd2b369610f266093e',
    messagingSenderId: '576736049563',
    projectId: 'simple-cbfcb',
    authDomain: 'simple-cbfcb.firebaseapp.com',
    storageBucket: 'simple-cbfcb.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDO9VKPn_x97o4SNAzw0lHpX6yDj3SFdkI',
    appId: '1:576736049563:android:0a4993a8b3a9026066093e',
    messagingSenderId: '576736049563',
    projectId: 'simple-cbfcb',
    storageBucket: 'simple-cbfcb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDrR5q6nuFvHEfyPFat-kO5J3La-J-rd48',
    appId: '1:576736049563:ios:5be15ac0447c02ae66093e',
    messagingSenderId: '576736049563',
    projectId: 'simple-cbfcb',
    storageBucket: 'simple-cbfcb.appspot.com',
    androidClientId: '576736049563-56lfretb7n77seju9rpl2qa0l91t8hcd.apps.googleusercontent.com',
    iosClientId: '576736049563-8ar7j6c4hua0ottcd75kg8q3rraoq2o7.apps.googleusercontent.com',
    iosBundleId: 'com.example.crAdmin',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDrR5q6nuFvHEfyPFat-kO5J3La-J-rd48',
    appId: '1:576736049563:ios:b456de90b69f362366093e',
    messagingSenderId: '576736049563',
    projectId: 'simple-cbfcb',
    storageBucket: 'simple-cbfcb.appspot.com',
    androidClientId: '576736049563-56lfretb7n77seju9rpl2qa0l91t8hcd.apps.googleusercontent.com',
    iosClientId: '576736049563-i518d54pn4iblaeahaa8qruphadep7ca.apps.googleusercontent.com',
    iosBundleId: 'com.example.crAdmin.RunnerTests',
  );
}
