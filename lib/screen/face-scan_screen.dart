import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:skin_id/button/bottom_navigation.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;

  int _currentIndex = 1;

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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.20, -0.98),
            end: Alignment(-0.2, 0.98),
            colors: [Color(0xFFFEE1CC), Color(0xFFD6843C)],
          ),
        ),
        child: Stack(
          children: [
            // Camera preview positioned in the center, stretching down
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

            // "Let our AI find best make up that suits you!" text
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

            // IconButton positioned at the bottom center
            Positioned(
              bottom:
                  20, // Adjust this value to change the distance from the bottom
              left: MediaQuery.of(context).size.width / 2 -
                  30, // Center the button
              child: IconButton(
                icon: Icon(Icons.camera, color: Colors.black, size: 40),
                onPressed: () async {
                  try {
                    XFile picture = await _controller!.takePicture();
                    print("Picture taken: ${picture.path}");
                  } catch (e) {
                    print(e);
                  }
                },
                padding: EdgeInsets.all(20),
                iconSize: 40,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex:
            0, // Set the current index, you can update it based on state
        onTap: (index) {
          // Handle tap actions here
        },
      ),
    );
  }
}
