// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, unnecessary_string_interpolations, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/notification_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String username = "Loading...";
  String displayName = "Loading...";
  String email = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please log in.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_ACCOUNT_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url, headers: {
        'Authorization': '$token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username = data['username'] ?? "Unknown";
          displayName = username;
          email = data['email'] ?? "Unknown";
        });
      } else {
        throw Exception('Failed to fetch user profile.');
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user profile.')),
        );
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
      body: Column(
        children: [
          SizedBox(height: 20),
          ListTile(
            leading: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://www.example.com/profile-pic.jpg'), // URL gambar profil
            ),
            title: Text(displayName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            subtitle: Text('@$username', style: TextStyle(fontSize: 18)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('162', style: TextStyle(fontSize: 18)),
                    Text('Following', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Text('734', style: TextStyle(fontSize: 18)),
                    Text('Followers', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Text('34', style: TextStyle(fontSize: 18)),
                    Text('Posts', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfileScreen()),
                  ).then((value) {
                    if (value == true) {
                      _loadUserData();
                    }
                  });
                },
                child: Text('Edit Profile'),
              ),
              OutlinedButton(
                onPressed: () {},
                child: Text('Share Profile'),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('Upload Content'),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.grey[300],
                  child: Center(child: Text('Beautiful sunset')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please log in.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_EDIT_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url, headers: {
        'Authorization': '$token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _usernameController.text = data['username'] ?? 'Unknown';
          _emailController.text = data['email'] ?? 'unknown@example.com';
        });
      } else {
        throw Exception('Failed to load user data.');
      }
    } catch (e) {
      print("Error loading profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile.')),
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
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image.')),
      );
    }
  }

  Future<void> _saveChanges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please log in.');
      }

      if (_usernameController.text.isNotEmpty) {
        await prefs.setString('username', _usernameController.text);
      }

      if (_emailController.text.isNotEmpty) {
        await prefs.setString('email', _emailController.text);
      }

      await _updateProfileOnServer(
        _usernameController.text.isNotEmpty ? _usernameController.text : null,
        _emailController.text.isNotEmpty ? _emailController.text : null,
        _passwordController.text.isNotEmpty ? _passwordController.text : null,
        _selectedImage,
      );

      Navigator.pop(context, true);
    } catch (e) {
      print('Error saving changes: $e');
    }
  }

  Future<void> _updateProfileOnServer(
    String? username,
    String? email,
    String? password,
    File? profileImage,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please log in.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      if (baseUrl == null) {
        throw Exception('Base URL is not set.');
      }

      final url = Uri.parse('$baseUrl/api/user/profile/');
      var request = http.MultipartRequest('PUT', url)
        ..headers['Authorization'] = 'Bearer $token';

      if (username != null) request.fields['username'] = username;
      if (email != null) request.fields['email'] = email;
      if (password != null) request.fields['password'] = password;

      if (profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          profileImage.path,
        ));
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        print("Profile updated successfully.");
      } else {
        throw Exception('Failed to update profile.');
      }
    } catch (e) {
      print("Error updating profile on server: $e");
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
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : AssetImage('assets/default_profile.jpg') as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
