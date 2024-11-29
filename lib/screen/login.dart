import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skin_id/screen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginAccountState createState() => _LoginAccountState();
}

class _LoginAccountState extends State<Login> {
  final _formKey = GlobalKey<FormState>(); // Key to track the form state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      // Jika token tersedia, langsung navigasi ke HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 5) {
      return 'Password must be at least 5 characters';
    }
    return null;
  }

  Future<void> loginUser(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('http://127.0.0.1:8000/api/user/login/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': _emailController.text,
      'password': _passwordController.text,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Simpan token ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('username', data['username']);
        await prefs.setString('email', data['email']);

        // Navigasi ke halaman Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      } else {
        setState(() {
          _errorMessage = 'Unexpected error occurred';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to server';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                child: Form(
                  key: _formKey, // Assigning the form key here
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
                      // Email TextFormField with validation
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Type your email',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateEmail, // Validator for email
                      ),
                      SizedBox(height: 20),
                      // Password TextFormField with validation
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validatePassword, // Validator for password
                      ),
                      SizedBox(height: 10),
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 16.0),
                      ],
                      ElevatedButton(
                        onPressed: () {
                          print('pressed');
                          if (_formKey.currentState!.validate()) {
                            print('checked');
                            final email = _emailController.text.trim();
                            final password = _passwordController.text.trim();
                            loginUser(email, password);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 50),
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
                          padding: EdgeInsets.symmetric(
                            vertical: 13,
                            horizontal: 73,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          // Logic for navigating to the sign-up screen
                          print("Navigating to Create Account");
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Create an Account',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold, // Bold text
                                  fontFamily: 'Montserrat',
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text: ' if you don’t have one yet',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
