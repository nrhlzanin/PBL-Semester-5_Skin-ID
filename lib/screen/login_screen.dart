import 'package:flutter/material.dart';
import 'package:skin_id/screen/home.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // Key to track the form state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                          boxShadow: [
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
                                height:
                                    20), // Space between back button and the form

                            // Logo or App Name
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),

                            // Login Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Email Field
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      } else if (!RegExp(
                                              r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
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

                                  // Row for Back Button and Login Button
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Back Button (with white font and red background)
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Go back to the previous screen
                                        },
                                        child: Text('Back'),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 20),
                                          backgroundColor:
                                              Colors.red, // Red background
                                          foregroundColor:
                                              Colors.white, // White text
                                          textStyle: TextStyle(fontSize: 18),
                                        ),
                                      ),

                                      // Login Button
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            // Process the login if validation is successful
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content:
                                                      Text('Logging in...')),
                                            );
                                            // Navigate to HomeScreen on successful login
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Home(),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text('Login'),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 50),
                                          backgroundColor: Colors
                                              .green, // Green background for Login
                                          foregroundColor: Colors
                                              .white, // White text for Login
                                          textStyle: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
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
