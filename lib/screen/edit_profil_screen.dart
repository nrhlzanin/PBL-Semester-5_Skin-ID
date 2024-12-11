// ignore_for_file: use_build_context_synchronously, avoid_print, unnecessary_string_interpolations

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String profilePictureUrl = '';
  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _selectedGender;
  List<String> genderOptions = ['Pria', 'Wanita', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Tidak ada token yang ditemukan. Silakan masuk lagi.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_PROFILE_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url, headers: {
        'Authorization': '$token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _usernameController.text = data['username'] ?? 'Tidak diketahui';
          _emailController.text = data['email'] ?? 'unknown@example.com';
          _selectedGender = data['jenis_kelamin'] ?? 'Lainnya';
          profilePictureUrl = data['profile_picture'] ?? '';
        });
      } else {
        throw Exception('Gagal memuat data pengguna.');
      }
    } catch (e) {
      print("Terjadi kesalahan saat mengambil profil: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat memuat profil.')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Kesalahan saat memilih gambar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat memilih gambar.')),
      );
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Tidak ada token yang ditemukan. Silakan masuk lagi.');
      }
      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['EDIT_PROFILE_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');

      var request = http.MultipartRequest('PUT', url)
        ..headers['Authorization'] = '$token';

      request.fields['username'] = _usernameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['jenis_kelamin'] = _selectedGender ?? 'Lainnya';

      if (_oldPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty) {
        request.fields['old_password'] = _oldPasswordController.text;
        request.fields['new_password'] = _newPasswordController.text;
      }
      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          _selectedImage!.path,
        ));
        print("Pilih jalur gambar: ${_selectedImage!.path}");
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final updatedData = json.decode(responseBody);
        setState(() {
          profilePictureUrl = updatedData['data']['profile_picture'] ?? '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil berhasil diperbarui.')),
        );
        Navigator.pop(context, true);
      } else {
        final errorData = json.decode(responseBody);
        throw Exception(errorData['Terjadi Kesalahan'] ?? 'Gagal memperbarui profil.');
      }
    } catch (e) {
      print("Terjadi kesalahan saat menyimpan perubahan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat menyimpan perubahan.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (profilePictureUrl.isNotEmpty
                          ? NetworkImage(profilePictureUrl)
                          : AssetImage('assets/image/default_profile.jpg')
                              as ImageProvider),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Nama Pengguna'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: genderOptions.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Jenis Kelamin'),
              ),
              TextField(
                controller: _oldPasswordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Kata sandi lama',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              TextField(
                controller: _newPasswordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Kata sandi baru',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}