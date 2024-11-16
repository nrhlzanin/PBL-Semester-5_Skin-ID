import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Import http package
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/face-scan_screen.dart';
import 'package:skin_id/screen/makeup_detail.dart'; // Import CameraPage

void main() {
  runApp(HomeScreen());
}

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
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(1),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Color(0xFF242424),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
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
            Row(
              children: [
                SkinToneColor(color: Color(0xFFF4C2C2)),
                SkinToneColor(color: Color(0xFFE6A57E)),
                SkinToneColor(color: Color(0xFFD2B48C)),
                SkinToneColor(color: Color(0xFFC19A6B)),
                SkinToneColor(color: Color(0xFF8D5524)),
                SkinToneColor(color: Color(0xFF7D4B3E)),
              ],
            ),
            // Updated makeup section with proper styling
            Container(
              width: double.infinity, // Mengisi lebar penuh layar
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              decoration: BoxDecoration(
                color: Color(0xFF242424),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 7.0),
                  Text(
                    'Makeup ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.w700,
                      height: 0.03,
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    'Find makeup that suits you with choices from many brands around the world.',
                    style:
                        TextStyle(color: Colors.white), // Ensure text is white
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      FilterButton(
                          label: 'All',
                          isSelected: true,
                          textColor: Colors.white), // Text color set to white
                      SizedBox(width: 8.0),
                      FilterButton(
                          label: 'Lipstick',
                          textColor: Colors.white), // Text color set to white
                      SizedBox(width: 8.0),
                      FilterButton(
                          label: 'Eyeliner',
                          textColor: Colors.white), // Text color set to white
                      SizedBox(width: 8.0),
                      FilterButton(
                          label: 'Mascara',
                          textColor: Colors.white), // Text color set to white
                    ],
                  ),
                  SizedBox(height: 16.0),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    children: [
                      // Menggunakan data yang didapatkan dari API atau data default
                      ProductCard(
                        imageUrl:
                            'assets/image/makeup.jpg', // Gambar dari asset
                        title: 'Nama Produk Tidak Ditemukan', // Nama produk
                        brand: 'Brand Tidak Ditemukan', // Brand produk
                      ),
                      // Product lainnya dengan data yang sesuai dari API atau data default
                      ProductCard(
                        imageUrl:
                            'assets/image/makeup.jpg', // Gambar placeholder dari asset
                        title: 'Nama Produk Tidak Ditemukan', // Nama produk
                        brand: 'Brand Tidak Ditemukan', // Brand produk
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Action for browsing more
                          },
                          child: Text('Browse for more'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                        ),
                      ),
                    ],
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MakeupDetail(),
          ),
        );
      },
      child: Card(
        elevation: 8.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Column(
          children: [
            Image.asset(
              imageUrl, // Menampilkan gambar dari asset
              fit: BoxFit.cover,
              height: 150, // Atur tinggi gambar sesuai kebutuhan
              width: double.infinity, // Lebar gambar mengikuti lebar container
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    title,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    brand,
                    style: TextStyle(color: Colors.grey),
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
          Image.network(imageUrl),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                Text(subtitle),
                SizedBox(height: 4.0),
                Text('By $author'),
                SizedBox(height: 8.0),
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
