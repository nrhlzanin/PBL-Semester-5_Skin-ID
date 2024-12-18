// ignore_for_file: non_constant_identifier_names, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/edit_profil_screen.dart';
import 'package:skin_id/screen/face-scan_screen.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/home_screen.dart';
import 'package:skin_id/screen/skin_identification.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String username = "Memuat...";
  String email = "Memuat...";
  String jenis_kelamin = "Memuat...";
  String profilePictureUrl = '';
  String skinTone = "Tidak diketahui";
  String skinDescription = "Tidak ada deskripsi tersedia";
  Color skinToneColor = Colors.grey; // Default color placeholder

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // _fetchSkinToneData(); // Fetch skin tone data on initialization
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan masuk kembali.');
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
          username = data['username'] ?? "Tidak diketahui";
          email = data['email'] ?? "Tidak diketahui";
          jenis_kelamin = data['jenis_kelamin'] ?? "Tidak diketahui";

          if (skintone != null && skintone.isNotEmpty) {
            profilePictureUrl =
                data['profile_picture'] ?? 'default_profile.jpg';
            skinTone = skintone['skintone_name'] ?? '';
            skinDescription = skintone['skintone_description'] ?? '';
            final hexColor = skintone['hex_start'] ?? 'grey';

            if (hexColor.startsWith('#')) {
              try {
                skinToneColor = Color(
                    int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
              } catch (e) {
                print("Terjadi kesalahan saat mengurai warna heksadesimal: $e");
              }
            }
          } else {
            skinTone = 'Tidak terdeteksi';
            skinDescription =
                'Anda dapat mengetahui Warna Kulit Anda dengan menggunakan menu pemindaian kami dari Beranda';
            profilePictureUrl = 'default_profile.jpg';
          }
        });
      } else {
        throw Exception('Gagal mengambil profil pengguna.');
      }
    } catch (e) {
      print("Terjadi kesalahan saat mengambil profil pengguna: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Warna kulit tidak terdeteksi, Anda dapat mengetahui warna kulit Anda menggunakan "Fitur Pemindaian" kami di rumah :D',
          ),
        ),
      );
    }
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Navbar(),
      appBar: AppBar(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Profil kamu',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w700,
                  height: 0,
                  letterSpacing: 0.03,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            skinToneColor.withOpacity(0.5),
                            skinToneColor.withOpacity(
                                0.3), // Warna coklat muda dengan opasitas
                            Colors.white.withOpacity(
                                0.5) // Warna coklat muda dengan opasitas
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: skinToneColor.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 1,
                            offset: Offset(0, 10), // Bayangan ke bawah
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        blurRadius: 3,
                                        spreadRadius: 0,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage:
                                        NetworkImage(profilePictureUrl),
                                  ),
                                ),
                                SizedBox(width: 20),
                                // Username + email
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        username,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        jenis_kelamin,
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                      SizedBox(height: 7),
                                      Text(
                                        email,
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final updated =
                                              await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProfileScreen(),
                                            ),
                                          );
                                          if (updated == true) {
                                            _loadUserData(); // Reload user data
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 0, vertical: 3),
                                        ),
                                        child: Text(
                                          'Edit Profil',
                                          style: TextStyle(
                                            fontSize: 14,
                                            decoration: TextDecoration
                                                .underline, // Garis bawah pada teks
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: 3,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                            ),
                            // Skin Tone Representation Section
                            SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFF2B2B2B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Warna Kulit Anda Adalah',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 3,
                                          spreadRadius: 2,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: skinToneColor,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    skinTone,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Container(
                                    margin: const EdgeInsets.all(20.0),
                                    padding: const EdgeInsets.all(2.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 3,
                                          spreadRadius: 2,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Wrap(
                                      direction: Axis.horizontal,
                                      children: List.generate(5, (index) {
                                        // Map index to skin tone
                                        final tones = [
                                          "very_light",
                                          "light",
                                          "medium",
                                          // "olive",
                                          "brown",
                                          "dark"
                                        ];
                                        final colors = [
                                          Color(0xFFFFDFC4),
                                          Color(0xFFF0D5BE),
                                          Color(0xFFD1A684),
                                          // Color(0xFFA67C52),
                                          Color(0xFF825C3A),
                                          Color(0xFF4A312C),
                                        ];
                                        final isSelected = tones[index] ==
                                            skinTone.toLowerCase();

                                        return Stack(
                                          children: [
                                            Container(
                                              width: isSelected ? 32 : 32,
                                              height: isSelected ? 32 : 32,
                                              margin: EdgeInsets.all(4.0),
                                              decoration: BoxDecoration(
                                                color: colors[index],
                                                borderRadius:
                                                    BorderRadius.horizontal(
                                                  left: index == 0
                                                      ? Radius.circular(16)
                                                      : Radius.zero,
                                                  right:
                                                      index == tones.length - 1
                                                          ? Radius.circular(16)
                                                          : Radius.zero,
                                                ),
                                                border: isSelected
                                                    ? Border.all(
                                                        color: Colors
                                                            .black, // Border for the selected tone
                                                        width: 2,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                            if (isSelected)
                                              Positioned(
                                                top: -10,
                                                left: 0,
                                                right: 0,
                                                child: Icon(
                                                  Icons.arrow_drop_up,
                                                  color: Colors.black,
                                                  size: 24,
                                                ),
                                              ),
                                          ],
                                        );
                                      }),
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
                                    textAlign: TextAlign.justify,
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
              ),
            ),
          ],
        ),
      ),
      //bottomnavigation
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend),
            label: 'Identifikasi',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );

            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CameraPage()),
              );

            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SkinIdentificationPage()),
              );
          }
          setState(
            () {
              _selectedIndex = index;
            },
          );
        },
      ),
    );
  }
}