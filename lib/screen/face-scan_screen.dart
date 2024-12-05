// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print, unnecessary_null_in_if_null_operators, unnecessary_string_interpolations

import 'dart:typed_data'; // Untuk bekerja dengan Uint8List
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/home_screen.dart';
import 'package:skin_id/screen/notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math' as math;
import 'package:skin_id/screen/recomendation.dart';
import 'package:http/http.dart' as http;
import 'package:skin_id/screen/skin_identification.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  Uint8List? _imageBytes;
  String? skinToneResult;
  List<dynamic>? recommendedProducts;
  bool isLoading = false;
  bool hasRecommendations = false;
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.length > 1) {
        _controller = CameraController(cameras![1], ResolutionPreset.high);
        await _controller!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      } else {
        print("No sufficient cameras available");
      }
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
          skinToneResult =
              responseData['skintone_name']; // Menyimpan hasil skin_tone
        });
        _getRecommendations();
      } else {
        print("Failed to get prediction. Status code: ${response.statusCode}");
        setState(() {
          skinToneResult = "Failed to get prediction";
        });
      }
    } catch (e) {
      print("Error capturing and predicting: $e");
      setState(() {
        skinToneResult = "Error occurred while predicting skin tone.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Unable to process the image")),
      );
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

      setState(() {
        isFetching = true;
        isLoading = true;
      });

      final response =
          await http.get(url, headers: {'Authorization': '$token'});

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        setState(() {
          recommendedProducts = responseData['recommended_products'];
          hasRecommendations = true;
        });
      } else {
        setState(() {
          recommendedProducts = [];
          hasRecommendations = false;
        });
        print("Failed to fetch recommendations: ${response.body}");
      }
    } catch (e) {
      print("Error getting recommendations: $e");
      setState(() {
        recommendedProducts = [];
      });
    } finally {
      setState(() {
        isFetching = false;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

    // Fungsi untuk memeriksa status pembaruan skintone dan menentukan halaman tujuan
  Future<int?> _getSkintoneId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please log in.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_PROFILE_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.get(url, headers: {'Authorization': token});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Response Data: $data");  // Log data untuk memeriksa struktur data
        
        // Mengakses skintone_id yang ada dalam objek skintone dan memastikan ia merupakan tipe int
        final skintoneId = data['skintone']?['skintone_id'] ?? null;

        print("Skintone ID: $skintoneId");  // Log untuk memeriksa nilai skintone_id

        return skintoneId is int ? skintoneId : null;  // Mengembalikan skintone_id jika tipe int
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else {
        print("Error: Failed to fetch skintone data. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching skintone: $e");
      return null;
    }
  }

  // Fungsi untuk menangani aksi ketika kembali ditekan
  Future<bool> _onWillPop() async {
    int? skintoneId = await _getSkintoneId();

    // Menentukan halaman berdasarkan skintone_id
    if (skintoneId != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Home()),  // Halaman Home jika skintone_id ada
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),  // Halaman HomeScreen jika skintone_id tidak ada
        (Route<dynamic> route) => false,
      );
    }
    return false;  // Menghentikan aksi kembali default
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,  // Menangani aksi tombol back
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () async {
                int? skintoneId = await _getSkintoneId();
                // Tentukan halaman tujuan berdasarkan skintone_id
                if (skintoneId != null) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),  // Jika skintone_id ada
                    (Route<dynamic> route) => false,
                  );
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),  // Jika skintone_id tidak ada
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          title: Text(
            'YourSkin-ID',
            style: GoogleFonts.caveat(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        body: Stack(
          children: [
            if (_isCameraInitialized)
              Positioned.fill(
                child: Transform(
                  alignment: Alignment.center,
                  transform: _controller?.description.lensDirection ==
                          CameraLensDirection.front
                      ? Matrix4.rotationY(
                          math.pi) // Membalikkan tampilan kamera depan
                      : Matrix4
                          .identity(), // Tidak melakukan apa-apa untuk kamera belakang
                  child: CameraPreview(_controller!),
                ),
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
                          'Skin Tone Result: $skinToneResult',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
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
                        if (isFetching)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 10),
                                Text(
                                  "Mohon tunggu sistem sedang membuat rekomendasi...",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (hasRecommendations)
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Recomendation(),
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
                                    hasRecommendations = false;
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
      ),
    );
  }
}
