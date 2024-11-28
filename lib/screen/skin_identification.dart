// ignore_for_file: unused_field, unused_element, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/home_screen.dart';
import 'package:skin_id/screen/list_product.dart';
import 'package:skin_id/screen/makeup_detail.dart';
import 'package:skin_id/screen/notification_screen.dart';
import 'package:skin_id/screen/home.dart' as home;
import 'package:skin_id/screen/home_screen.dart' as home_screen;

class SkinIdentificationPage extends StatefulWidget {
  @override
  _SkinIdentificationPageState createState() => _SkinIdentificationPageState();
}

class _SkinIdentificationPageState extends State<SkinIdentificationPage> {
  String skinTone = "Light";
  String skinDescription =
      "Your skin has higher skin moisture, low skin elasticity, good sebum, low moisture, and uneven texture. This skin type is more sensitive to UV rays and tends to experience more severe photo-aging.";
  int _currentIndex = 0;


  Future<List<dynamic>> fetchMakeupProducts() async {
    final url =
        // 'http://192.168.1.4:8000/api/user/makeup-products/'; // Sesuaikan dengan endpoint API Anda
         'http://127.0.0.1:8000/api/user/makeup-products/';// Sesuaikan dengan endpoint API Anda
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parsing JSON dari response API
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load makeup products');
      }
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void updateSkinDetails(String tone, String description) {
    setState(() {
      skinTone = tone;
      skinDescription = description;
    });
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
    'All',
    'Foundation',
    'Lipstick',
    'Eyeliner',
    'Mascara',
    'Cushion',
    'bronzer',
    'eyeshadow',
    'blush',
    'lip_liner',
    'nail_polish',
  ];
  // Menyimpan kategori yang dipilih
  String selectedCategory = 'All';
  String skinTone = "Light";
  String skinDescription =
      "Your skin has higher skin moisture, low skin elasticity, good sebum, low moisture, and uneven texture. This skin type is more sensitive to UV rays and tends to experience more severe photo-aging.";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(),
      appBar: AppBar(
        title: Text(
          'YourSkin-ID',
          style: GoogleFonts.caveat(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            color: Colors.black,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSkinIdentificationSection(skinTone, skinDescription),
              SizedBox(height: 32),
              _buildMakeupRecommendationSection(context),
              SizedBox(height: 32),
              _buildCommunityInspirationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkinIdentificationSection(
      String skinTone, String skinDescription) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Skin Identification',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),

        // Centered content
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
                  color: Color(0xFFF4C2C2),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: 16),

              // Skin tone color palette
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  home.SkinToneColor(color: const Color(0xFFF4C2C2)),
                  home.SkinToneColor(color: Color(0xFFE6A57E)),
                  home.SkinToneColor(color: Color(0xFFD2B48C)),
                  home.SkinToneColor(color: Color(0xFFC19A6B)),
                  home.SkinToneColor(color: Color(0xFF8D5524)),
                  home.SkinToneColor(color: Color(0xFF7D4B3E)),
                ],
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
    );
  }

  Widget _buildMakeupRecommendationSection(BuildContext context) {
    List<dynamic> filteredProducts = selectedCategory == 'All'
        ? _makeupProducts
        : _makeupProducts
            .where((product) =>
                product['product_type']?.toString().toLowerCase() ==
                selectedCategory.toLowerCase())
            .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Makeup Recommendation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        // Filter Buttons Section
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((product_type) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterButton(
                  label: product_type,
                  isSelected: selectedCategory ==
                      product_type, // Check if this category is selected
                  onTap: () => setState(() {
                    selectedCategory =
                        product_type; // Set the selected category
                  }), textColor: Colors.black,
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 20),
        // Display selected category products in GridView
        filteredProducts.isEmpty
            ? Center(
                child: Text(
                  'Not Found',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: min(
                    filteredProducts.length, 6), // Menampilkan maksimal 6 item
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];

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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Gambar produk
                          SizedBox(height: 8),
                          Container(

                            width: 70,
                            height: 50,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  product['image_link'] ??
                                      'https://via.placeholder.com/50',
                                ),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  8), // Jarak antara gambar dan teks nama produk

                          // Nama produk
                          Text(
                            product['product_type'] ?? 'Tipe Produk',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                              height: 4), // Jarak antara nama produk dan merek
                          Text(
                            product['name'] ?? 'Nama Produk',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                              height: 4), // Jarak antara nama produk dan merek

                          // Merek produk
                          Text(
                            product['brand'] ?? 'Merek Produk',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
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
                MaterialPageRoute(builder: (context) => ListProduct()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
            child: Text('Browse for more'),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityInspirationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inspirations from the community',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w700,
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            CommunityCard(
              imageUrl:
                  'https://storage.googleapis.com/a1aa/image/zRIoLp5MScojNhaNOYN6K07c9Gymwm7PbdCGuhWM7dDVHU8E.jpg',
              title: 'Tutorial make up shade',
              subtitle: 'Tutorial make up',
              author: 'Beauty',
              likes: 2017,
              comments: 333,
            ),
            CommunityCard(
              imageUrl:
                  'https://storage.googleapis.com/a1aa/image/N8QFqmhw3644G1AqeYo4Amvblmowlr86IIGKJIlyIw0oOo4JA.jpg',
              title: 'Lumme brand new products',
              subtitle: 'Lumme',
              author: 'Women',
              likes: 1115,
              comments: 555,
            ),
          ],
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
            Text(
              "Brand: $brand",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
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

class CommunityCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String author;
  final int likes;
  final int comments;

  const CommunityCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.author,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          // Set a fixed height for the image
          Container(
            height: 150, // Fixed height for the image
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with overflow handling
                Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                // Subtitle with overflow handling
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.0),
                // Author text
                Text(
                  'By $author',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8.0),
                // Likes and comments section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.thumb_up, size: 16),
                        SizedBox(width: 4.0),
                        Text('$likes'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.comment, size: 16),
                        SizedBox(width: 4.0),
                        Text('$comments'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
