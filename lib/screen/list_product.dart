// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print, unnecessary_null_in_if_null_operators, curly_braces_in_flow_control_structures, prefer_const_constructors_in_immutables, non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/face-scan_screen.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/home_screen.dart';
import 'package:skin_id/screen/notification_screen.dart';
import 'package:skin_id/screen/makeup_detail.dart';
import 'package:skin_id/screen/skin_identification.dart';

void main() {
  runApp(ListProduct());
}

class ListProduct extends StatefulWidget {
  @override
  _ListProductState createState() => _ListProductState();
}

class _ListProductState extends State<ListProduct> {
  int _currentIndex = 0;

  Future<List<dynamic>> fetchMakeupProducts() async {
    final baseUrl = dotenv.env['BASE_URL'];
    final endpoint = dotenv.env['PRODUCT_ENDPOINT'];
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return Future.error('Gagal memuat produk makeup');
      }
    } catch (e) {
      return Future.error('Terjadi kesalahan saat mengambil data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMakeupProducts().then((data) {
      setState(() {
        _makeupProducts = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YourSkin-ID',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'caveat',
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: HomePage(),
    );
  }
}

List<dynamic> _makeupProducts = [];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Daftar kategori untuk filter
  List<String> categories = [
    'Semua',
    'Foundation',
    'Lipstick',
    'Eyeliner',
    'Mascara',
    // 'Cushion',
    'bronzer',
    'eyeshadow',
    'blush',
    'lip_liner',
    'nail_polish',
  ];
  // Menyimpan kategori yang dipilih
  String selectedCategory = 'Semua';

// Check if the image URL is valid
  Future<bool> isImageValid(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      // Check if the response is a success and if the content type is an image
      return response.statusCode == 200 &&
          response.headers['content-type']?.contains('image') == true;
    } catch (e) {
      return false; // In case of an error (e.g., invalid URL)
    }
  }

  Future<bool> loadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<int?> _getSkintoneId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please log in.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_PROFILE_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.get(url, headers: {'Authorization': token});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Response Data: $data"); // Log data untuk memeriksa struktur data

        // Mengakses skintone_id yang ada dalam objek skintone dan memastikan ia merupakan tipe int
        final skintoneId = data['skintone']?['skintone_id'] ?? null;

        print(
            "Skintone ID: $skintoneId"); // Log untuk memeriksa nilai skintone_id

        return skintoneId is int
            ? skintoneId
            : null; // Mengembalikan skintone_id jika tipe int
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else {
        print(
            "Error: Failed to fetch skintone data. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching skintone: $e");
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
            builder: (context) =>
                HomeScreen()), // Halaman Home jika skintone_id ada
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

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredProducts = selectedCategory == 'Semua'
        ? _makeupProducts
        : _makeupProducts
            .where((product) =>
                product['product_type']?.toString().toLowerCase() ==
                selectedCategory.toLowerCase())
            .toList();
// Filter produk yang memiliki gambar valid

    List<dynamic> validFilteredProducts = filteredProducts.where((product) {
      final imageUrl = product['image_link'] as String?;
      return imageUrl != null &&
          imageUrl.isNotEmpty &&
          Uri.tryParse(imageUrl)?.isAbsolute == true;
    }).toList();
    return WillPopScope(
      onWillPop: _onWillPop, // Menangani aksi tombol back
      child: Scaffold(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BAGIAN ATAS GAMBAR
              Stack(
                children: [
                  // Gambar
                  Container(
                    height: 200, // Tinggi gambar
                    width: double.infinity, // Lebar gambar penuh
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/image/brush.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Teks di atas gambar
                  Positioned(
                    bottom: 16, // Jarak dari bawah
                    left: 16, // Jarak dari kiri
                    right: 16, // Jarak dari kanan
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search for Beauty',
                          style: TextStyle(
                            color: Colors.white, // Warna teks putih
                            fontSize: 30,
                            fontFamily: 'Playfair Display',
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color:
                                    Colors.black.withOpacity(0.5), // Bayangan
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8), // Jarak antar teks
                        Text(
                          'Temukan makeup yang cocok untuk Anda dengan pilihan dari berbagai merek di seluruh dunia.',
                          style: TextStyle(
                            color: Colors.white, // Warna teks putih
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Updated makeup section with proper styling
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                width: double.infinity, // Mengisi lebar penuh layar
                decoration: BoxDecoration(
                  color: Color(0xFF242424),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Buttons Section
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((product_type) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterButton(
                              label: product_type,
                              textStyle: TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                              isSelected: selectedCategory ==
                                  product_type, // Check if this category is selected
                              onTap: () => setState(() {
                                selectedCategory =
                                    product_type; // Set the selected category
                              }),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Display selected category products in GridView
                    validFilteredProducts.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(16.0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  MediaQuery.of(context).size.width > 600
                                      ? 3
                                      : 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio:
                                  0.75, // Mengatur rasio lebar-tinggi item
                            ),
                            itemCount: (validFilteredProducts
                                .length), // Maksimal 6 item
                            itemBuilder: (context, index) {
                              final product = validFilteredProducts[index];

                              return Card(
                                elevation: 4.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    // Navigasi ke MakeupDetail dengan data produk
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MakeupDetail(product: product),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
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
                                            errorBuilder:
                                                (context, error, stackTrace) {
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
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
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
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['product_type'] ??
                                                    'Tipe Produk',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
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
                                                product['name'] ??
                                                    'Nama Produk',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
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
                                                product['brand'] ??
                                                    'Merek Produk',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize:
                                                      MediaQuery.of(context)
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
                  ],
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
      ),
    );
  }
}

// FilterButton widget
class FilterButton extends StatelessWidget {
  final String label;
  final TextStyle textStyle;
  final bool isSelected;
  final VoidCallback onTap;

  FilterButton(
      {required this.label,
      required this.textStyle,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.grey : Colors.white,
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: textStyle,
      ),
    );
  }
}

// Assuming you have a list of products with 'brand' and 'name'
String selectedCategory = 'All';

class ProductCard extends StatelessWidget {
  // final String imageUrl;
  final String title;
  final String brand;
  final String description;
  final List<dynamic> productColors;
  final int id;

  const ProductCard({
    required this.id,
    // required this.imageUrl,
    required this.title,
    required this.brand,
    required this.description,
    required this.productColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              id: id,
              title: title,
              brand: brand,
              // imageUrl: imageUrl,
              description: description,
              productColors: productColors,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded(
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            //     child: Image.network(
            //       imageUrl,
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14, // Adjusted font size
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                    maxLines: 1, // Ensures the title does not overflow
                    overflow: TextOverflow.ellipsis, // Ellipsis for overflow
                  ),
                  SizedBox(height: 4),
                  Text(
                    brand,
                    style: TextStyle(
                      fontSize: 12, // Adjusted font size
                      color: Colors.grey[700],
                      fontFamily: 'Montserrat',
                    ),
                    maxLines: 1, // Ensures the brand does not overflow
                    overflow: TextOverflow.ellipsis, // Ellipsis for overflow
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

class ProductDetailPage extends StatelessWidget {
  final int id;
  final String title;
  final String brand;
  // final String imageUrl;
  final String description;
  final List<dynamic> productColors;

  const ProductDetailPage({
    required this.id,
    required this.title,
    required this.brand,
    // required this.imageUrl,
    required this.description,
    required this.productColors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image.network(
            //   imageUrl,
            //   fit: BoxFit.cover,
            //   errorBuilder: (context, error, stackTrace) {
            //     return Image.asset('assets/image/makeup.jpg'); // Placeholder
            //   },
            //   width: double.infinity,
            // ),
            SizedBox(height: 16.0),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              child: Text(
                "Brand: $brand",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              description.isNotEmpty
                  ? description
                  : "No description available.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Text(
              "Available Colors:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children: productColors.map((color) {
                return ColorBox(color: color['hex_value'] ?? "#FFFFFF");
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}