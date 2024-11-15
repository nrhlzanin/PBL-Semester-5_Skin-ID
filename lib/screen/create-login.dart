// ignore_for_file: unused_import, duplicate_import

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_id/screen/create_account.dart';
import 'package:skin_id/screen/verification_screen.dart';
import 'package:skin_id/screen/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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
                  Color.fromARGB(158, 163, 85, 56),
                  Color(0xFFB68D40)
                      .withOpacity(0.5), // Warna coklat muda dengan opasitas
                  Color.fromARGB(255, 39, 39, 39)
                      .withOpacity(0.5) // Warna coklat muda dengan opasitas
                ],
              ),
            ),
          ),
          // SafeArea and positioning the text to the left-center
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 200, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    Expanded(child: SizedBox()),

                    // "Login With IG" button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateAccount(),
                                ));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 100),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "create an account",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18, // Ukuran font yang lebih besar
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                   
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(),
                                ));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 100),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "existing account",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18, // Ukuran font yang lebih besar
                                fontWeight: FontWeight.bold,
                              ),
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
