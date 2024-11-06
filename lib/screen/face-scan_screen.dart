// lib/face_scan_page.dart
// ignore_for_file: file_names, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:skin_id/button/bottom_navigation.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class FaceScanPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  FaceScanPage(this.cameras);

  @override
  _FaceScanPageState createState() => _FaceScanPageState();
}

class _FaceScanPageState extends State<FaceScanPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCameraWithPermissionCheck();
  }

  Future<void> _initializeCameraWithPermissionCheck() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      await _initializeCamera();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Camera Permission Required'),
          content: Text('This app requires camera access to function properly.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isNotEmpty) {
      _cameraController = CameraController(
        widget.cameras.length > 1 ? widget.cameras[1] : widget.cameras[0],
        ResolutionPreset.medium,
      );
      await _cameraController?.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face Scan"),
        backgroundColor: Colors.orange[700],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _isCameraInitialized
                ? AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        'Loading Camera...',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Show us your pretty face!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Let our AI find the best makeup shade that suits you!",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
      // Replace the BottomNavigationBar with your custom BottomNavigation widget
      bottomNavigationBar: BottomNavigation(
        currentIndex: 1, // The current tab index for the scan page (adjust if necessary)
        onTap: (index) {
          // Handle tab tap if needed, you can navigate or update the UI
          // For example, if you want to navigate to other pages:
          // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        },
      ),
    );
  }
}
