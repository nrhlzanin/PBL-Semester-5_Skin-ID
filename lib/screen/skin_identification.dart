// ignore_for_file: unused_field, unused_element, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_id/button/navbar.dart';
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
  String skinTone = "Unknown";
  // bool isLoading = true;
  String product_name = '';
  String brand = '';
  String product_type = '';
  String product_description = '';
  String imageUrl = '';
  String hex_color = '';
  String colour_name = '';
  String price = '';

  String skinDescription = "No description available";
  // // Daftar kategori untuk filter
  // List<String> categories = [
  //   'All',
  //   'Foundation',
  //   'Lipstick',
  //   'Eyeliner',
  //   'Mascara',
  //   'Cushion',
  //   'bronzer',
  //   'eyeshadow',
  //   'blush',
  //   'lip_liner',
  //   'nail_polish',
  // ];

  @override
  void initState() {
    super.initState();
    skinToneResult = widget.skinToneResult ?? "Unknown";
    skinDescription = widget.skinDescription ?? "No description available";
    _getRecommendations(); // Call to fetch recommendations
    _loadUserData();
  }

  // Fetch user profile data
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please log in.');
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
              print("Error parsing hex color: $e");
            }
          }
        });
      } else {
        throw Exception('Failed to fetch user profile.');
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user profile.')),
      );
    }
  }

  Color _parseHexColor(String hexColor) {
    if (hexColor != null && hexColor.isNotEmpty && hexColor.startsWith('#')) {
      try {
        return Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
      } catch (e) {
        print("Error parsing hex color: $e");
        return Colors.grey;
      }
    }
    return Colors.grey; // Default
  }

  Future<void> _getRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('User is not logged in or token is missing.');
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
          imageUrl = data['image_link'] ?? "No image";
          product_name = data['product_name'] ?? "Unknown";
          brand = data['brand'] ?? "Unknown brand";
          colour_name = data['colour_name'] ?? "";
          recommendedProducts = data['recommendations'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          recommendedProducts = [];
        });
        throw Exception('Failed to fetch recommendations');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        recommendedProducts = [];
      });
      print("Error getting recommendations: $e");
    }
  }

  void _showProductDetailDialog(BuildContext context,
      Map<String, dynamic> product, List<Map<String, dynamic>> productColors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product['product_name'] ?? 'Unknown Product'),
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
                'Brand: ${product['brand'] ?? 'Unknown Brand'}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Color: ${product['colour_name'] ?? 'Unknown Color'}',
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
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // List<dynamic> filteredProducts = selectedCategory == 'All'
    //     ? _makeupProducts
    //     : _makeupProducts
    //         .where((product) =>
    //             product['product_type']?.toString().toLowerCase() ==
    //             selectedCategory.toLowerCase())
    //         .toList();
// Filter produk yang memiliki gambar valid

    // List<dynamic> validFilteredProducts = filteredProducts.where((product) {
    //   final imageUrl = product['image_link'] as String?;
    //   return imageUrl != null &&
    //       imageUrl.isNotEmpty &&
    //       Uri.tryParse(imageUrl)?.isAbsolute == true;
    // }).toList();
    return Scaffold(
      endDrawer: Navbar(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSkinIdentificationSection(),
              SizedBox(height: 32),
              _buildMakeupRecommendationSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkinIdentificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Skin Identification',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        // Skin Tone Representation Section
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF2B2B2B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Your Skin Tone Is',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              // Circle representing the skin tone
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: skinToneColor, // Dynamic skin tone color
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: 16),
              // Skin tone Name
              Text(
                skinTone,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<dynamic> _makeupProducts = [];
  Widget _buildMakeupRecommendationSection(BuildContext context) {
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

        isLoading
            ? Center(
                child: CircularProgressIndicator()) // Show loading indicator
            : recommendedProducts?.isEmpty ?? true
                ? Center(child: Text('No products found'))
                : Container(
                    
              width: double.infinity, // Mengisi lebar penuh layar
               decoration: BoxDecoration(
                color: Color(0xFF242424),
              ),
                    // Remove Expanded and use Container instead
                    height: 400, // Set a fixed height or use a dynamic approach
                    child: GridView.builder(
                      padding: EdgeInsets.all(16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 600 ? 3 : 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.75, // Aspect ratio of items
                      ),
                      itemCount: recommendedProducts?.length ?? 0,
                      itemBuilder: (context, index) {
                        final product = recommendedProducts?[index];

                        // Check if the product is null (it shouldn't be if the data is correctly fetched)
                        if (product == null) {
                          return SizedBox(); // Return an empty widget if product is null
                        }

                        return Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              // Assuming the product has a 'product_colors' field that contains color details
                              List<Map<String, dynamic>> productColors =
                                  product['product_colors'] ?? [];
                              _showProductDetailDialog(context, product,
                                  productColors); // Show product details in a dialog
                            },
                            child: Container(
                              height:
                                  300, // Ensure the container has a height, adjust accordingly
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Image container
                                  Flexible(
                                    flex: 3, // Larger space for image
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(8.0)),
                                      child: Image.network(
                                        product['image_link'] ??
                                            '', // Display product image
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
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        },
                                      ),
                                    ),
                                  ),
                                  // Text container
                                  Flexible(
                                    flex: 2, // Smaller space for text
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          MediaQuery.of(context).size.width *
                                              0.02),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['product_type'] ??
                                                'Tipe Produk', // Display product type
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
                                                'Nama Produk', // Display product name
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
                                            product['brand'] ??
                                                'Merek Produk', // Display product brand
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
                                            product['colour_name'] ??
                                                '', // Display product color
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
                          ),
                        );
                      },
                    ),
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
