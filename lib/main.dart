import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skin_id/screen/create-login.dart';
import 'package:skin_id/screen/home_screen.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/login.dart';
import 'package:skin_id/screen/skin_identification.dart';
import 'package:skin_id/screen/notification_screen.dart';
import 'package:skin_id/screen/recomendation.dart';

void main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verification App',
      debugShowCheckedModeBanner: false, // Disable debug banner
      home: CreateLogin(), // Default screen on app start
      routes: {
        // Define your routes here for easy navigation
        '/login': (context) => Login(),
        '/homescreen': (context) => HomeScreen(),
        '/home': (context) => Home(),
        '/skin-identification': (context) => SkinIdentificationPage(),
        '/notifications': (context) => NotificationScreen(),
        '/recomendation': (context) => Recomendation(),
        // You can add more routes as needed
      },
    );
  }
}
