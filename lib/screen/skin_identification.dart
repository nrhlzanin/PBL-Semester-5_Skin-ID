// ignore_for_file: avoid_unnecessary_containers, unused_field

import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:skin_id/button/navbar.dart';
import 'package:flutter/material.dart';
import 'package:skin_id/button/bottom_navigation.dart';
import 'package:skin_id/button/top_widget.dart';
import 'package:skin_id/screen/notification_screen.dart';

class SkinIdentificationPage extends StatefulWidget {
  @override
  _SkinIdentificationPageState createState() => _SkinIdentificationPageState();
}

class _SkinIdentificationPageState extends State<SkinIdentificationPage> {
  String skinTone = "Light"; // Contoh data, bisa diatur dari hasil prediksi
  String skinDescription =
      "Your skin has higher skin moisture, low skin elasticity, good sebum, low moisture, and uneven texture. This skin type is more sensitive to UV rays and tends to experience more severe photo-aging.";
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(),
      appBar: AppBar(
        title: Text(
          'YourSkin-ID',
          style: GoogleFonts.caveat(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.w400,
            height: 0.06,
          ),
        ),
        actions: [
          Container(
            child: IconButton(
              icon: Icon(Icons.notifications),
              color: Colors.black,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Skin Identification
              Text(
                'Skin Identification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Your Skin Tone Is',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.orange[200],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: Row(
                        children: [
                          for (var color in [
                            Colors.orange[100],
                            Colors.orange[300],
                            Colors.orange[400],
                            Colors.orange[600],
                            Colors.orange[800],
                          ])
                            Expanded(
                              child: Container(color: color),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      skinTone,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      skinDescription,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Section: Makeup Recommendation
              Text(
                'Makeup Recommendation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['All', 'Lipstick', 'EyeLiner', 'Mascara']
                    .map((label) => OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.orange),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            label,
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 14,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: 4,
                itemBuilder: (context, index) => Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: Image.asset(
                          'assets/lipstick.jpg', // Sesuaikan path gambar
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'L’Absolu Rouge Drama',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'LANCOME',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
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
    );
  }
}