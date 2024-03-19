import 'package:flutter/material.dart';
import 'package:mhealth/login_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey:
          "AIzaSyAyeXqzbl16wE0oVOGBjc20fotvYdtZoG0", // paste your api key here
      appId:
          "1:194857567449:android:678be1e2de2560e184eac8", //paste your app id here
      messagingSenderId: "194857567449", //paste your messagingSenderId here
      projectId: "mhealthapp-2647c", //paste your project id here
    ),
  );
  runApp(const MaterialApp(
    home: Scaffold(
      body: LoginPage(),
    ),
    debugShowCheckedModeBanner: false,
  ));
}
