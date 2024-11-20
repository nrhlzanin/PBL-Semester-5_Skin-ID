// ignore_for_file: unused_import, duplicate_import

import 'dart:typed_data'; // Untuk bekerja dengan Uint8List
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/home.dart';
// import 'dart:html' as html; // Untuk bekerja dengan elemen HTML (Web)
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:skin_id/screen/notification_screen.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  int _currentIndex = 1;
  Uint8List? _imageBytes; // Menyimpan gambar yang diambil dalam bentuk bytes
  String? skinToneResult;

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
    final url = Uri.parse(
        // 'http://192.168.64.224:8000/api/user/predict/'
        'http://192.168.56.217:8000/api/user/predict/'); //Masih kirim ke local
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      http.MultipartFile.fromBytes('image', imageBytes, filename: 'skin.jpg'),
    );
    final response = await http.Response.fromStream(await request.send());
    return response;
  }

  void _showPredictionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Prediction Result'),
        content: skinToneResult == null
            ? CircularProgressIndicator()
            : Text(
                'Detected Skin Tone: $skinToneResult',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      // Navigasi ke halaman yang sesuai berdasarkan index
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CameraPage()),
          );
          break;
        // Tambahkan halaman Profile jika dibutuhkan
        case 2:
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => ProfilePage()),
          // );
          break;
      }
    }
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          ),
        child: Stack(
          children: [
            if (_isCameraInitialized)
              Positioned(
                left: 30,
                top: 80,
                right: 30,
                bottom: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: CameraPreview(_controller!),
                ),
              )
            else
              Center(child: CircularProgressIndicator()),
            Positioned(
              left: 26,
              bottom: 50,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 52,
                height: 60,
                child: Text(
                  'Let our AI find the best makeup that suits you!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.02,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: IconButton(
                icon: Icon(Icons.camera, color: Colors.black, size: 40),
                onPressed: () async {
                  try {
                    await _initializeCamera();
                    final picture = await _controller!.takePicture();
                    print("Picture taken: ${picture.path}");

                    // Membaca file gambar sebagai bytes
                    final byteData = await picture.readAsBytes();
                    setState(() {
                      _imageBytes = byteData; // Menyimpan bytes gambar
                    });
                    await _captureAndPredict();
                    // Menampilkan gambar dalam dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Captured Image'),
                        content: _imageBytes == null
                            ? CircularProgressIndicator()
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.memory(
                                      _imageBytes!), // Menampilkan gambar dari memory
                                  SizedBox(height: 10),
                                  Text(
                                    skinToneResult ?? "No result available",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ), // Menampilkan gambar dari memory
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
                  } catch (e) {
                    print("Error capturing image: $e");
                  }
                },
                padding: EdgeInsets.all(20),
                iconSize: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
