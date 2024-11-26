import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:skin_id/screen/login.dart';
import 'package:skin_id/screen/home.dart';

void main() async {
  // await dotenv.load(fileName: ".env");
  // print(dotenv.env);
  runApp(CreateAccount());
}

// JANGAN DIHAPUS GES
// ===========================================================
// class APIConfig {
//   static final String baseUrl = dotenv.env['BASE_URL'].toString();
//   static final String registerEndpoint =
//       dotenv.env['REGISTER_ENDPOINT'].toString();

//   static String getRegisterURL() {
//     if (baseUrl.isEmpty || registerEndpoint.isEmpty) {
//       print('$baseUrl$registerEndpoint');
//       throw Exception('Environment variables are not initialized correctly');
//     }
//     return '$baseUrl$registerEndpoint';
//   }
// }
// ===========================================================

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool _isAccountCreated = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter username';
    } else if (value.length < 3 && value.length > 13) {
      return 'username must between 3 ~ 12 characters';
    }
    return null;
  }

  String? _email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 5) {
      return 'Password must be at least 5 characters';
    }
    return null;
  }

  String? _confirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    } else if (value != _passwordController.text) {
      return 'Password do not match';
    }
    return null;
  }

  Future<void> registerUser(
      String username, String email, String password) async {
    final confirmPassword = _confirmPasswordController.text.trim();
    print('Button ditekan');
    // print(APIConfig.getRegisterURL());
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    try {
      final response = await http.post(
        // ===========================================================
        // Uri.parse(APIConfig.getRegisterURL()),
        Uri.parse('http://192.168.1.7:8000/api/user/register/'), //alamat IP diubah ke alamat IP kalian (cek cmd ipconfig)
        body: {
          'username': username,
          'email': email,
          'password': password,
          // 'skintone_id': null,
        },
      );
        // ===========================================================

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        final error = jsonDecode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occured: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/image/makeup.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
            if (!_isAccountCreated)
              Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Create an Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'Type your username',
                            border: OutlineInputBorder(),
                          ),
                          validator: _username,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(),
                          ),
                          validator: _email,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Type your password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: _password,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm password',
                            hintText: 'Type your password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: _confirmPassword,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            print('pressed');
                            if (_formKey.currentState!.validate()) {
                              final username = _usernameController.text.trim();
                              final email = _emailController.text.trim();
                              final password = _passwordController.text.trim();
                              registerUser(username, email, password);
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
                              'Create account',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {},
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
                            vertical: 15, horizontal: 50
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                             
                        SizedBox(height: 20),
                        Text.rich(
                          TextSpan(
                            text: 'Already have one? ',
                            children: [
                              TextSpan(
                                text: 'Log in',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Login(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}


// else
            //   Center(
            //     child: Container(
            //       padding: EdgeInsets.all(20),
            //       margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            //       decoration: BoxDecoration(
            //         color: Colors.white.withOpacity(0.8),
            //         borderRadius: BorderRadius.circular(20),
            //       ),
            //       child: Column(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           SizedBox(height: 20),
            //           Text(
            //             'Verification',
            //             textAlign: TextAlign.center,
            //             style: TextStyle(
            //               color: Colors.black,
            //               fontSize: 18,
            //               fontFamily: 'Montserrat',
            //               fontWeight: FontWeight.w800,
            //               decoration: TextDecoration.underline,
            //               height: 1.5,
            //               letterSpacing: 0.02,
            //             ),
            //           ),
            //           SizedBox(height: 20),
            //           Text(
            //             'We sent you an Email!',
            //             textAlign: TextAlign.center,
            //             style: TextStyle(
            //               color: Colors.black,
            //               fontSize: 16,
            //               fontFamily: 'Montserrat',
            //               fontWeight: FontWeight.w700,
            //               height: 1.5,
            //               letterSpacing: 0.01,
            //             ),
            //           ),
            //           SizedBox(height: 20),
            //           Text.rich(
            //             TextSpan(
            //               children: [
            //                 TextSpan(
            //                   text:
            //                       'We have sent you a verification link to your email address before you can use ',
            //                   style: TextStyle(
            //                     color: Colors.black,
            //                     fontSize: 14,
            //                     fontFamily: 'Montserrat',
            //                     fontWeight: FontWeight.w400,
            //                     height: 1.5,
            //                     letterSpacing: 0.01,
            //                   ),
            //                 ),
            //                 TextSpan(
            //                   text: 'Skin-ID',
            //                   style: TextStyle(
            //                     color: Colors.black,
            //                     fontSize: 14,
            //                     fontFamily: 'Pacifico',
            //                     fontWeight: FontWeight.w400,
            //                     height: 1.5,
            //                     letterSpacing: 0.01,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             textAlign: TextAlign.center,
            //           ),
            //           SizedBox(height: 20),
            //         ],
            //       ),
            //     ),
            //   ),