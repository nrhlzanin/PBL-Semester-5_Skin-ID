// ignore_for_file: avoid_unnecessary_containers

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Import http package
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/face-scan_screen.dart';
import 'package:skin_id/screen/list_product.dart';
import 'package:skin_id/screen/makeup_detail.dart';
import 'package:skin_id/screen/notification_screen.dart'; // Import CameraPage

void main() {
  runApp(Home());
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final int _currentIndex = 0;
  final List<dynamic> _makeupProducts = [];

  Future<List<dynamic>> fetchMakeupProducts() async {
    const url =
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YourSkin-ID',
      theme: ThemeData(
        canvasColor: Color(0xFFFFE8D4),
        fontFamily: 'caveat',
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Check Your Skin Tone',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'Playfair Display',
                fontWeight: FontWeight.w700,
                height: 0,
                letterSpacing: 0.03,
              ),
            ),
            Row(
              children: [
                CameraButton(),
                SizedBox(width: 20),
                Text(
                  'Use me!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Identify your skin tone using our AI for a better understanding of your skin. More makeup preferences and content recommendations based on your skin tone.',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 17), // Set color of the text
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.0),
            Row(
              children: [
                AvatarImage(imageUrl: "assets/image/avatar1.jpeg"),
                SizedBox(width: 16.0),
                AvatarImage(imageUrl: "assets/image/avatar2.jpeg"),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkinIdentificationCard(),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              width: double.infinity, // Mengisi lebar penuh layar
              decoration: BoxDecoration(
                color: Color(0xFF242424),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 7.0),
                  Text(
                    'Makeup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    'Find makeup that suits you with choices from many brands around the world.',
                    style: TextStyle(
                        color: Colors.white), // Pastikan teks berwarna putih
                  ),
                  SizedBox(height: 15.0),
                  // Filter Buttons Section
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterButton(
                            label: 'All',
                            isSelected: true,
                            textColor: Colors.white),
                        SizedBox(width: 8.0),
                        FilterButton(
                            label: 'Lipstick', textColor: Colors.white),
                        SizedBox(width: 8.0),
                        FilterButton(
                            label: 'Eyeliner', textColor: Colors.white),
                        SizedBox(width: 8.0),
                        FilterButton(label: 'Mascara', textColor: Colors.white),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  // Responsive GridView Section
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600
                          ? 3
                          : 2, // 3 kolom untuk layar lebar, 2 kolom untuk layar kecil
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                    ),
                    itemCount:
                        4, // Menyesuaikan dengan jumlah produk yang Anda punya
                    itemBuilder: (context, index) {
                      return ProductCard(
                        imageUrl: 'assets/image/makeup.jpg',
                        title: 'Nama Produk Tidak Ditemukan',
                        brand: 'Brand Tidak Ditemukan',
                      );
                    },
                  ),
                  SizedBox(height: 16.0),
                  // Browse Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ListProduct()), // Ganti `[]` dengan daftar kamera jika diperlukan
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      child: Text('Browse for more'),
                    ),
                  ),
                  SizedBox(height: 10.0),
                ],
              ),
            ),
            Text(
              'Inspirations from the community',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'Playfair Display',
                fontWeight: FontWeight.w700,
                height: 4,
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
        ),
      ),
    );
  }
}

