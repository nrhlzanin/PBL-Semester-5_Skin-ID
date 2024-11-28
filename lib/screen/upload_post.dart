import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UploadPost extends StatefulWidget {
  const UploadPost({super.key});

  @override
  State<UploadPost> createState() => _UploadPostState();
}

class _UploadPostState extends State<UploadPost> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();
  String? _imagePath; // Untuk menyimpan path gambar yang dipilih

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image.')),
      );
      return;
    }

    try {
      const String apiUrl =
          'http://127.0.0.1:8000/api/upload-post/'; // Ganti URL dengan URL backend Anda
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..fields['caption'] = _captionController.text
        ..fields['hashtag'] = _hashtagController.text
        ..files.add(await http.MultipartFile.fromPath('image', _imagePath!));

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload successful!')),
        );
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Upload failed. Code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _imagePath = null;
      _captionController.clear();
      _hashtagController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Post'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(15),
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text('@Kangaroo0+',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: _pickImage,
                  child: _imagePath == null
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: 350,
                          color: Colors.grey[300],
                          child: Icon(Icons.add_photo_alternate,
                              size: 50, color: Colors.grey),
                        )
                      : Image.file(
                          File(_imagePath!),
                          width: MediaQuery.of(context).size.width,
                          height: 350,
                          fit: BoxFit.cover,
                        ),
                ),
                SizedBox(height: 10),
                Text('Add Caption',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _captionController,
                  maxLines: 5,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Enter your review',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                Text('Add Hashtag #',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _hashtagController,
                  maxLines: 5,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Add your own hashtag',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Color(0xFFE6E6E6),
                  child: Text('#Style', style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _resetForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text('Cancel',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _uploadPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: Text('Upload',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
