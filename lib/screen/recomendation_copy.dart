import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/notification_screen.dart';

class Recomendation2 extends StatefulWidget {
  final String? skinToneResult;
  final String? skinDescription;

  Recomendation2({this.skinToneResult, this.skinDescription});

  @override
  _RecommendationState2 createState() => _RecommendationState2();
}

class _RecommendationState2 extends State<Recomendation2> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  Uint8List? _imageBytes;
  String? skinToneResult;
  String? skinDescription;
  List<dynamic>? recommendedProducts;
  bool isLoading = true;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    skinToneResult = widget.skinToneResult;
    skinDescription = widget.skinDescription;
    _initializeCamera();
    _getRecommendations();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _controller = CameraController(cameras![0], ResolutionPreset.high);
      await _controller!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _captureAndPredict() async {
    try {
      final picture = await _controller!.takePicture();
      final imageBytes = await picture.readAsBytes();

      setState(() {
        _imageBytes = imageBytes;
      });

      final response = await _sendImageToServer(imageBytes);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          skinToneResult = responseData['skintone_name'];
          skinDescription = responseData['description'];
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Recomendation2(
              skinToneResult: skinToneResult,
              skinDescription: skinDescription,
            ),
          ),
        );
      } else {
        setState(() {
          skinToneResult = "Failed to get prediction";
          skinDescription = "Unable to determine skin tone";
        });
      }
    } catch (e) {
      print("Error capturing and predicting: $e");
      setState(() {
        skinToneResult = "Error capturing image";
        skinDescription = "An error occurred during image capture.";
      });
    }
  }

  Future<http.Response> _sendImageToServer(Uint8List imageBytes) async {
    final prefs = await _prefs;
    final token = prefs.getString('auth_token');

    if (token == null) throw Exception('User is not logged in.');

    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['SKIN_PREDICT_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');

      final request = http.MultipartRequest('POST', url)
        ..files.add(http.MultipartFile.fromBytes('image', imageBytes,
            filename: 'skin.jpg'))
        ..headers.addAll({'Authorization': ' $token'});

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      print("Error sending image to server: $e");
      rethrow;
    }
  }

  Future<void> _getRecommendations() async {
    try {
      final prefs = await _prefs;
      String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('User is not logged in or token is missing.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['RECOMMENDATION_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');

      final response =
          await http.get(url, headers: {'Authorization': ' $token'});

      if (response.statusCode == 401) {
        // Token might be expired, handle token refresh
        await _refreshToken();
        return; // Retry after refresh
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          recommendedProducts = responseData['recommended_products'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          recommendedProducts = [];
        });
        throw Exception('Failed to fetch recommendations');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        recommendedProducts = [];
      });
      print("Error getting recommendations: $e");
    }
  }

  Future<void> _refreshToken() async {
    try {
      // Assuming you have a refresh token endpoint
      final prefs = await _prefs;
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No refresh token available');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final url = Uri.parse(
          '$baseUrl/refresh_token'); // Replace with actual refresh token endpoint

      final response =
          await http.post(url, body: {'refresh_token': refreshToken});

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final newToken = responseData['access_token'];

        if (newToken != null) {
          prefs.setString('auth_token', newToken);
          _getRecommendations(); // Retry fetching recommendations
        } else {
          throw Exception('Failed to refresh token');
        }
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      print("Error refreshing token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RecommendationPage(
      skinTone: skinToneResult ?? "Loading...",
      skinDescription:
          skinDescription ?? "Please wait while we analyze your skin.",
      recommendedProducts: recommendedProducts ?? [],
      isLoading: isLoading,
    );
  }
}

class RecommendationPage extends StatelessWidget {
  final String skinTone;
  final String skinDescription;
  final List<dynamic> recommendedProducts;
  final bool isLoading;

  RecommendationPage({
    required this.skinTone,
    required this.skinDescription,
    required this.recommendedProducts,
    required this.isLoading,
  });

  // Function to filter the recommended products based on skin tone
  List<dynamic> _filterRecommendedProducts(String skinTone) {
    // Map the skin tone to color
    Color skinToneColor;
    switch (skinTone.toLowerCase().trim()) {
      case "very light":
      case "light":
        skinToneColor = Color(0xFFF0D5BE); // Light skin tone
        break;
      case "medium":
        skinToneColor = Color(0xDDD1A684); // Medium skin tone
        break;
      case "olive":
        skinToneColor = Color(0xAAA67C52); // Olive skin tone
        break;
      case "brown":
        skinToneColor = Color(0x88825C3A); // Brown skin tone
        break;
      case "dark":
        skinToneColor = Color(0x444A312C); // Dark skin tone
        break;
      default:
        skinToneColor =
            const Color.fromARGB(255, 0, 0, 0); // Default fallback color
        break;
    }

    // Filter the products based on the skin tone color
    return recommendedProducts.where((product) {
      // Compare product skin tone with the chosen skin tone
      return product['skintone_name'] == skinTone;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Filter the products according to the skin tone
    List<dynamic> filteredProducts = _filterRecommendedProducts(skinTone);

    return Scaffold(
      appBar: AppBar(
        title: Text('YourSkin-ID'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Skin Identification',
                      style: GoogleFonts.roboto(fontSize: 24)),
                  SizedBox(height: 16),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFFF0D5BE), // Example skin tone color
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkinToneColor(color: Color(0xFFFFDFC4)), // Very Light
                      SkinToneColor(color: Color(0xFFF0D5BE)), // Light
                      SkinToneColor(color: Color(0xFDD1A684)), // Medium
                      SkinToneColor(color: Color(0xFAAAA67C)), // Olive
                      SkinToneColor(color: Color(0xF8825C3A)), // Brown
                      SkinToneColor(color: Color(0xF44A312C)), // Dark
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(skinTone),
                  SizedBox(height: 16),
                  Text(skinDescription, textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  Text('Recommended Makeup',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  filteredProducts.isEmpty
                      ? Center(
                          child: Text('No recommendations available.',
                              style: TextStyle(color: Colors.grey)))
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
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
                              child: Column(
                                children: [
                                  Image.network(
                                    product['image_url'],
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      product['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
