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
    _fetchSkinToneData(); // Fetch skin tone data on initialization
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
      final response = await http.get(url, headers: {'Authorization': '$token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username = data['username'] ?? "Unknown";
          email = data['email'] ?? "Unknown";
          profilePictureUrl = data['profile_picture'] ?? 'default_profile.jpg';
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

  // Fetch and update skin tone data from the user profile
// Fetch and update skin tone data from the user profile
  Future<void> _fetchSkinToneData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please log in.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['SKIN_PREDICT_ENDPOINT']; // Use the correct endpoint
      final url = Uri.parse('$baseUrl$endpoint');

      // You may need to send data as a body for the update
      final response = await http.post(
        url,
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
        body: json.encode({}), // Provide necessary data here if required by the API
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint(data.toString()); // Debugging to check the response structure

        // Extract skintone_id, hex_range_start, and other data from the response
        String skintoneId = data['skintone_id'].toString();
        String hexRangeStart = data['hex_range_start']; // Get hex_range_start for skin color
        String skinToneName = data['skintone_name'] ?? 'Unknown';
        String skinDescriptionText = data['skintone_description'] ?? 'No description available';

        // If hex_range_start exists, convert it to Color format for use
        if (hexRangeStart != null && hexRangeStart.isNotEmpty && hexRangeStart.startsWith('#')) {
          try {
            setState(() {
              skinTone = skinToneName;
              skinDescription = skinDescriptionText;
              skinToneColor = Color(int.parse(hexRangeStart.substring(1), radix: 16) + 0xFF000000);
            });
          } catch (e) {
            print("Error parsing hex color: $e");
          }
        }
      } else {
        throw Exception('Failed to update skin tone data.');
      }
    } catch (e) {
      print('Error fetching skin tone data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching skin tone data.')),
      );
    }
  }


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
                mainAxisAlignment: MainAxisAlignment.center, // Center the Edit Profile button
                children: [
                  // Edit Profile Button
                  ElevatedButton(
                    onPressed: () async {
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfileScreen()),
                      );
                      if (updated == true) {
                        _loadUserData(); // Reload user data
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      backgroundColor: Colors.black,
                    ),
                    child: Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Skin Tone Representation Section
            Center(
              child: Column(
                children: [
                  // Subtitle
                  Text(
                    'Your Skin Tone Is',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
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
                  // Skin tone label
                  Text(
                    skinTone,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Skin description
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
          ],
        ),
      ),
    );
  }
}
