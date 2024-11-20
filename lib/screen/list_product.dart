import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/face-scan_screen.dart';
import 'package:skin_id/screen/makeup_detail.dart';
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
  List<dynamic> _makeupProducts = [];

  Future<List<dynamic>> fetchMakeupProducts() async {
    final url = 'http://192.168.1.7:8000/api/user/makeup-products/';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
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
        primarySwatch: Colors.grey,
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
                SizedBox(
                  width: 16.0,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 0, bottom: 5), // Mengurangi jarak atas dan bawah
                    child: Text(
                      'Find the make up that suits you from many brands across the world with many categories.',
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
            // Updated makeup section with proper styling
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              width: double.infinity, // Mengisi lebar penuh layar
              decoration: BoxDecoration(
                color: Color(0xFF242424),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        16, // Menyesuaikan dengan jumlah produk yang Anda punya
                    itemBuilder: (context, index) {
                      return ProductCard(
                        imageUrl: 'assets/image/makeup.jpg',
                        title: 'Nama Produk Tidak Ditemukan',
                        brand: 'Brand Tidak Ditemukan',
                      );
                    },
                  ),

                  SizedBox(height: 10.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(1),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Color(0xFF242424),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: IconButton(
        icon: Icon(Icons.camera_alt),
        color: Colors.white,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CameraPage()), // Ganti `[]` dengan daftar kamera jika diperlukan
          );
        },
      ),
    );
  }
}

class AvatarImage extends StatelessWidget {
  final String imageUrl;
  const AvatarImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.0,
      height: 64.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class SkinToneColor extends StatelessWidget {
  final Color color;
  const SkinToneColor({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      color: color,
      margin: EdgeInsets.all(4.0),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  const FilterButton({
    required this.label,
    this.isSelected = false,
    required Color textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color.fromARGB(255, 186, 190, 199)
            : const Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MakeupDetail(), // Halaman yang dituju
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    brand,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontFamily: 'Montserrat',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
