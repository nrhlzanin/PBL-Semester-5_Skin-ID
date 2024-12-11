// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class VerificationScreen extends StatelessWidget {
  final TextEditingController verificationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
                  // Title and Icon
                  Text(
                    'Verifikasi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // To make text visible on background
                    ),
                  ),
                  SizedBox(height: 16),
                  Icon(
                    Icons.domain_verification,
                    size: 50,
                    color: Colors.green,
                  ),
                  SizedBox(height: 32),
                  // Verification Code Field
                  TextField(
                    controller: verificationController,
                    decoration: InputDecoration(
                      labelText: 'Kode Verifikasi',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  // Password Field
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Kata sandi',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  // Confirm Password Field
                  TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Kata Sandi',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 24),
                  // Submit Button
                  ElevatedButton(
                    onPressed: () {
                      // Handle submit action
                      String verificationCode = verificationController.text;
                      String password = passwordController.text;
                      String confirmPassword = confirmPasswordController.text;

                      if (verificationCode.isNotEmpty &&
                          password.isNotEmpty &&
                          confirmPassword.isNotEmpty) {
                        if (password == confirmPassword) {
                          // Submit the form
                          print(
                              'Formulir yang dikirimkan: Kode Verifikasi: $verificationCode, Kata sandi: $password');
                        } else {
                          // Show error message if passwords don't match
                          print('Kata sandi tidak cocok');
                        }
                      } else {
                        // Show an error message if any field is empty
                        print('Harap isi semua kolom');
                      }
                    },
                    child: Text('Kirim'),
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
