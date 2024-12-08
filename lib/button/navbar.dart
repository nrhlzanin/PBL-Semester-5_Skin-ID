// ignore_for_file: use_build_context_synchronously, avoid_print, unnecessary_string_interpolations, unused_element, unnecessary_null_in_if_null_operators, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:skin_id/screen/create-login.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/home_screen.dart';
import 'package:skin_id/screen/notification_screen.dart';
import 'package:skin_id/screen/account_screen.dart';
import 'package:skin_id/screen/skin_identification.dart';
import 'dart:convert';

class Navbar extends StatefulWidget {
  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  String username = "Memuat...";
  String email = "";
  String profilePictureUrl = "";

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CreateLogin()),
        );
        return;
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_PROFILE_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url, headers: {'Authorization': '$token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username = data['username'] ?? "Tidak diketahui";
          email = data['email'] ?? "Tidak diketahui";
          profilePictureUrl = data['profile_picture'] ?? 
              'https://www.example.com/default-profile-pic.jpg';
        });
      } else {
        throw Exception('Gagal memuat profil pengguna.');
      }
    } catch (e) {
      print("Kesalahan saat memuat profil pengguna: $e");
    }
  }

  Future<void> _userLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Token tidak ditemukan. Tidak dapat logout.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['LOGOUT_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.post(
        url,
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        await prefs.remove('auth_token');
        print('Logout berhasil');
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Logout gagal';
        if (error == 'Token invalid atau kadaluarsa') {
          await prefs.remove('auth_token');
          print('Token kadaluarsa. Mengarahkan ke halaman login...');
        } else {
          print('Kesalahan logout: $error');
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CreateLogin()),
      );
    } catch (e) {
      print("Kesalahan selama logout: $e");
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _userLogout();
              },
              child: Text('Ya, Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double navbarWidth = screenWidth * 0.60;

    return Container(
      width: navbarWidth,
      color: Color(0xFF2E2E2E),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 30, bottom: 2),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(profilePictureUrl),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30, left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.home, color: Colors.white),
                  title: Text('Beranda', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                ),
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
                ListTile(
                  leading: Icon(Icons.recommend, color: Colors.white),
                  title: Text('Identifikasi Kulit', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SkinIdentificationPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.notifications, color: Colors.white),
                  title: Text('Notifikasi', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          // Menu Logout di bagian bawah
          ListTile(
            leading: Icon(Icons.logout, color: Colors.white),
            title: Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: () {
              _showLogoutConfirmation();
            },
          ),
        ],
      ),
    );
  }
}
