import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:skin_id/button/bottom_navigation.dart';
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/face-scan_screen.dart';
import 'package:skin_id/screen/home_screen.dart';
import 'package:skin_id/screen/makeup_detail.dart'; // Import CameraPage
// Import BottomNavigation

void main() {
  runApp(MakeupDetail());
}

class MakeupDetail extends StatefulWidget {
  @override
  _MakeUpDetailState createState() => _MakeUpDetailState();
}

class _MakeUpDetailState extends State<MakeupDetail> {
  int _currentIndex = 0; // To keep track of selected bottom navigation item
  List<dynamic> _makeupProducts = [];

  // Fetch makeup products from the API
  Future<List<dynamic>> fetchMakeupProducts() async {
    final url = 'http://127.0.0.1:8000/api/makeup-products/';
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
  void initState() {
    super.initState();
    // Fetch makeup products when the widget is initialized
    fetchMakeupProducts().then((product) {
      setState(() {
        _makeupProducts = product;
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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
        ),
        body: Stack(
          // Stack digunakan untuk menumpuk widget
          children: [
            // Background hitam
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal:
                        20.0), // Memberikan ruang 20px di kiri dan kanan
                color: Color(0xFF242424), // Background hitam
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.asset(
                          'assets/image/makeup.jpg',
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Konten lainnya
                    Text(
                      "L'Absolu Rouge Drama - Matte Lipstick",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'LANCOME',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      "Where luxury meets bold. L'Absolu Rouge Drama Matte Lipstick is the ultimate bold lipstick powered by pure pigments for a vibrant and matte finish. Our new formula is enriched with rose extracts and hyaluronic acid to provide lips with lasting moisture and comfort. Available in 18 beautiful shades, the petal shaped bullet allows for ease of application for bold lipstick color in one swipe.",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),

                    SizedBox(height: 16.0),
                    Text(
                      'Recommendation Colors',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),

                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        ColorCircle(Colors.red[600]!),
                        ColorCircle(Colors.red[400]!),
                        ColorCircle(Colors.red[800]!),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'All colors',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        ColorCircle(Colors.red[600]!),
                        ColorCircle(Colors.red[400]!),
                        ColorCircle(Colors.purple[600]!),
                        ColorCircle(Colors.purple[400]!),
                        ColorCircle(Colors.red[800]!),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // Pindah ke halaman CameraPage ketika button di-tap
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HomeScreen(), // Ganti dengan halaman yang sesuai
                              ),
                            );
                          },
                          icon: Icon(Icons.arrow_back),
                          label: Text('Back',
                              style: TextStyle(
                                  color: Colors
                                      .white)), // Menambahkan warna putih pada teks
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigation(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            // You can use Navigator to navigate between different screens as needed.
          },
        ), // Add the BottomNavigation widget
      ),
    );
  }
}

class ColorCircle extends StatelessWidget {
  final Color color;

  ColorCircle(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
