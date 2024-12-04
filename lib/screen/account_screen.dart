// ignore_for_file: avoid_print, unused_element

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
  Future<void> _fetchSkinToneData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please log in.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['SKIN_PREDICT_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
        body: json.encode({}), 
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          skinTone = data['skintone_name'] ?? 'Unknown';
          skinDescription = data['skintone_description'] ?? 'No description available';
          skinToneColor = Color(int.parse(data['color_code'].substring(1), radix: 16) + 0xFF000000);
        });
      } else {
        throw Exception('Failed to fetch skin tone data.');
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
