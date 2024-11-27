// ignore_for_file: unused_field, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/notification_screen.dart';

void main() {
  runApp(ListProduct());
}

class ListProduct extends StatefulWidget {
  @override
  _ListProductState createState() => _ListProductState();
}

class _ListProductState extends State<ListProduct> {
  final int _currentIndex = 0;
  List<dynamic> _makeupProducts = [];

  Future<void> fetchMakeupProducts() async {
    const url = 'http://192.168.1.4:8000/api/user/makeup-products/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _makeupProducts = data;
        });
      } else {
        throw Exception('Failed to load makeup products');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _makeupProducts = [];
      });
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

class HomePage extends StatelessWidget {
  final List<dynamic> makeupProducts;
  const HomePage({required this.makeupProducts});

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
            height: 0.06,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 0.2),
              child: Text(
                'Search for Beauty',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w700,
                  height: 2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 0, bottom: 5),
              child: Text(
                'Find the makeup that suits you from many brands across the world with many categories.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              decoration: BoxDecoration(color: Color(0xFF242424)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterButton(label: 'All', isSelected: true, onTap: () {}),
                        SizedBox(width: 8.0),
                        FilterButton(label: 'Lipstick', onTap: () {}),
                        SizedBox(width: 8.0),
                        FilterButton(label: 'Eyeliner', onTap: () {}),
                        SizedBox(width: 8.0),
                        FilterButton(label: 'Mascara', onTap: () {}),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  makeupProducts.isNotEmpty
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(16.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                          ),
                          itemCount: makeupProducts.length,
                          itemBuilder: (context, index) {
                            final product = makeupProducts[index];
                            return ProductCard(
                              imageUrl: product['image_link'] ?? 'https://via.placeholder.com/150',
                              title: product['name'] ?? 'No Name',
                              brand: product['brand'] ?? 'Unknown',
                            );
                          },
                        )
                      : Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String brand;

  const ProductCard({
    required this.imageUrl,
    required this.title,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Tapped on product: $title');
      },
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                brand,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.grey[700] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
