import 'dart:typed_data'; // Untuk bekerja dengan Uint8List
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/home.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:skin_id/screen/notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math' as math;  

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  Uint8List? _imageBytes; // Menyimpan gambar yang diambil dalam bentuk bytes
  String? skinToneResult;
  List<dynamic>? recommendedProducts;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras![0], ResolutionPreset.high);

    await _controller!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _captureAndPredict() async {
    try {
      // Ambil gambar
      final picture = await _controller!.takePicture();
      final imageBytes = await picture.readAsBytes();

      // Kirim gambar ke Django API
      final response = await _sendImageToServer(imageBytes);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          skinToneResult = responseData['skin_tone'];
        });

        // Ambil rekomendasi produk
        await _getRecommendations();
      } else {
        setState(() {
          skinToneResult = "Failed to get prediction";
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<http.Response> _sendImageToServer(Uint8List imageBytes) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print("Token sent to server: $token");

    if (token == null) {
      print('No token found. User is not logged in.');
      throw Exception('User is not logged in');
    }
    final baseUrl = dotenv.env['BASE_URL'];
    final endpoint = dotenv.env['SKIN_PREDICT_ENDPOINT'];
    final url = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', url);

    // Tambahkan file gambar
    request.files.add(
      http.MultipartFile.fromBytes('image', imageBytes, filename: 'skin.jpg'),
    );

    // Tambahkan header Authorization
    request.headers.addAll({
      'Authorization': '$token', // Kirim token ke backend
      // 'Content-Type': 'multipart/form-data', // Perhatikan tipe konten
    });

    // Kirim request ke server
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print('Image sent successfully.');
    } else {
      print('Failed to send image: ${response.body}');
    }

    return response;
  }

  Future<void> _getRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print('No token found. User is not logged in.');
      throw Exception('User is not logged in');
    }

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['RECOMMENDATION_ENDPOINT'];
      final url =
          Uri.parse('$baseUrl$endpoint');
      final response = await http.get(
        url,
        headers: {
          'Authorization': '$token', // Sertakan token
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          recommendedProducts = responseData['recommended_products'];
        });
        print('Recommendations fetched successfully.');
      } else {
        setState(() {
          recommendedProducts = [];
        });
        print("Failed to get recommendations: ${response.body}");
      }
    } catch (e) {
      print("Error getting recommendations: $e");
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (skinToneResult != null)
              Text(
                'Detected Skin Tone: $skinToneResult',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 10),
            if (recommendedProducts != null)
              ...recommendedProducts!.map((product) => ListTile(
                    leading: Image.network(product['image_url']),
                    title: Text(product['name']),
                    subtitle:
                        Text('${product['brand']} - ${product['price']} USD'),
                  )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

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
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isCameraInitialized)
            Positioned.fill(
              child: Transform(
                alignment: Alignment.center,
                transform: _controller?.description.lensDirection == CameraLensDirection.front
                    ? Matrix4.rotationY(math.pi)  // Membalikkan tampilan kamera depan
                    : Matrix4.identity(), // Tidak melakukan apa-apa untuk kamera belakang
                child: CameraPreview(_controller!),
              ),
            )
          else
            Center(child: CircularProgressIndicator()
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: IconButton(
              icon: Icon(Icons.camera, color: Colors.black, size: 40),
              onPressed: () async {
                try {
                  await _captureAndPredict();
                  _showResultDialog();
                } catch (e) {
                  print("Error capturing image: $e");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
