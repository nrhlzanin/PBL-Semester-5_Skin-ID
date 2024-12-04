import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:skin_id/screen/home_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginAccountState();
}

class _LoginAccountState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false; // Untuk toggle visibilitas password
  bool _isLoading = false; // Untuk state loading tombol login
  String? _errorMessage; // Menyimpan pesan error jika ada

  // Validasi input email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan email Anda';
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Masukkan email yang valid';
    }
    return null;
  }

  // Validasi input password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan password Anda';
    } else if (value.length < 5) {
      return 'Password minimal 5 karakter';
    }
    return null;
  }
Future<void> loginUser(String email, String password) async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final baseUrl = dotenv.env['BASE_URL']; // URL base, e.g. 'http://your-api-url'
  final endpoint = dotenv.env['LOGIN_ENDPOINT']; // e.g. '/api/login/'

  try {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      body: {'email': email, 'password': password},
    );

    // Handle response status code
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // If token exists, save it and navigate to the home screen
      if (data.containsKey('token')) {
        final token = data['token'];
        await _saveTokenAndNavigate(token);
      } else {
        _showErrorMessage('Terjadi kesalahan saat memproses login.');
      }
    } else {
      // Handle different error responses based on status code and error message
      final data = jsonDecode(response.body);
      final errorMessage = data['Error'] ?? 'Terjadi kesalahan tak dikenal';

      if (response.statusCode == 400) {
        if (errorMessage.contains('Password salah')) {
          _showErrorMessage('Password salah.');
        } else if (errorMessage.contains('Username dan password diperlukan')) {
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

// Save token to SharedPreferences and navigate to HomeScreen
  Future<void> _saveTokenAndNavigate(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

// Show error message
  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Periksa token di SharedPreferences
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
            // Form Login
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
                        'Welcome Back!',
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
                          labelText: 'Password',
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
                            : const Text(
                                'Login',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          print("Navigasi ke halaman buat akun");
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Create account,',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text: " If you don't have an account ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
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