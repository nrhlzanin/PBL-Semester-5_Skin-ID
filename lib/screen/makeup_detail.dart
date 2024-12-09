import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    final baseUrl = dotenv.env['BASE_URL'];
    final endpoint = dotenv.env['PRODUCT_ENDPOINT'];
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
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

  // Fungsi untuk memparsing hex color
  Color parseColor(String hexColor) {
    // Jika kode warna diawali dengan '#', kita hapus '#' dan tambahkan '0xFF' di depannya
    if (hexColor.startsWith('#')) {
      hexColor = hexColor.replaceFirst('#', '0xFF');
    }
    return Color(int.parse(hexColor));
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white), // Tombol kembali
            onPressed: () {
              Navigator.pop(
                  context); // Menutup halaman dan kembali ke halaman sebelumnya
            },
          ),

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

              // Warna Produk
              if (product['product_colors'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Warna Tersedia:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Warna putih untuk header
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      children: (product['product_colors'] as List)
                          .map<Widget>((color) {
                        final colorHex = color['hex_value'] ??
                            ''; // Mengambil hex value dengan default string kosong
                        final colorName = color['color_name'] ??
                            'Warna Tidak Dikenal'; // Mengambil nama warna, jika null gunakan default 'Warna Tidak Dikenal'

                        // Memparsing warna hex dan menampilkan warna serta nama warna
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              ColorCircle(
                                color:
                                    parseColor(colorHex), colorName: '', // Memparse warna hex
                              ),
                              const SizedBox(
                                  height:
                                      4.0), // Spasi antara lingkaran warna dan nama warna
                              Text(
                                colorName, // Nama warna, jika null akan menampilkan 'Warna Tidak Dikenal'
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors
                                      .white, // Warna putih untuk nama warna
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              const SizedBox(height: 16.0),

              // // Back Button
              // TextButton.icon(
              //   onPressed: () {
              //     Navigator.pop(context); // Kembali ke halaman sebelumnya
              //   },
              //   icon: const Icon(Icons.arrow_back, color: Colors.white),
              //   label:
              //       const Text('Back', style: TextStyle(color: Colors.white)),
              // ),
            ],
          ),
        ),
        
      ),
    );
  }
}

class ColorCircle extends StatelessWidget {
  final Color color;

  const ColorCircle({required this.color, Key? key, required String colorName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
