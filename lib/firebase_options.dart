// // File generated by FlutterFire CLI.
// // ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
// import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
// import 'package:flutter/foundation.dart'
//     show defaultTargetPlatform, kIsWeb, TargetPlatform;

// /// Default [FirebaseOptions] for use with your Firebase apps.
// ///
// /// Example:
// /// ```dart
// /// import 'firebase_options.dart';
// /// // ...
// /// await Firebase.initializeApp(
// ///   options: DefaultFirebaseOptions.currentPlatform,
// /// );
// /// ```
// class DefaultFirebaseOptions {
//   static FirebaseOptions get currentPlatform {
//     if (kIsWeb) {
//       return web;
//     }
//     switch (defaultTargetPlatform) {
//       case TargetPlatform.android:
//         return android;
//       case TargetPlatform.iOS:
//         return ios;
//       case TargetPlatform.macOS:
//         return macos;
//       case TargetPlatform.windows:
//         throw UnsupportedError(
//           'DefaultFirebaseOptions have not been configured for windows - '
//           'you can reconfigure this by running the FlutterFire CLI again.',
//         );
//       case TargetPlatform.linux:
//         throw UnsupportedError(
//           'DefaultFirebaseOptions have not been configured for linux - '
//           'you can reconfigure this by running the FlutterFire CLI again.',
//         );
//       default:
//         throw UnsupportedError(
//           'DefaultFirebaseOptions are not supported for this platform.',
//         );
//     }
//   }

//   static const FirebaseOptions web = FirebaseOptions(
//     apiKey: 'AIzaSyAXEQArmTjCO1l5YBrL3Af591FySVXxtmg',
//     appId: '1:753000000659:web:1ae8179389dd330a93f166',
//     messagingSenderId: '753000000659',
//     projectId: 'mhealth-f6f90',
//     authDomain: 'mhealth-f6f90.firebaseapp.com',
//     storageBucket: 'mhealth-f6f90.appspot.com',
//   );

//   static const FirebaseOptions android = FirebaseOptions(
//     apiKey: 'AIzaSyCeSkOWMV8IBP1Yt2yVfDOLeYeSF7l6yJk',
//     appId: '1:753000000659:android:6ab423bc1b2fd60693f166',
//     messagingSenderId: '753000000659',
//     projectId: 'mhealth-f6f90',
//     storageBucket: 'mhealth-f6f90.appspot.com',
//   );

//   static const FirebaseOptions ios = FirebaseOptions(
//     apiKey: 'AIzaSyC7sc_iGQiM0gMe_1CGTDLo158OJsbetzg',
//     appId: '1:753000000659:ios:d77e3fcbd284c2a693f166',
//     messagingSenderId: '753000000659',
//     projectId: 'mhealth-f6f90',
//     storageBucket: 'mhealth-f6f90.appspot.com',
//     iosBundleId: 'com.example.mhealth',
//   );

//   static const FirebaseOptions macos = FirebaseOptions(
//     apiKey: 'AIzaSyC7sc_iGQiM0gMe_1CGTDLo158OJsbetzg',
//     appId: '1:753000000659:ios:c776ed44df83a0c293f166',
//     messagingSenderId: '753000000659',
//     projectId: 'mhealth-f6f90',
//     storageBucket: 'mhealth-f6f90.appspot.com',
//     iosBundleId: 'com.example.mhealth.RunnerTests',
//   );
// }
