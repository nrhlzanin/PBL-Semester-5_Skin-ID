import 'package:flutter/material.dart';
import 'package:skin_id/screen/home_screen.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>(); // Key to track the form state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  bool _isVerificationStep =
      false; // Flag to toggle between form and verification step

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Colors.brown.shade100.withOpacity(0.1),
                  const Color.fromARGB(255, 180, 87, 54),
                ],
              ),
            ),
          ),
          // SafeArea to prevent content from being under the status bar
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // White container with form
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 253, 253, 253),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                                height: 20), // Space between title and form
                            // Title
                            Text(
                              _isVerificationStep
                                  ? 'Enter Verification Code'
                                  : 'Create Account',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),

                            // Form for email and password (or verification code)
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Email Field (for Create Account step)
                                  if (!_isVerificationStep) ...[
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.email),
                                      ),
                                    ),
                                    SizedBox(height: 20),

                                    // Password Field
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.lock),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 30),
                                  ],

                                  // Verification Code Field (for Verification step)
                                  if (_isVerificationStep) ...[
                                    TextFormField(
                                      controller: _verificationCodeController,
                                      decoration: InputDecoration(
                                        labelText: 'Verification Code',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.lock),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter the verification code';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 30),
                                  ],

                                  // Row for Back Button and Next/Submit Button
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Back Button (only for verification step)
                                      if (_isVerificationStep)
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _isVerificationStep =
                                                  false; // Go back to create account form
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 20),
                                            backgroundColor:
                                                Colors.red, // Red background
                                            foregroundColor:
                                                Colors.white, // White text
                                            textStyle: TextStyle(fontSize: 18),
                                          ),
                                          child: Text('Back'),
                                        ),

                                      // Continue Button (for both steps)
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            if (_isVerificationStep) {
                                              // Process the verification code
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Verification Successful')),
                                              );
                                              // Navigate to HomeScreen on successful verification
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomeScreen(),
                                                ),
                                              );
                                            } else {
                                              // Process the account creation
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Account Created! Please check your email for verification code')),
                                              );
                                              setState(() {
                                                _isVerificationStep =
                                                    true; // Move to verification step
                                              });
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 50),
                                          backgroundColor: Colors
                                              .green, // Green background for Continue
                                          foregroundColor:
                                              Colors.white, // White text
                                          textStyle: TextStyle(fontSize: 18),
                                        ),
                                        child: Text(_isVerificationStep
                                            ? 'Verify Code'
                                            : 'Create Account'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
