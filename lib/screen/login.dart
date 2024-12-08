// ignore_for_file: use_build_context_synchronously, unnecessary_null_in_if_null_operators, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:skin_id/screen/home_screen.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/create_account.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginAccountState();
}

class _LoginAccountState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Email validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan email Anda';
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Masukkan email yang valid';
    }
    return null;
  }

  // Password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan password Anda';
    } else if (value.length < 5) {
      return 'Password minimal 5 karakter';
    }
    return null;
  }

  // Login user function
  Future<void> loginUser(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final baseUrl = dotenv.env['BASE_URL'];
    final endpoint = dotenv.env['LOGIN_ENDPOINT'];

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('token')) {
          final token = data['token'];
          await _saveTokenAndCheckSkintone(token);
        } else {
          _showErrorMessage('Terjadi kesalahan saat memproses login.');
        }
      } else {
        final data = jsonDecode(response.body);
        final errorMessage = data['Error'] ?? 'Terjadi kesalahan tak dikenal';

        if (response.statusCode == 400) {
          if (errorMessage.contains('Password salah')) {
            _showErrorMessage('Password salah.');
          } else if (errorMessage
              .contains('Username dan password diperlukan')) {
            _showErrorMessage('Email dan password diperlukan.');
          }
        } else if (response.statusCode == 404) {
          if (errorMessage.contains('Email tidak ditemukan')) {
            _showErrorMessage('Email Salah');
          }
        } else {
          _showErrorMessage('Login gagal: $errorMessage');
        }
      }
    } catch (e) {
      _showErrorMessage('Terjadi kesalahan. Coba lagi nanti.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save token to SharedPreferences and check skintone_id
  Future<void> _saveTokenAndCheckSkintone(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);

    final skintoneId = await _getSkintoneId(token);

    if (skintoneId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  // Function to fetch skintone_id from API
  Future<int?> _getSkintoneId(String token) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_PROFILE_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.get(url, headers: {'Authorization': token});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final skintoneId = data['skintone']?['skintone_id'] ?? null;
        return skintoneId is int ? skintoneId : null;
      } else {
        _showErrorMessage('Gagal mendapatkan data profil.');
        return null;
      }
    } catch (e) {
      print("Error fetching skintone: $e");
      return null;
    }
  }

  // Show error message
  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Check if token exists in SharedPreferences
  Future<void> checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Container(
              decoration: const BoxDecoration(
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
                    const Color.fromARGB(158, 163, 85, 56),
                    Color(0xFFB68D40).withOpacity(0.5),
                    Color.fromARGB(255, 39, 39, 39).withOpacity(0.5),
                  ],
                ),
              ),
            ),
            // Login Form
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Selamat Datang Kembali!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Masukkan email Anda',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 20),
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          hintText: 'Masukkan password Anda',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 10),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  loginUser(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Login'),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateAccount()),
                          );
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Buat Akun, ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text: "Jika kamu belum memiliki akun",
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
