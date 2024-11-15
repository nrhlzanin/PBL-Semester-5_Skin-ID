import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:skin_id/screen/login.dart';

void main() {
  runApp(CreateAccount());
}

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool _isAccountCreated = false; // Track if account is created

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
            // Check if account is created
            if (!_isAccountCreated)
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
                        'Create an Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Type your username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Type your password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Confirm password',
                          hintText: 'Type your password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isAccountCreated =
                                true; // Show verification screen
                          });
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
                              vertical: 13, horizontal: 142),
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
              )
            else
              // If account is created, show confirmation message
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
                      SizedBox(height: 20),
                      Text(
                        'Verification',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                          height: 1.5,
                          letterSpacing: 0.02,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'We sent you an Email!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          letterSpacing: 0.01,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'We have sent you a verification link to your email address before you can use ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                                letterSpacing: 0.01,
                              ),
                            ),
                            TextSpan(
                              text: 'Skin-ID',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Pacifico',
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                                letterSpacing: 0.01,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
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
