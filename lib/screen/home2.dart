import 'package:flutter/material.dart';
import 'package:skin_id/button/bottom_navigation.dart';
import 'package:skin_id/button/top_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<dynamic> _makeupProducts = [];

  Future<List<dynamic>> fetchMakeupProducts() async {
    final url =
        'http://127.0.0.1:8000/api/makeup-products/'; // Sesuaikan dengan endpoint API Anda
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

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopWidget(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skin Tone Section
            Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "Check Your Skin Tone with our AI feature",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Check your skin tone for better understanding to your skin. More personalized makeup and content recommendation based on your skin tone will come soon!",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                              Colors.brown.shade100, Colors.brown, index / 5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Make Up Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Make Up Section",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _makeupProducts.isNotEmpty
                    ? List.generate(
                        _makeupProducts.length >= 6
                            ? 6
                            : _makeupProducts.length,
                        (index) {
                          final product = _makeupProducts[index];
                          return GestureDetector(
                            onTap: () {
                              // Tambahkan fungsi jika Anda ingin melakukan sesuatu ketika gambar di-klik
                              print('Clicked on ${product['name']}');
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    product['image_link'] ??
                                        'https://via.placeholder.com/50', // Gambar default jika image_link kosong
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : [
                        Text('No makeup products available')
                      ], // Pesan saat data kosong
              ),
            ),
            SizedBox(height: 24),

            // What is Popular Around
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "What is Popular Around",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: List.generate(2, (index) {
                  return Container(
                    width: double.infinity,
                    height: 150,
                    margin: EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            index == 0
                                ? "Tutorial make up shade warna cerah"
                                : "Cara memilih skin care yang baik sesuai jenis kulit",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.favorite_border,
                                  size: 20, color: Colors.grey),
                              SizedBox(width: 4),
                              Text("2.1k"),
                              SizedBox(width: 16),
                              Icon(Icons.chat_bubble_outline,
                                  size: 20, color: Colors.grey),
                              SizedBox(width: 4),
                              Text("975"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}
