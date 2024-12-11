// ignore_for_file: avoid_print, unused_field, use_super_parameters

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart'; //SEK ERROR
import 'package:flutter/services.dart';

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

  // UNTUK MENGARAHKAN LINK KE URL
  Future<void> openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Tidak dapat membuka URL: $url");
    }
  }
  // END MENGARAHKAN LINK KE URL

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
        throw Exception('Gagal memuat produk makeup');
      }
    } catch (e) {
      print('Terjadi kesalahan saat mengambil data: $e');
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

  // Fungsi untuk membuka URL
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url); // Membuka URL
    } else {
      throw 'URL tidak dapat diluncurkan $url'; // Menangani jika URL tidak bisa dibuka
    }
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
                product['name'] ?? 'Produk Tidak Dikenal',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Set text color to white
                ),
              ),
              const SizedBox(height: 8.0),
              // Brand
              Text(
                product['brand'] ?? 'Brand Tidak Dikenali',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey, // Light gray for brand text
                ),
              ),
              const SizedBox(height: 16.0),
              // Product Description
              Text(
                product['description'] ??
                    'Tidak ada deskripsi tersedia', // Product description
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white, // White color for description
                ),
                textAlign: TextAlign.justify,
              ),
                            const SizedBox(height: 16.0),
              if (product['product_link'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: GestureDetector(
                    onTap: () => _launchURL(product['product_link']),
                    child: Text(
                      'Link Produk',
                      style: TextStyle(
                        fontSize: 16,  // Sesuaikan ukuran font agar konsisten
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
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
              const SizedBox(height: 8.0),
              // LINK PEMBELIAN
              // if (product['product_link'] != null)
              //   GestureDetector(
              //     onTap: () {
              //       openLink(product['product_link']);
              //     },
              //     child: Container(
              //       margin: const EdgeInsets.symmetric(
              //           vertical: 6.0, horizontal: 0),
              //       padding: const EdgeInsets.all(8.0),
              //       decoration: BoxDecoration(
              //         color: Colors.white.withOpacity(0.2),
              //         borderRadius: BorderRadius.circular(10.0),
              //         boxShadow: [
              //           BoxShadow(color: const Color.fromARGB(255, 24, 24, 24)),
              //         ],
              //         border: Border.all(
              //           color: Colors.white.withOpacity(0.3),
              //           width: 1.0,
              //         ),
              //       ),
              //       child: Text(
              //         'Beli Sekarang',
              //         textAlign: TextAlign.center,
              //         style: const TextStyle(
              //           fontSize: 16,
              //           fontWeight: FontWeight.w100,
              //           color: Colors.white,
              //           decoration: TextDecoration.underline,
              //         ),
              //       ),
              //     ),
              //   ),
              Text(
                'Link Pembelian', // Perbaiki agar harga dapat muncul
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.2), // Warna latar belakang semi-transparan
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10.0,
                      spreadRadius: 5.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white
                        .withOpacity(0.3), // Warna border semi-transparan
                    width: 1.0,
                  ),
                ),
                child: Stack(
                  children: [
                    // Teks Link
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${product['product_link'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Ikon Salin di Pojok Kanan Atas
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          final link = product['product_link'] ?? 'N/A';
                          print('Link yang disalin: $link');
                          if (link != 'N/A') {
                            Clipboard.setData(ClipboardData(text: link));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Link telah disalin ke clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Icon(
                          Icons.copy,
                          size: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // END LINK PEMBELIAN
              // WARNA PRODUK
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
                                color: parseColor(colorHex),
                                colorName: '', // Memparse warna hex
                              ),
                              const SizedBox(
                                  height:
                                      4.0), // Spasi antara lingkaran warna dan nama warna
                              SizedBox(
                                width: 100,
                                child: Text(
                                  colorName, // Nama warna, jika null akan menampilkan 'Warna Tidak Dikenal'
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors
                                        .white, // Warna putih untuk nama warna
                                  ),
                                  textAlign: TextAlign.center,
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
            ],
          ),
        ),
      ),
    );
  }
}

class ColorCircle extends StatelessWidget {
  final Color color;

  const ColorCircle({required this.color, Key? key, required String colorName})
      : super(key: key);

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
