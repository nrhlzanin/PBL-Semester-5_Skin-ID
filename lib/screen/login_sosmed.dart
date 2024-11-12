import 'package:flutter/material.dart';

class InstagramLoginScreen extends StatelessWidget {
  final TextEditingController verificationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/image/makeup.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.brown.shade100.withOpacity(0.1),
                    const Color.fromARGB(255, 180, 87, 54),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'Login with Social Media',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // To make text visible on background
                    ),
                  ),
                  SizedBox(height: 32),
                  // Instagram Login Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Action for Instagram login
                      print('Instagram Login');
                    },
                    icon: Image.asset(
                      'assets/image/Instagram_icon.png', // Instagram icon
                      width: 30,
                      height: 30,
                    ),
                    label: Text('Login with Instagram'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Google Login Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Action for Google login
                      print('Google Login');
                    },
                    icon: Image.asset(
                      'assets/image/Logo-google-icon-PNG.png', // Google icon
                      width: 30,
                      height: 30,
                    ),
                    label: Text('Login with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
