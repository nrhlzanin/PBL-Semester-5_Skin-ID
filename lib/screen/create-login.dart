// ignore_for_file: unused_import, file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_id/screen/home_screen.dart';
import 'package:skin_id/screen/login_screen.dart';
import 'package:skin_id/screen/new_account_screen.dart';
import 'package:skin_id/screen/verification_screen.dart';

class CreateLogin extends StatelessWidget {
  const CreateLogin({super.key});

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
          // SafeArea and positioning the text to the left-center
          SafeArea(
            child: Center(
              // This will center the entire content
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 200, left: 20, right: 20), // Added top padding here

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text to the left
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center vertically
                  children: [
                    Text(
                      'DETEKSI',
                      style: GoogleFonts.montserrat(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'WARNA KULITMU',
                      style: GoogleFonts.caveat(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'DAN LIHAT SHADE YANG PALING COCOK UNTUKMU',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    // Using an Expanded widget to push the button down to the bottom
                    Expanded(child: SizedBox()),
                    // Button section at the bottom with added margin
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 20), // Added bottom padding
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VerificationScreen(),
                                ));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 130),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Create an account",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 20), // Added bottom padding
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 150),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Existing user",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
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
    );
  }
}
