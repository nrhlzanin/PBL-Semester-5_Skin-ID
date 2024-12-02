import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:skin_id/screen/create-login.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/home_screen.dart';
import 'package:skin_id/screen/notification_screen.dart';
import 'package:skin_id/screen/account_screen.dart';
import 'package:skin_id/screen/recomendation.dart';
import 'package:skin_id/screen/skin_identification.dart';
import 'dart:convert';

class Navbar extends StatefulWidget {
  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  String username = "Loading...";
  String email = "";

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No token found. Please log in.');
      }
      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_PROFILE_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url, headers: {
        'Authorization': '$token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username = data['username'] ?? "Unknown";
          email = data['email'] ?? "Unknown";
        });
      } else {
        print("Failed to fetch user profile: ${response.body}");
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  Future<void> _userLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No token found... Wait how can you get in then?');
      }
      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['LOGOUT_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.post(url, 
        headers: {
          'Authorization': '$token',
          'Content-Type':'application/json',
        },
        body: jsonEncode({'token':token}),
      );

      if (response.statusCode == 200) {
        await prefs.remove('auth_token');
        print('Logout successful');
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Logout failed';
        print('Logout error: $error');
      }
    } catch (e) {
      print("Error logout for user profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double navbarWidth = screenWidth * 0.60; // One-third of screen width

    return Container(
      width: navbarWidth,
      color: Color(0xFF2E2E2E), // Dark gray color
      child: Column(
        children: <Widget>[
          // Profile Photo and Username
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                // Profile Photo
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 30, bottom: 2),
                  child: CircleAvatar(
                    radius: 30, // Avatar size
                    backgroundImage: AssetImage(
                        'assets/image/avatar1.jpeg'), // Profile photo
                  ),
                ),
                // Username
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 30, left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username, // Username
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14, // Font size
                              fontWeight: FontWeight.bold,
                              overflow:
                                  TextOverflow.ellipsis, // Truncate if too long
                            ),
                            softWrap:
                                false, // Prevent wrapping to the next line
                            maxLines: 1, // Limit to 1 line
                          ),
                          Text(
                            email,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
          // Menu List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Home Menu
                ListTile(
                  leading: Icon(Icons.home, color: Colors.white),
                  title: Text('Home', style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final hasCheckedSkintone =
                        prefs.getBool('hasCheckedSkintone') ?? false;

                    if (hasCheckedSkintone) {
                      // Jika sudah memeriksa skintone, navigasi ke halaman Home
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    }
                  },
                ),
                // Akun Menu
                ListTile(
                  leading: Icon(Icons.account_circle, color: Colors.white),
                  title: Text('Akun', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AccountScreen()),
                    );
                  },
                ),
                // Rekomendasi Menu
                ListTile(
                  leading: Icon(Icons.recommend, color: Colors.white),
                  title: Text('Skin Identification',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SkinIdentificationPage()),
                    );
                  },
                ),
                // Notifikasi Menu
                ListTile(
                  leading: Icon(Icons.notifications, color: Colors.white),
                  title:
                      Text('Notifikasi', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationScreen()),
                    );
                  },
                ),
                // Logout Menu
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.white),
                  title: Text('Logout', style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    try {
                      await _userLogout();
                      // Navigate to the login screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CreateLogin()), // Ensure CreateLogin is the correct login screen
                      );
                    } catch (e) {
                      print('Error logout: $e . Woho tidak bisa logout kau!');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
