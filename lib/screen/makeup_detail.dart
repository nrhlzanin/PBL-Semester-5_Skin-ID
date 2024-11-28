import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MakeupDetail(product: {}));
}

class MakeupDetail extends StatefulWidget {
  final dynamic product; // Data produk diterima sebagai parameter
  const MakeupDetail({Key? key, required this.product}) : super(key: key);

  @override
  _MakeUpDetailState createState() => _MakeUpDetailState();
}

class _MakeUpDetailState extends State<MakeupDetail> {
  List<dynamic> _makeupProducts = [];

  // Fetch makeup products from the API
  Future<List<dynamic>> fetchMakeupProducts() async {
    const url =
        'http://127.0.0.1:8000/api/makeup-products/'; // Ganti dengan URL API Anda
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
    fetchMakeupProducts().then((product) {
      setState(() {
        _makeupProducts = product;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product; // Akses data produk

    return MaterialApp(
      title: 'YourSkin-ID',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'Caveat',
        brightness: Brightness.dark, // Set the overall app theme to dark
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black, // Set Scaffold background to black
        appBar: AppBar(
          title: Text(
            product['name'] ?? 'Product Detail',
            style: GoogleFonts.caveat(
              color: Colors.white, // Set text color to white
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: Colors.black, // Set app bar background to black
          iconTheme:
              IconThemeData(color: Colors.white), // Set icon color to white
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.network(
                    product['image_link'] ??
                        'https://via.placeholder.com/300', // Placeholder if image link is empty
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Product Name
              Text(
                product['name'] ?? 'Unknown Product',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Set text color to white
                ),
              ),
              const SizedBox(height: 8.0),
              // Brand
              Text(
                product['brand'] ?? 'Unknown Brand',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey, // Light gray for brand text
                ),
              ),
              const SizedBox(height: 16.0),
              // Product Description
              Text(
                product['description'] ??
                    'No description available', // Product description
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white, // White color for description
                ),
              ),
              const SizedBox(height: 16.0),
              // Product Price
              Text(
                'Price: \$${product['price'] ?? 'N/A'}', // Product price
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White color for price
                ),
              ),
              const SizedBox(height: 16.0),
              // Product Colors
              Text(
                'Product Colors:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White color for headers
                ),
              ),
              const SizedBox(height: 8.0),
            product['product_colors'] != null && (product['product_colors'] as List).isNotEmpty
    ? Wrap(
        spacing: 8.0,
        children: (product['product_colors'] as List).map((color) {
          // Ambil nilai hex_value dari produk, fallback ke warna default jika null
          String hexColor = color['hex_value']?.replaceAll('#', '') ?? '000000';

          // Validasi panjang hexColor
          if (hexColor.length != 6) {
            hexColor = '000000'; // fallback ke warna hitam
          }

          try {
            // Mengonversi hex menjadi warna dengan menambahkan '0xFF' untuk channel alpha (opacity 100%)
            return ColorCircle(
              color: Color(int.parse('0xFF$hexColor', radix: 16)),
            );
          } catch (e) {
            // Jika terjadi kesalahan parsing, fallback ke warna hitam
            return ColorCircle(
              color: Color(0xFF000000),
            );
          }
        }).toList(),
      )
    : const Text('No colors available'),

              const SizedBox(height: 16.0),
              // Back Button
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label:
                    const Text('Back', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorCircle extends StatelessWidget {
  final Color color;

  const ColorCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
