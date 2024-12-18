// ignore_for_file: unused_field, unused_element, avoid_unnecessary_containers, unnecessary_string_interpolations, use_super_parameters, non_constant_identifier_names, avoid_print, use_build_context_synchronously, unnecessary_null_comparison, prefer_final_fields, prefer_const_constructors, sort_child_properties_last

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/detail_recom.dart';
import 'package:skin_id/screen/face-scan_screen.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/home_screen.dart';
import 'package:skin_id/screen/list_product.dart';
import 'package:skin_id/screen/makeup_detail.dart';
import 'package:skin_id/screen/recomendation.dart';

class SkinIdentificationPage extends StatefulWidget {
  final String? skinToneResult;
  final String? skinDescription;

  const SkinIdentificationPage({
    Key? key,
    this.skinToneResult,
    this.skinDescription,
  }) : super(key: key);

  @override
  _SkinIdentificationPageState createState() => _SkinIdentificationPageState();
}

class _SkinIdentificationPageState extends State<SkinIdentificationPage> {
  String? skinToneResult;
  List<dynamic>? recommendedProducts = [];
  bool isLoading = true;
  Color skinToneColor = Colors.grey; // Default color placeholder
  String skinTone = "Tidak dikenal";
  // bool isLoading = true;
  String product_name = '';
  String brand = '';
  String product_type = '';
  String product_description = '';
  String imageUrl = '';
  String hex_color = '';
  String colour_name = '';
  String price = '';
  bool hasSkintone = false;
  String skinDescription = "Tidak ada deskripsi tersedia";

  @override
  void initState() {
    super.initState();
    skinToneResult = widget.skinToneResult ?? "Tidak dikenal";
    skinDescription = widget.skinDescription ?? "Tidak ada deskripsi tersedia";
    _getRecommendations(); // Call to fetch recommendations
    _loadUserData();
  }

  // Fetch user profile data
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan masuk lagi.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_PROFILE_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');
      final response =
          await http.get(url, headers: {'Authorization': ' $token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final skintone = data['skintone'];
        setState(() {
          skinTone = skintone['skintone_name'] ?? '';
          skinDescription = skintone['skintone_description'] ?? '';
          final hex_color = skintone['hex_start'] ?? 'grey';

          if (hex_color != null &&
              hex_color.isNotEmpty &&
              hex_color.startsWith('#')) {
            try {
              setState(() {
                skinTone = skinTone;
                skinToneColor = Color(
                    int.parse(hex_color.substring(1), radix: 16) + 0xFF000000);
                skinDescription = skinDescription;
              });
            } catch (e) {
              print("Terjadi kesalahan saat mengurai warna heksadesimal: $e");
            }
          }
        });
      } else {
        throw Exception('Gagal mengambil profil pengguna.');
      }
    } catch (e) {
      print("Terjadi kesalahan saat mengambil profil pengguna: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Terjadi kesalahan saat mengambil profil pengguna.')),
      );
    }
  }

  Color _parseHexColor(String hexColor) {
    if (hexColor != null && hexColor.isNotEmpty && hexColor.startsWith('#')) {
      try {
        return Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
      } catch (e) {
        print("Terjadi kesalahan saat mengurai warna heksadesimal: $e");
        return Colors.grey;
      }
    }
    return Colors.grey; // Default
  }

  Future<void> _getRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Pengguna tidak masuk atau token hilang.');
    }
    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_RECOMMENDATION_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');
      final response =
          await http.get(url, headers: {'Authorization': '$token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          imageUrl = data['image_link'] ?? "Tidak ada gambar";
          product_name = data['product_name'] ?? "Tidak diketahui";
          brand = data['brand'] ?? "Merek tidak dikenal";
          colour_name = data['colour_name'] ?? "";
          recommendedProducts = data['recommendations'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          recommendedProducts = [];
        });
        throw Exception('Gagal mengambil rekomendasi');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        recommendedProducts = [];
      });
      print("Terjadi kesalahan saat mendapatkan rekomendasi: $e");
    }
  }

  void _showProductDetailDialog(BuildContext context,
      Map<String, dynamic> product, List<Map<String, dynamic>> productColors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product['product_name'] ?? 'Produk Tidak Dikenal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Image
              Image.network(
                product['image_link'] ?? '',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 50, color: Colors.grey);
                },
              ),
              SizedBox(height: 16),
              // Product Details
              Text(
                'Brand: ${product['brand'] ?? 'Merek Tidak Dikenal'}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Color: ${product['colour_name'] ?? 'Warna Tidak Diketahui'}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              // Display Color Circles for product colors
              Column(
                children: productColors.map((color) {
                  String colorHex = color['hex_value'] ??
                      'FFFFFF'; // Default to white if hex is missing
                  String colorName = color['colour_name'] ??
                      'Warna Tidak Dikenal'; // Default to 'Unknown Color'

                  return ColorCircle(
                    color: _parseHexColor(colorHex), // Parse hex color
                    colorName: colorName, // Display color name
                  );
                }).toList(),
              ),
              SizedBox(height: 8),
              // Additional details can be added here
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  int _selectedIndex = 2;

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
            height: 0.06,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSkinIdentificationSection(),
            SizedBox(height: 32),
            _buildMakeupRecommendationSection(context),
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
        selectedItemColor: Colors.black,
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

  Widget _buildSkinIdentificationSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Identifikasi Kulit',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.w700,
              height: 0,
              letterSpacing: 0.03,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Color.fromARGB(0, 0, 255, 255),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Warna Kulit Anda Adalah',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Playfair Display',
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.03,
                  ),
                ),
                SizedBox(height: 12),
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: skinToneColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  skinTone,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
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
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(5, (index) {
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
                      final isSelected = tones[index] == skinTone.toLowerCase();

                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors[index],
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                        child: isSelected
                            ? Icon(Icons.check, size: 20, color: Colors.white)
                            : null,
                      );
                    }),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  skinDescription,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<dynamic> _makeupProducts = [];
  Widget _buildMakeupRecommendationSection(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity, // Mengisi lebar penuh layar
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
          decoration: BoxDecoration(
            color: Color(0xFF242424),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rekomendasi Makeup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.03,
                ),
              ),
              SizedBox(height: 16),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else if (recommendedProducts?.isEmpty ?? true)
                Center(
                  child: Text(
                    "Tidak ada produk yang direkomendasikan",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: (recommendedProducts?.length ?? 0).clamp(0, 6),
                  itemBuilder: (context, index) {
                    final product = recommendedProducts?[index];

                    return Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailRecom(product: product),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8.0)),
                                child: Image.network(
                                  product['image_link'] ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.1,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * 0.02),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['product_type'] ?? 'Tipe Produk',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          fontFamily: 'Playfair Display',
                                          color: Colors.grey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.005),
                                    Text(
                                      product['product_name'] ?? 'Nama Produk',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.025,
                                        fontFamily: 'Montserrat',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.005),
                                    Text(
                                      product['brand'] ?? 'Merek Produk',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.025,
                                        fontFamily: 'Montserrat',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Recomendation()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  child: Text(
                    'Telusuri lebih banyak',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ),
      ],
    );
  }
}

// FilterButton widget
class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton(
      {required this.label,
      required this.isSelected,
      required this.onTap,
      required Color textColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.grey : Colors.white,
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}

// Assuming you have a list of products with 'brand' and 'name'
String selectedCategory = 'Semua';

class ColorCircle extends StatelessWidget {
  final Color color;
  final String colorName;

  const ColorCircle({required this.color, required this.colorName, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          margin: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color, // Display the circle with the passed color
          ),
        ),
        SizedBox(height: 4),
        Text(
          colorName, // Display color name below the circle
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }
}
