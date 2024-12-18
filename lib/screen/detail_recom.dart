// ignore_for_file: use_super_parameters, non_constant_identifier_names, unused_field, unused_element, avoid_print, unnecessary_string_interpolations

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_id/screen/skin_identification.dart';
import 'package:url_launcher/url_launcher.dart'; //INI SEK BLM ISO DIPAKE
import 'package:flutter/services.dart';
import 'package:expandable_text/expandable_text.dart'; //UNTUK BACA SELENGKAPMYA

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
  String skinTone = "Tidak diketahui";
  String product_name = '';
  String brand = '';
  String product_type = '';
  String product_description = '';
  String imageUrl = '';
  String hex_color = '';
  String colour_name = '';
  bool hasSkintone = false;
  String skinDescription = "Tidak ada deskripsi tersedia";
  List<dynamic> _makeupProducts = [];

  String price = '';

  // UNTUK MENGARAHKAN LINK KE URL
  Future<void> openLink(String url) async {
    if (url.isEmpty) {
      print("URL kosong, tidak dapat membuka link.");
      return;
    }
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print("Tidak dapat membuka URL: $url");
      }
    } catch (e) {
      print("Error saat membuka URL: $e");
    }
  }
  // END MENGARAHKAN LINK KE URL

  // AMBIL DATA PRODUK DARI API
  Future<List<dynamic>> fetchMakeupProducts() async {
    final baseUrl = dotenv.env['BASE_URL'];
    final endpoint = dotenv.env['PRODUCT_ENDPOINT'];
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Makeup Products fetched: $data"); // Debugging line
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
      final response =
          await http.get(url, headers: {'Authorization': '$token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Recommendations fetched: $data"); // Debugging line
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
        print("_makeupProducts: $_makeupProducts"); // Debugging line
      });
    });
    _getRecommendations(); // Added to fetch recommendations at the start
  }

  // Fungsi untuk memparsing hex color
  Color parseColor(String hexColor) {
    if (hexColor.startsWith('#')) {
      return Color(int.parse('0xFF${hexColor.substring(1)}'));
    } else {
      return Colors.grey;
    }
    // return Color(int.parse(hexColor));
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product; // Akses data produk

    // Debugging output if product is missing or invalid
    print("Product data: $product"); // Debugging line

    if (product == null || product.isEmpty) {
      print("Data produk tidak ditemukan.");
    } else if (product['name'] == null) {
      print("Nama produk tidak ditemukan.");
    }

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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SkinIdentificationPage(),
                ),
              );
            },
          ),
          title: Text(
            product['name'] ?? 'Detail Produk',
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
                    height: 400,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Product Name
              Text(
                product['product_name'] ?? 'Produk Tidak Dikenal',
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8.0),
              // Brand
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product['brand'] ?? 'Brand Tidak Dikenali',
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Playfair Display',
                      color: Colors.grey, // Light gray for brand text
                    ),
                  ),
                  Text(
                    'Price: \$${product['price'] ?? 'N/A'}', // Product price
                    style: const TextStyle(
                      fontSize: 24,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White color for price
                    ),
                  ),
                ],
              ),
              // Text(
              //   product['brand'] ?? 'Merek Tidak Dikenal',
              //   style: const TextStyle(
              //     fontSize: 18,
              //     color: Colors.grey,
              //   ),
              // ),
              // PRODUCT PRICE
              // const SizedBox(height: 8.0),
              // Text(
              //   'Price: \u0024${product['price'] ?? 'N/A'}', // Perbaiki agar harga dapat muncul
              //   style: const TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white,
              //   ),
              // ),
              SizedBox(height: 16.0),
              // Warna Produk
              if (product['recommended_colors'] != null &&
                  product['recommended_colors'] is List)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rekomendasi Warna:',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Wrap(
                      children: (product['recommended_colors'] as List<dynamic>)
                          .map<Widget>((color) {
                        final colorHex = color['hex_value'] ?? '#FFFFFF';
                        final colorName =
                            color['color_name'] ?? 'Warna Tidak Dikenal';

                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.0,
                                  ),
                                ),
                                child: ColorCircle(
                                  color: parseColor(colorHex),
                                  colorName: colorName, // Memparse warna hex
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              SizedBox(
                                width: 100,
                                child: Text(
                                  colorName, // Nama warna, jika null akan menampilkan 'Warna Tidak Dikenal'
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors
                                        .white, // Warna putih untuk nama warna
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              const SizedBox(height: 16.0),
              // Product Description
              Text(
                "Deskripsi:",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8.0),
              ExpandableText(
                product['description'] ?? 'Tidak ada deskripsi tersedia',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                ),
                textAlign: TextAlign.justify,
                expandText: '(Baca Selengkapnya)',
                collapseText: '(Tutup)',
                maxLines: 6,
                linkColor: Color(0xFFD1A684),
              ),
              const SizedBox(height: 16.0),
              // LINK PEMBELIAN PRODUK (BAGIAN YG KU COMMAND MASIH ERROR KARENA APP TIDAK MAU DIRECT KE URL)
              if (product['product_link'] != null)
                GestureDetector(
                  onTap: () {
                    openLink(product['product_link']);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(color: const Color.fromARGB(255, 24, 24, 24)),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      'Beli Sekarang',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              Text(
                'Atau salin link berikut:', // Perbaiki agar harga dapat muncul
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.2), // Warna latar belakang semi-transparan
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10.0,
                      spreadRadius: 5.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white
                        .withOpacity(0.3), // Warna border semi-transparan
                    width: 1.0,
                  ),
                ),
                child: Stack(
                  children: [
                    // Teks Link
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${product['product_link'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Ikon Salin di Pojok Kanan Atas
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          final link = product['product_link'] ?? 'N/A';
                          print('Link yang disalin: $link');
                          if (link != 'N/A') {
                            Clipboard.setData(ClipboardData(text: link));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Link telah disalin ke clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Icon(
                          Icons.copy,
                          size: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // END LINK PEMBELIAN
            ],
          ),
        ),
      ),
    );
  }
}

class ColorCircle extends StatelessWidget {
  final Color color;
  final String colorName;

  const ColorCircle({required this.color, required this.colorName, Key? key})
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
