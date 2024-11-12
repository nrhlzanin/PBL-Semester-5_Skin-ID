import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class InstagramLoginScreen extends StatelessWidget {
  final TextEditingController verificationController = TextEditingController();

  // Future<void> _loginWithInstagram(BuildContext context) async {
  //   final result = await FacebookAuth.i.login(permissions: [
  //     'email',
  //     'public_profile',
  //   ]);

  //   if (result.status == LoginStatus.success) {
  //     final accessToken = result.accessToken;

  //     // You can now use the access token to fetch user data or authenticate with your backend
  //     print('Instagram Login Successful');
  //     print('Access Token: ${accessToken?.token}');

  //     // Navigate to home screen or other pages after successful login
  //     Navigator.pushReplacementNamed(context, '/home');
  //   } else {
  //     print('Instagram Login Failed: ${result.status}');
  //     // Handle errors
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Login Failed')));
  //   }
  // }

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
                    'Instagram Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // To make text visible on background
                    ),
                  ),
                  SizedBox(height: 16),
                  Image(
                    image: AssetImage("assets/image/Instagram_icon.png"),
                    width: 50, // Mengatur lebar gambar
                    height: 50, // Mengatur tinggi gambar
                    colorBlendMode: BlendMode
                        .color, // Mengatur cara warna diterapkan pada gambar
                  ),
                  SizedBox(height: 32),
                  // Instagram Login Button - Centered
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => (context),
                      icon: Icon(Icons.login, color: Colors.black),
                      label: Text('Login with Instagram'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
