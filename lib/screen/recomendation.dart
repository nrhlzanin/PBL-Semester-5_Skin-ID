import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/list_product.dart';
import 'package:skin_id/screen/makeup_detail.dart';
import 'package:skin_id/screen/notification_screen.dart';

class Recomendation extends StatefulWidget {
  @override
  _RecomendationState createState() => _RecomendationState();
}

class _RecomendationState extends State<Recomendation> {
  String skinTone = "Light";
  String skinDescription =
      "Your skin has higher skin moisture, low skin elasticity, good sebum, low moisture, and uneven texture. This skin type is more sensitive to UV rays and tends to experience more severe photo-aging.";
  int _currentIndex = 0;
  List<dynamic> _makeupProducts = [];

  Future<List<dynamic>> fetchMakeupProducts() async {
    const url = 'http://172.0.0.1:8000/api/user/makeup-products/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        print('Failed to load data: ${response.statusCode}');
        throw Exception('Failed to load makeup products');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _makeupProducts = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data. Silakan coba lagi.')),
      );
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

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void updateSkinDetails(String tone, String description) {
    setState(() {
      skinTone = tone;
      skinDescription = description;
    });
  }

  @override
  Widget build(BuildContext context) {
    final validProducts = _makeupProducts.where((product) {
      return product['image_link'] != null && product['image_link'].isNotEmpty;
    }).toList();

    return Scaffold(
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
      body: GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: validProducts.length,
        itemBuilder: (context, index) {
          final product = validProducts[index];
          return GestureDetector(
            onTap: () {
              print('Clicked on ${product['name']}');
            },
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.network(
                      product['image_link'],
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Container();
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    product['name'] ?? 'Nama Produk',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    product['brand'] ?? 'Merek Produk',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RecomendationPage extends StatelessWidget {
  final String skinTone;
  final String skinDescription;

  RecomendationPage({
    required this.skinTone,
    required this.skinDescription,
  });

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
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skin Identification',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'Playfair Display',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Your Skin Tone Is',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontFamily: 'Playfair Display',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFF4C2C2),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkinToneColor(color: Color(0xFFF4C2C2)),
                SkinToneColor(color: Color(0xFFE6A57E)),
                SkinToneColor(color: Color(0xFFD2B48C)),
                SkinToneColor(color: Color(0xFFC19A6B)),
                SkinToneColor(color: Color(0xFF8D5524)),
                SkinToneColor(color: Color(0xFF7D4B3E)),
              ],
            ),
            SizedBox(height: 16),
            Text(
              skinTone,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
            SizedBox(height: 16),
            Text(
              skinDescription,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF242424),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Makeup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    'Find makeup that suits you with choices from many brands around the world.',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 15.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterButton(label: 'All', isSelected: true, textColor: Colors.white),
                        SizedBox(width: 8.0),
                        FilterButton(label: 'Lipstick', textColor: Colors.white),
                        SizedBox(width: 8.0),
                        FilterButton(label: 'Eyeliner', textColor: Colors.white),
                        SizedBox(width: 8.0),
                        FilterButton(label: 'Mascara', textColor: Colors.white),
                      ],
                    ),
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

class SkinToneColor extends StatelessWidget {
  final Color color;
  SkinToneColor({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color textColor;

  FilterButton({required this.label, this.isSelected = false, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange[800] : Colors.transparent,
        border: Border.all(
          color: isSelected ? Colors.orange[800]! : Colors.white,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Text(
          label,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
