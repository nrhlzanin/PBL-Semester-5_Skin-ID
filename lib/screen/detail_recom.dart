// ignore_for_file: use_super_parameters, non_constant_identifier_names, unused_field, unused_element, avoid_print, unnecessary_string_interpolations

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(DetailRecom(product: {}));
}

class DetailRecom extends StatefulWidget {
  final dynamic product; // Data produk diterima sebagai parameter
  const DetailRecom({Key? key, required this.product}) : super(key: key);

  @override
  _DetailRecom createState() => _DetailRecom();
}

class _DetailRecom extends State<DetailRecom> {
  String? skinToneResult;
  List<dynamic>? recommendedProducts = [];
  bool isLoading = true;
  Color skinToneColor = Colors.grey; // Default color placeholder
  String skinTone = "Unknown";
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
  List<dynamic> _makeupProducts = [];

  // Fetch makeup products from the API
  Future<List<dynamic>> fetchMakeupProducts() async {
    final baseUrl = dotenv.env['BASE_URL'];
    final endpoint = dotenv.env['PRODUCT_ENDPOINT'];
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Gagal memuat produk makeup');
      }
    } catch (e) {
      print('Terjadi kesalahan saat mengambil data: $e');
      return [];
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
      final response = await http.get(url, headers: {'Authorization': '$token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          imageUrl = data['image_link'] ?? "Tidak ada gambar";
          product_name = data['product_name'] ?? "Tidak dikenal";
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
      print("Terjadi kesalahan saat menerima rekomendasi: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMakeupProducts().then((product) {
      setState(() {
        _makeupProducts = product;
      });
    });
  }

  // Fungsi untuk memparsing hex color
  Color parseColor(String hexColor) {
    if (hexColor.startsWith('#')) {
      hexColor = hexColor.replaceFirst('#', '0xFF');
    }
    return Color(int.parse(hexColor));
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product; // Akses data produk

    return MaterialApp(
      title: 'YourSkin-ID',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'Caveat',
        brightness: Brightness.dark, // Set the overall app theme to dark
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black, // Set Scaffold background to black
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            product['Nama'] ?? 'Detail Produk',
            style: GoogleFonts.caveat(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.network(
                    product['image_link'] ?? 'https://via.placeholder.com/300',
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Product Name
              Text(
                product['Nama'] ?? 'Produk Tidak Dikenal',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8.0),
              // Brand
              Text(
                product['brand'] ?? 'Merek Tidak Dikenal',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16.0),
              // Product Description
              Text(
                product['Deskripsi'] ?? 'Tidak ada deskripsi tersedia',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              // Product Price
              Text(
                'Price: \$${product['price'] ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              // Warna Produk
              if (product['product_colors'] != null && product['product_colors'] is List)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Warna Tersedia:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      children: (product['product_colors'] as List<dynamic>)
                          .map<Widget>((color) {
                        final colorHex = color['hex_value'] ?? '#FFFFFF';
                        final colorName = color['colour_name'] ?? 'Warna Tidak Dikenal';

                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              ColorCircle(
                                color: parseColor(colorHex),
                                colorName: colorName,
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                colorName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorCircle extends StatelessWidget {
  final Color color;

  const ColorCircle({required this.color, Key? key, required String colorName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
