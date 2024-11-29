

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/notification_screen.dart';

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
    final url =
        // 'http://192.168.1.7:8000/api/user/makeup-products/'; // Sesuaikan dengan endpoint API Anda
        'http://127.0.0.1:8000/api/user/makeup-products/'; // Sesuaikan dengan endpoint API Anda
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

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredProducts = selectedCategory == 'All'
        ? _makeupProducts
        : _makeupProducts
            .where((product) =>
                product['product_type']?.toString().toLowerCase() ==
                selectedCategory.toLowerCase())
            .toList();
    return Scaffold(
      drawer: Navbar(),
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
        actions: [
          Container(
            child: IconButton(
              icon: Icon(Icons.notifications),
              color: Colors.black,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 0.2),
              child: Text(
                'Search for Beauty',
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 30,
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w700,
                  height: 2,
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 16.0),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 5),
                    child: Text(
                      'Find the makeup that suits you from many brands across the world with many categories.',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Filter Buttons Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              decoration: BoxDecoration(color: Color(0xFF242424)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15.0),
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
                            }),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  // Responsive GridView Section

                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                    ),
                    itemCount: filteredProducts.length,
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
                                  height:
                                      4), // Jarak antara nama produk dan merek
                              Text(
                                product['name'] ?? 'Nama Produk',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                  height:
                                      4), // Jarak antara nama produk dan merek

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
                ],
              ),
            ),
          ],
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

  FilterButton(
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
