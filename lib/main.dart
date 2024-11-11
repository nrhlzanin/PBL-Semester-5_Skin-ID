import 'package:flutter/material.dart';
import 'package:skin_id/screen/face-scan_screen.dart';
import 'package:skin_id/screen/home.dart';
// import 'package:skin_id/screen/home_screen.dart';
import 'package:skin_id/screen/create-login.dart';
import 'package:skin_id/screen/login_screen.dart';
import 'package:skin_id/screen/makeup_Section.dart';
import 'package:skin_id/screen/new_account_screen.dart';
import 'package:skin_id/screen/notification_screen.dart';

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
      home: CreateLogin(), // Start with the CreateLogin screen
      routes: {
        '/login': (context) => LoginScreen(), // Define the /login route
        '/homescreen': (context) => HomeScreen(), // Define the /home route
        '/home': (context) => Home(), // Define the Home screen route
        // Add other routes if needed
      },
    );
  }
}
