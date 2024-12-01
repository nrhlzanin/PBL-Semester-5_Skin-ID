import 'dart:typed_data'; // Untuk bekerja dengan Uint8List
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skin_id/screen/recomendation.dart';
import 'package:http/http.dart' as http;
import 'package:skin_id/screen/recomendation_copy.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  Uint8List? _imageBytes; // Menyimpan gambar yang diambil dalam bentuk bytes
  String? skinToneResult; // Variabel untuk menyimpan hasil prediksi warna kulit
  List<dynamic>? recommendedProducts;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      _controller = CameraController(cameras![0], ResolutionPreset.high);

      await _controller!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<void> _captureAndPredict() async {
    try {
      print("Capturing image...");
      final picture = await _controller!.takePicture();
      final imageBytes = await picture.readAsBytes();

      setState(() {
        _imageBytes = imageBytes;
      });

      print("Sending image to server...");
      final response = await _sendImageToServer(imageBytes);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("Decoded response data: $responseData");
        setState(() {
          skinToneResult = responseData['skintone_name']; // Menyimpan hasil skin_tone
        });
      } else {
        print("Failed to get prediction. Status code: ${response.statusCode}");
        setState(() {
          skinToneResult = "Failed to get prediction";
        });
              _getRecommendations();
      }
    } catch (e) {
      print("Error capturing and predicting: $e");
    }
  }

  Future<http.Response> _sendImageToServer(Uint8List imageBytes) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) throw Exception('User is not logged in.');

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['SKIN_PREDICT_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');

      print("Base URL: $baseUrl");
      print("Endpoint: $endpoint");

      final request = http.MultipartRequest('POST', url);

      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: 'skin.jpg'),
      );

      request.headers.addAll({'Authorization': '$token'});

      print("Headers: ${request.headers}");
      print("Sending request to server...");

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      print("Error sending image to server: $e");
      rethrow;
    }
  }


  Future<void> _getRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) throw Exception('User is not logged in.');

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['RECOMMENDATION_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');

      final response =
          await http.get(url, headers: {'Authorization': '$token'});

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          recommendedProducts = responseData['recommended_products'];
        });
      } else {
        setState(() {
          recommendedProducts = [];
        });
        print("Failed to fetch recommendations: ${response.body}");
      }
    } catch (e) {
      print("Error getting recommendations: $e");
    }
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
              child: CameraPreview(_controller!),
            )
          else
            Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: IconButton(
              icon: Icon(Icons.camera, color: Colors.black, size: 40),
              onPressed: () async {
                try {
                  await _captureAndPredict();
                } catch (e) {
                  print("Error capturing image: $e");
                }
              },
            ),
          ),
          if (_imageBytes != null)
            Center(
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Skin Tone Result: $skinToneResult', // Menampilkan hasil skin_tone
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      if (_imageBytes != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _imageBytes!,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 10),
                      Text(
                        skinToneResult ?? 'No result available',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Recomendation2(),
                                ),
                              );
                            },
                            child: Text("Recommendations"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _imageBytes = null;
                                skinToneResult = null;
                              });
                            },
                            child: Text("Retake"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
