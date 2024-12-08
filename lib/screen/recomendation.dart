// ignore_for_file: use_build_context_synchronously, unused_element, avoid_print, unnecessary_null_in_if_null_operators, unnecessary_string_interpolations, prefer_interpolation_to_compose_strings, non_constant_identifier_names, prefer_const_constructors_in_immutables, deprecated_member_use, use_super_parameters

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/home_screen.dart';
import 'package:skin_id/screen/makeup_detail.dart';

class Recomendation extends StatefulWidget {
  final String? skinToneResult;
  final String? skinDescription;

  Recomendation({this.skinToneResult, this.skinDescription});

  @override
  _RecommendationState createState() => _RecommendationState();
}

class _RecommendationState extends State<Recomendation> {
  String? skinToneResult;
  String? skinDescription;
  List<dynamic>? recommendedProducts;
  bool isLoading = true;
  String product_name = '';
  String brand = '';
  String product_type = '';
  String product_description = '';
  String imageUrl = '';
  String hex_color = '';
  String colour_name = '';
  String price = '';

  @override
  void initState() {
    super.initState();
    skinToneResult = widget.skinToneResult;
    skinDescription = widget.skinDescription;
    _getRecommendations();
  }

  void _showProductDetailDialog(BuildContext context,
      Map<String, dynamic> product, List<Map<String, dynamic>> productColors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product['product_name'] ?? 'Produk Tidak Tersedia'),
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
                'Brand: ${product['brand'] ?? 'Merek Tidak Tersedia'}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Color: ${product['colour_name'] ?? 'Warna Tidak Dikenal'}',
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
                    color: parseColor(colorHex), // Parse hex color
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
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

// Fungsi untuk memparsing hex color
  Color parseColor(String hexColor) {
    // Ensure the color string is prefixed with '0xFF' for proper parsing
    if (hexColor.startsWith('#')) {
      hexColor = '0xFF' + hexColor.substring(1); // Remove '#' and add '0xFF'
    } else if (hexColor.length == 6) {
      hexColor = '0xFF' + hexColor; // Ensure it's 8 digits with '0xFF' prefix
    }

    try {
      return Color(int.parse(hexColor, radix: 16)); // Parse hex color
    } catch (e) {
      return Colors.grey; // Return grey if parsing fails
    }
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
          product_name = data['product_name'] ?? "Tidak dikenal";
          brand = data['brand'] ?? "Merek tidak ditemukn";
          colour_name = data['colour_name'] ?? "";
          recommendedProducts = data['recommendations'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          recommendedProducts = [];
        });
        throw Exception('Tidak diketahui Gagal mengambil rekomendasi');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        recommendedProducts = [];
      });
      print("Terjadi kesalahan saat mendapatkan rekomendasi: $e");
    }
  }

  Future<int?> _getSkintoneId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan masuk kembali.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_PROFILE_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.get(url, headers: {'Authorization': token});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Data Respons: $data"); // Log data untuk memeriksa struktur data

        // Mengakses skintone_id yang ada dalam objek skintone dan memastikan ia merupakan tipe int
        final skintoneId = data['skintone']?['skintone_id'] ?? null;

        print(
            "Skintone ID: $skintoneId"); // Log untuk memeriksa nilai skintone_id

        return skintoneId is int
            ? skintoneId
            : null; // Mengembalikan skintone_id jika tipe int
      } else if (response.statusCode == 401) {
        throw Exception('Akses tidak sah. Silakan masuk lagi.');
      } else {
        print(
            "Kesalahan: Gagal mengambil data warna kulit. Kode status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Terjadi kesalahan saat mengambil warna kulit: $e");
      return null;
    }
  }

  // Fungsi untuk menangani aksi ketika kembali ditekan
  Future<bool> _onWillPop() async {
    int? skintoneId = await _getSkintoneId();

    // Menentukan halaman berdasarkan skintone_id
    if (skintoneId != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen()), // Halaman Home jika skintone_id ada
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomeScreen()), // Halaman HomeScreen jika skintone_id tidak ada
        (Route<dynamic> route) => false,
      );
    }
    return false; // Menghentikan aksi kembali default
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Menangani aksi tombol back
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              int? skintoneId = await _getSkintoneId();
              // Tentukan halaman tujuan berdasarkan skintone_id
              if (skintoneId != null) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomeScreen()), // Jika skintone_id ada
                  (Route<dynamic> route) => false,
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomeScreen()), // Jika skintone_id tidak ada
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
          title: Text('Rekomendasi Anda'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : (recommendedProducts?.isEmpty ?? true)
                ? Center(child: Text('Tidak ada produk yang ditemukan'))
                : GridView.builder(
                    padding: EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.75, // Rasio lebar-tinggi item
                    ),
                    itemCount: recommendedProducts?.length ?? 0,
                    itemBuilder: (context, index) {
                      final product = recommendedProducts?[index];

                      if (recommendedProducts == null) {
                        return SizedBox(); // Tampilkan widget kosong jika `product` null
                      }

                      return Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            // Assuming the product has a 'product_colors' field that contains the list of color details
                            List<Map<String, dynamic>> productColors = product[
                                    'product_colors'] ??
                                []; // Access the colors field from the product

                            _showProductDetailDialog(context, product,
                                productColors); // Pass colors to the dialog
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Container untuk gambar
                              Expanded(
                                flex:
                                    3, // Bagian gambar mengambil lebih banyak ruang
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
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.1,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                          child: CircularProgressIndicator());
                                    },
                                  ),
                                ),
                              ),
                              // Container untuk teks
                              Expanded(
                                flex:
                                    2, // Bagian teks lebih kecil dibanding gambar
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width * 0.02),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['product_type'] ??
                                            'Tipe Produk',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.03,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.005),
                                      Text(
                                        product['product_name'] ??
                                            'Nama Produk',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.025,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.005),
                                      Text(
                                        product['brand'] ?? 'Merek Produk',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.025,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        product['colour_name'] ?? '',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.025,
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
      ),
    );
  }
}

// FilterButton widget
class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton(
      {required this.label, required this.isSelected, required this.onTap});

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
