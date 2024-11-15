import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:skin_id/screen/home_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginAccountState createState() => _LoginAccountState();
}

class _LoginAccountState extends State<Login> {
  final _formKey = GlobalKey<FormState>(); // Key to track the form state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  bool _isVerificationStep =
      false; // Flag to toggle between form and verification step

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      home: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/image/makeup.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(158, 163, 85, 56),
                    Color(0xFFB68D40).withOpacity(0.5),
                    Color.fromARGB(255, 39, 39, 39).withOpacity(0.5),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Type your email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Add login logic here
                        print("Logging in...");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Add Google login logic here
                        print("Continue with Google");
                      },
                      icon: Image.asset(
                        "assets/image/Logo-google-icon-PNG.png",
                        height: 20,
                        width: 20,
                      ),
                      label: Text(
                        'Continue with Google',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey),
                        padding:
                            EdgeInsets.symmetric(vertical: 13, horizontal: 142),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
