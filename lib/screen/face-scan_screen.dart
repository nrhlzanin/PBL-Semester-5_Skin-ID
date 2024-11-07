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
            colors: [Color(0xFFFEE1CC), Color(0xFFD6843C), Color(0xFFFEE1CC)],
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
              bottom: 130,
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

            // Button row container
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFFD6843C), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Center(
                        child: IconButton(
                          icon: Icon(Icons.camera, color: Colors.black),
                          onPressed: () async {
                            try {
                              XFile picture = await _controller!.takePicture();
                              // Save or process the captured image here
                              print("Picture taken: ${picture.path}");
                            } catch (e) {
                              print(e);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
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
