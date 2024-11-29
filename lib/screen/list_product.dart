// ignore_for_file: unused_field, avoid_print

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
  List<dynamic> _makeupProducts = [];

  Future<void> fetchMakeupProducts() async {
    const url = 'http://127.0.0.1:8000/api/user/makeup-products/';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _makeupProducts = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load makeup products');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMakeupProducts();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YourSkin-ID',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'caveat',
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(makeupProducts: _makeupProducts),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<dynamic> makeupProducts;

  HomePage({required this.makeupProducts});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> categories = [
    'All',
    'Foundation',
    'Lipstick',
    'Eyeliner',
    'Mascara',
    'Cushion',
    'Bronzer',
    'Eyeshadow',
    'Blush',
    'Lip Liner',
    'Nail Polish',
  ];

  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final List<dynamic> filteredProducts = selectedCategory == 'All'
        ? widget.makeupProducts
        : widget.makeupProducts
            .where((product) =>
                product['product_type']?.toLowerCase() ==
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
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            color: Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Search for Beauty',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Find the makeup that suits you from many brands across the world with many categories.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FilterButton(
                      label: category,
                      isSelected: selectedCategory == category,
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16.0),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ProductCard(
                  id: product['product_id'] ?? 0,
                  imageUrl: product['image_link'] ??
                      'https://via.placeholder.com/150',
                  title: product['name'] ?? 'No Name',
                  brand: product['brand'] ?? 'Unknown',
                  description: product['description'] ?? 'No description',
                  productColors: product['product_colors'] ?? [],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.grey[700] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final int id;
  final String imageUrl;
  final String title;
  final String brand;
  final String description;
  final List<dynamic> productColors;

  const ProductCard({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.brand,
    required this.description,
    required this.productColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Tapped on product: $title');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              id: id,
              title: title,
              brand: brand,
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
            //       errorBuilder: (context, error, stackTrace) =>
            //           Image.asset('assets/image/makeup.jpg'),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Montserrat'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
