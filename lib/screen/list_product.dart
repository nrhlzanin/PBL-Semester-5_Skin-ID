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
  final List<dynamic> _makeupProducts = [];

<<<<<<< HEAD
  Future<List<dynamic>> fetchMakeupProducts() async {
    const url = 'http://192.168.1.7:8000/api/user/makeup-products/';
=======
  @override
  void initState() {
    super.initState();
    fetchMakeupProducts();
  }

  Future<void> fetchMakeupProducts() async {
    const url = 'http://192.168.1.4:8000/api/user/makeup-products/';
>>>>>>> e2acc31009f302e9ad4096d45a3fdc52d6fc3e03
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterButton(label: 'All', isSelected: true, textColor: Colors.white, onTap: () {}),
                        SizedBox(width: 8.0),
                        FilterButton(label: 'Lipstick', textColor: Colors.white, onTap: () {}),
                        SizedBox(width: 8.0),
                        FilterButton(label: 'Eyeliner', textColor: Colors.white, onTap: () {}),
                        SizedBox(width: 8.0),
                        FilterButton(label: 'Mascara', textColor: Colors.white, onTap: () {}),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  // Responsive GridView Section
                  makeupProducts.isNotEmpty
                      ? GridView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(16.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2, // Responsive
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                          ),
                          itemCount: makeupProducts.length,
                          itemBuilder: (context, index) {
                            final product = makeupProducts[index];
                            return ProductCard(
                              imageUrl: product['image_link'] ?? 'https://via.placeholder.com/50',
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
        // Navigate to Makeup Details page if needed
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
  const FilterButton({
    required this.label,
    this.isSelected = false,
    required Color textColor, required Null Function() onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color.fromARGB(255, 186, 190, 199)
            : const Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(label),
    );
  }
}