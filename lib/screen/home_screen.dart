// ignore_for_file: prefer_final_fields, unused_field, use_key_in_widget_constructors, prefer_const_declarations, avoid_print, prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last, unnecessary_string_interpolations, non_constant_identifier_names, sized_box_for_whitespace, curly_braces_in_flow_control_structures, unused_element

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Import http package
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/face-scan_screen.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/list_product.dart';
import 'package:skin_id/screen/makeup_detail.dart';
import 'package:skin_id/screen/notification_screen.dart'; // Import CameraPage
import 'dart:async';

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Future<List<dynamic>> fetchMakeupProducts() async {
    final baseUrl = dotenv.env['BASE_URL'];
    final endpoint = dotenv.env['PRODUCT_ENDPOINT'];
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));

      if (response.statusCode == 200) {
        // Parsing JSON dari response API
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Gagal memuat produk makeup');
      }
    } catch (e) {
      print('Terjadi kesalahan saat mengambil data: $e');
      return [];
    }
  }

// Fungsi untuk memeriksa apakah URL gambar valid dan dapat dimuat
  Future<bool> isImageAvailable(String? url) async {
    if (url == null || url.isEmpty) return false;
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200; // Gambar tersedia jika status 200
    } catch (e) {
      return false; // Jika terjadi error, anggap gambar tidak tersedia
    }
  }

// Filter produk dengan gambar yang benar-benar dapat dimuat
  Future<List<dynamic>> filterValidProducts(List<dynamic> products) async {
    List<dynamic> validProducts = [];
    for (var product in products) {
      final imageUrl = product['image_link'] as String?;
      if (await isImageAvailable(imageUrl)) {
        validProducts.add(product);
      }
    }
    return validProducts;
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
      debugShowCheckedModeBanner: false,
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
  bool hasSkintone = false;
  String skinTone = "Tidak diketahui";
  String skinDescription = "Deskripsi tidak tersedia";
  Color skinToneColor = Colors.grey;

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No token ditemukan. Silakan masuk.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_PROFILE_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');
      final response =
          await http.get(url, headers: {'Authorization': '$token'});

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
                skinDescription = skinDescription;
                skinToneColor = Color(
                    int.parse(hex_color.substring(1), radix: 16) + 0xFF000000);
                hasSkintone = true;
              });
            } catch (e) {
              print("Terjadi kesalahan saat mengurai warna heksadesimal: $e");
            }
          } else {
            print("Tidak Ada Warna Kulit yang Terdeteksi, tidak dapat menampilkan Warna Kulit");
            hasSkintone = false;
          }
        });
      }
    } catch (e) {
      print("Tidak Ada Warna Kulit yang Terdeteksi, tidak dapat menampilkan Warna Kulit");
    }
  }

  // Daftar kategori untuk filter
  List<String> categories = [
    'Semua',
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
  String selectedCategory = 'Semua';

  Future<bool> _onWillPop() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (Route<dynamic> route) => false,
    );
    return false;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredProducts = selectedCategory == 'Semua'
        ? _makeupProducts
        : _makeupProducts
            .where((product) =>
                product['product_type']?.toString().toLowerCase() ==
                selectedCategory.toLowerCase())
            .toList();

    List<dynamic> validFilteredProducts = filteredProducts.where((product) {
      final imageUrl = product['image_link'] as String?;
      return imageUrl != null &&
          imageUrl.isNotEmpty &&
          Uri.tryParse(imageUrl)?.isAbsolute == true;
    }).toList();

    return Scaffold(
      endDrawer: Navbar(),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Periksa Warna Kulit Anda',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w700,
                  height: 0,
                  letterSpacing: 0.03,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text.rich(
                              TextSpan(
                                text: 'Identifikasi warna kulit Anda menggunakan ',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    color:
                                        Colors.black), // Gaya umum untuk teks
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'AI',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text:
                                        ' untuk lebih memahami kulit Anda. Lebih banyak preferensi makeup dan rekomendasi konten berdasarkan warna kulit Anda.',
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6),
                Container(
                  width: 160,
                  height: 160,
                  child: Stack(
                    children: [
                      Positioned(
                        right: 16,
                        bottom: 0,
                        child: Container(
                          width: 90,
                          height: 90,
                          child: AvatarImage(
                              imageUrl: "assets/image/avatar2.jpeg"),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 90,
                          height: 90,
                          child: AvatarImage(
                              imageUrl: "assets/image/avatar1.jpeg"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.0),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CameraButton(),
                ),
                Text(
                  'Gunakan saya!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (hasSkintone)
              Container(
                padding: EdgeInsets.fromLTRB(24, 40, 24, 40),
                decoration: BoxDecoration(
                  color: skinToneColor,
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
                            'Warna Kulit Anda Adalah',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: skinToneColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            skinTone,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            margin: const EdgeInsets.all(20.0),
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 3,
                                  spreadRadius: 2,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Wrap(
                              direction: Axis.horizontal,
                              children: List.generate(6, (index) {
                                // Map index to skin tone
                                final tones = [
                                  "very_light",
                                  "light",
                                  "medium",
                                  "olive",
                                  "brown",
                                  "dark"
                                ];
                                final colors = [
                                  Color(0xFFFFDFC4),
                                  Color(0xFFF0D5BE),
                                  Color(0xFFD1A684),
                                  Color(0xFFA67C52),
                                  Color(0xFF825C3A),
                                  Color(0xFF4A312C),
                                ];
                                final isSelected =
                                    tones[index] == skinTone.toLowerCase();

                                return Stack(
                                  children: [
                                    Container(
                                      width: isSelected ? 32 : 32,
                                      height: isSelected ? 32 : 32,
                                      margin: EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: colors[index],
                                        borderRadius: BorderRadius.horizontal(
                                          left: index == 0
                                              ? Radius.circular(16)
                                              : Radius.zero,
                                          right: index == 5
                                              ? Radius.circular(16)
                                              : Radius.zero,
                                        ),
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.black,
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: -10,
                                        left: 0,
                                        right: 0,
                                        child: Icon(
                                          Icons.arrow_drop_up,
                                          color: Colors.black,
                                          size: 24,
                                        ),
                                      ),
                                  ],
                                );
                              }),
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
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
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
                    'Temukan makeup yang cocok untuk Anda dengan pilihan dari berbagai merek di seluruh dunia.',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15.0),
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
                  validFilteredProducts.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
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
                            childAspectRatio:
                                0.75, // Mengatur rasio lebar-tinggi item
                          ),
                          itemCount: min(validFilteredProducts.length,
                              6), // Maksimal 6 item
                          itemBuilder: (context, index) {
                            final product = validFilteredProducts[index];

                            return Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  // Navigasi ke MakeupDetail dengan data produk
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MakeupDetail(product: product),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Container untuk gambar
                                    Expanded(
                                      flex:
                                          3, // Bagian gambar mengambil lebih banyak ruang
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(8.0)),
                                        child: Image.network(
                                          product['image_link'] ?? '',
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
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    // Container untuk teks
                                    Expanded(
                                      flex:
                                          2, // Bagian teks lebih kecil dibanding gambar
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
                                                  'Tipe Produk',
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
                                              product['name'] ?? 'Nama Produk',
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
                                                  'Merek Produk',
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
                      child: Text('Telusuri lebih banyak'),
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
        icon: Icon(Icons.face_retouching_natural),
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

  const FilterButton(
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
String selectedCategory = 'Semua';