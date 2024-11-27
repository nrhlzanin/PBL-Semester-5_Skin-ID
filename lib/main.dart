// ignore_for_file: unused_import, equal_keys_in_map

import 'package:flutter/material.dart';
import 'package:skin_id/screen/face-scan_screen.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/create-login.dart';
import 'package:skin_id/screen/home_screen.dart';
import 'package:skin_id/screen/list_product.dart';
import 'package:skin_id/screen/login.dart';
import 'package:skin_id/screen/makeup_Section.dart';
import 'package:skin_id/screen/makeup_detail.dart';
import 'package:skin_id/screen/new_account_screen.dart';
import 'package:skin_id/screen/notification_screen.dart';
import 'package:skin_id/screen/recomendation.dart';
import 'package:skin_id/screen/skin_identification.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verification App',
      debugShowCheckedModeBanner: false, // Disables the debug banner
      // home: NotificationScreen(), // Start with the CreateLogin screen
      // home: SkinIdentificationPage(), // Start with the CreateLogin screen
      // home: SkinIdentificationPage(), // Start with the CreateLogin screen
      // home: CreateLogin(), // Start with the CreateLogin screen
      home: Home(), // Start with the CreateLogin screen
      routes: {
        '/login': (context) => Login(), // Define the /login route
        '/homescreen': (context) => HomeScreen(), // Define the /home route
        '/home': (context) => Home(), // Define the Home screen route
        '/skin-identification': (context) =>
            SkinIdentificationPage(), // Define the skin identification
        '/notifications': (context) =>
            NotificationScreen(), // Define the Notification route
        '/recomendation': (context) =>
            Recomendation(), // Define the skin identification
        // Add other routes if needed
      },
    );
  }
}
