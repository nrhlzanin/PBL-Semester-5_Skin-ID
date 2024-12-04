// ignore_for_file: avoid_print, unused_element, unused_local_variable, unnecessary_null_comparison, use_build_context_synchronously, unnecessary_string_interpolations

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/edit_profil_screen.dart';
import 'package:skin_id/screen/home.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String username = "Loading...";
  String email = "Loading...";
  String profilePictureUrl = '';
  String skinTone = "Unknown";
  String skinDescription = "No description available";
  Color skinToneColor = Colors.grey; // Default color placeholder

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // _fetchSkinToneData(); // Fetch skin tone data on initialization
  }

  // Fetch user profile data
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please log in.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_PROFILE_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');
      final response =
          await http.get(url, headers: {'Authorization': '$token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final skintone = data['skintone'];
        setState(() {
          username = data['username'] ?? "Unknown";
          email = data['email'] ?? "Unknown";
          profilePictureUrl = data['profile_picture'] ?? 'default_profile.jpg';
          skinTone = skintone['skintone_name'] ?? '';
          skinDescription = skintone['skintone_description'] ?? '';
          final hex_color = skintone['hex_start'] ?? 'grey';

          if (hex_color != null &&
              hex_color.isNotEmpty &&
              hex_color.startsWith('#')) {
            try {
              setState(() {
                skinTone = skinTone;
                skinDescription = skinDescription;
                skinToneColor = Color(
                    int.parse(hex_color.substring(1), radix: 16) + 0xFF000000);
              });
            } catch (e) {
              print("Error parsing hex color: $e");
            }
          }
        });
      } else {
        throw Exception('Failed to fetch user profile.');
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user profile.')),
      );
    }
  }

  Color _parseHexColor(String hexColor) {
    if (hexColor != null && hexColor.isNotEmpty && hexColor.startsWith('#')) {
      try {
        return Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
      } catch (e) {
        print("Error parsing hex color: $e");
        return Colors.grey;
      }
    }
    return Colors.grey; // Default
  }

  // Fetch and update skin tone data from the user profile
// Fetch and update skin tone data from the user profile
  // Future<void> _fetchSkinToneData() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('auth_token');

  //     if (token == null || token.isEmpty) {
  //       throw Exception('No token found. Please log in.');
  //     }

  //     final baseUrl = dotenv.env['BASE_URL'];
  //     final endpoint =
  //         dotenv.env['GET_PROFILE_ENDPOINT']; // Use the correct endpoint
  //     final url = Uri.parse('$baseUrl$endpoint');

  //     // You may need to send data as a body for the update
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': '$token',
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final skintone = data['skintone'];
  //       debugPrint(data.toString());

  //       if (skintone != null) {
  //         setState(() {
  //           skinTone = skintone['skintone_name'] ?? 'Unknown';
  //           skinDescription =
  //               skintone['skintone_description'] ?? 'No description available';
  //           final hexColor = skintone['hex_start'] ?? '#FFFFFF';

  //           if (hexColor != null &&
  //               hexColor.isNotEmpty &&
  //               hexColor.startsWith('#')) {
  //             try {
  //               setState(() {
  //                 skinTone = skinTone;
  //                 skinDescription = skinDescription;
  //                 skinToneColor = Color(
  //                     int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
  //               });
  //             } catch (e) {
  //               print("Error parsing hex color: $e");
  //             }
  //           }
  //         });
  //       }
  //     } else {
  //       throw Exception('Failed to update skin tone data.');
  //     }
  //   } catch (e) {
  //     print('Error fetching skin tone data: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error fetching skin tone data.')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Navbar(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Home()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Text(
          'YourSkin-ID',
          style: GoogleFonts.caveat(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            // Profile Information
            ListTile(
              leading: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(profilePictureUrl),
              ),
              title: Text(
                username,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(email, style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
            // Row for Edit Profile button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the Edit Profile button
                children: [
                  // Edit Profile Button
                  ElevatedButton(
                    onPressed: () async {
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfileScreen()),
                      );
                      if (updated == true) {
                        _loadUserData(); // Reload user data
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      backgroundColor: Colors.black,
                    ),
                    child: Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            Container(
              height: 2,
              color: Colors.grey,
              margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
            ),
            SizedBox(height: 24),
            // Skin Tone Representation Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2B2B2B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Skin Tone Is',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Circle representing the skin tone
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: skinToneColor, // Dynamic skin tone color
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Skin tone Name
                  Text(
                    skinTone,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Skin description
                  Text(
                    skinDescription,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
