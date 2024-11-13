// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:skin_id/button/bottom_navigation.dart';

class AccountScreen extends StatelessWidget {
  // Simulasi data pengguna, ini bisa diganti dengan data yang didapat dari API
  final String name = 'John Doe';
  final String email = 'johndoe@example.com';
  final String joinDate = 'January 1, 2020';
  final String profilePicUrl =
      'https://www.example.com/profile-pic.jpg'; // Ganti dengan URL foto profil Anda

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Account',
            style: TextStyle(
                fontSize: 30,
                fontWeight:
                    FontWeight.bold), // Anda bisa menyesuaikan ukuran font
          ),
        ),
        backgroundColor: Color(0xFFD6843C), // Customize the app bar color
        automaticallyImplyLeading: false, // Menghapus ikon back
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.20, -0.98),
            end: Alignment(-0.2, 0.98),
            colors: [Color(0xFFFEE1CC), Color(0xFFD6843C), Color(0xFFFEE1CC)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              top: 24.0, left: 16.0, right: 16.0), // Added top padding
          child: SingleChildScrollView(
            // To make sure content scrolls if there's overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Menampilkan foto profil
                Center(
                  child: CircleAvatar(
                    radius: 50, // Ukuran avatar
                    backgroundImage:
                        NetworkImage(profilePicUrl), // Gambar profil dari URL
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Welcome, $name',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center, // Teks di tengah
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Email: $email',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center, // Teks di tengah
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Joined on: $joinDate',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center, // Teks di tengah
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigasi ke halaman EditProfile
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfileScreen()),
                    );
                  },
                  child: Text('Edit Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 2, // Sesuaikan dengan halaman aktif
        onTap: (index) {
          // Implementasi navigasi ke halaman lain jika diperlukan
        },
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _profilePicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mengisi controller dengan data awal (misalnya dari API)
    _nameController.text = 'John Doe';
    _emailController.text = 'johndoe@example.com';
    _profilePicController.text = 'https://www.example.com/profile-pic.jpg';
  }

  void _saveChanges() {
    // Simulasi proses penyimpanan perubahan
    final name = _nameController.text;
    final email = _emailController.text;
    final profilePicUrl = _profilePicController.text;

    // Misalnya, Anda bisa melakukan validasi dan mengirim data ke server atau API

    print('Name: $name');
    print('Email: $email');
    print('Profile Pic URL: $profilePicUrl');

    // Navigasi kembali ke AccountScreen setelah menyimpan perubahan
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Color(0xFFD6843C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Form untuk mengedit profil
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _profilePicController,
                decoration: InputDecoration(
                  labelText: 'Profile Picture URL',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  backgroundColor: Color(0xFFD6843C), // Button color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
