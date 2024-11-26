// ignore_for_file: prefer_final_fields, unused_field, use_key_in_widget_constructors, prefer_const_declarations, avoid_print, prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Import http package
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/face-scan_screen.dart';
import 'package:skin_id/screen/home.dart';
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
              padding: const EdgeInsets.all(16.0),
              child: Text(
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
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CameraButton(),
                ),
                SizedBox(width: 5),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Identify your skin tone using our AI for a better understanding of your skin. More makeup preferences and content recommendations based on your skin tone.',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 17), // Set color of the text
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.0),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                  child: AvatarImage(imageUrl: "assets/image/avatar1.jpeg"),
                ),
                SizedBox(width: 16.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: AvatarImage(imageUrl: "assets/image/avatar2.jpeg"),
                ),
              ],
            ),
            SizedBox(height: 16.0),
          Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
      SizedBox(height: 16), // Menambahkan jarak antara Row dan Column
      SkinIdentificationCard(),
    ],
  ),
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
                      color: Colors.white,
                    ),
                  ),
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
                  SizedBox(height: 20),
                  // Display selected category products in GridView
                  filteredProducts.isEmpty
                      ? Center(
                          child: Text(
                            'Not Found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(16.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                                  print('Clicked on ${product['name']}');
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
                  SizedBox(height: 16.0),
                  // Browse Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListProduct(),
                          ),
                        );
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
                  SizedBox(height: 10.0),
                ],
              ),
            ),

            // Text(
            //   'Inspirations from the community',
            //   style: TextStyle(
            //     color: Colors.black,
            //     fontSize: 25,
            //     fontFamily: 'Playfair Display',
            //     fontWeight: FontWeight.w700,
            //     height: 4,
            //   ),
            // ),
            // GridView.count(
            //   crossAxisCount: 2,
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   crossAxisSpacing: 16.0,
            //   mainAxisSpacing: 16.0,
            //   children: [
            //     CommunityCard(
            //       imageUrl:
            //           'https://storage.googleapis.com/a1aa/image/zRIoLp5MScojNhaNOYN6K07c9Gymwm7PbdCGuhWM7dDVHU8E.jpg',
            //       title: 'Tutorial make up shade',
            //       subtitle: 'Tutorial make up',
            //       author: 'Beauty',
            //       likes: 2017,
            //       comments: 333,
            //     ),
            //     CommunityCard(
            //       imageUrl:
            //           'https://storage.googleapis.com/a1aa/image/N8QFqmhw3644G1AqeYo4Amvblmowlr86IIGKJIlyIw0oOo4JA.jpg',
            //       title: 'Lumme brand new products',
            //       subtitle: 'Lumme',
            //       author: 'Women',
            //       likes: 1115,
            //       comments: 555,
            //     ),
            //   ],
            // ),
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

// class CommunityCard extends StatelessWidget {
//   final String imageUrl;
//   final String title;
//   final String subtitle;
//   final String author;
//   final int likes;
//   final int comments;

//   const CommunityCard({
//     required this.imageUrl,
//     required this.title,
//     required this.subtitle,
//     required this.author,
//     required this.likes,
//     required this.comments,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 8.0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0),
//       ),
//       child: Column(
//         children: [
//           // Set a fixed height for the image
//           Container(
//             height: 150, // Fixed height for the image
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
//               image: DecorationImage(
//                 image: NetworkImage(imageUrl),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Title with overflow handling
//                 Text(
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   title,
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 4.0),
//                 // Subtitle with overflow handling
//                 Text(
//                   subtitle,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 4.0),
//                 // Author text
//                 Text(
//                   'By $author',
//                   style: TextStyle(fontSize: 12),
//                 ),
//                 SizedBox(height: 8.0),
//                 // Likes and comments section
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.thumb_up, size: 16),
//                         SizedBox(width: 4.0),
//                         Text('$likes'),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         Icon(Icons.comment, size: 16),
//                         SizedBox(width: 4.0),
//                         Text('$comments'),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class ColorBox extends StatelessWidget {
  final String color;

  const ColorBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Color(int.parse("0xFF${color.substring(1)}")),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

class SkinIdentificationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8D4),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
          ),
        ],
      ),
      width: 800,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Start of added content (from the second code)
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
                SizedBox(height: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSkinToneColor(Color(0xFFF5E4D7)),
                    _buildSkinToneColor(Color(0xFFE0C4A8)),
                    _buildSkinToneColor(Color(0xFFC49A6C)),
                    _buildSkinToneColor(Color(0xFFA66B3F)),
                    _buildSkinToneColor(Color(0xFF7B3F1B)),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'White',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'This skin has higher skin moisture, low skin elasticity, good gloss, low melanin and erythema levels. This skin type is more sensitive to UV rays and tends to experience more severe photo-aging.',
            style: TextStyle(
              color: Color(0xFF2B2B2B),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Widget _buildSkinToneColor(Color color) {
  return Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: Colors.white),
    ),
  );
}
