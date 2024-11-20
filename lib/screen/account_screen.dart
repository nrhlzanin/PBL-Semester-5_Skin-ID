// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skin_id/button/bottom_navigation.dart';
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/notification_screen.dart';

class AccountScreen extends StatelessWidget {
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
      body: Column(
        children: [
          SizedBox(height: 20),
          ListTile(
            leading: CircleAvatar(
              radius: 50, // Meningkatkan ukuran avatar
              backgroundImage: NetworkImage('https://www.example.com/profile-pic.jpg'), // URL profil gambar
            ),
            title: Text('John Doe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            subtitle: Text('@johndoe', style: TextStyle(fontSize: 18)),
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
                  );
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
      bottomNavigationBar: BottomNavigation(
        currentIndex: 2, // Sesuaikan dengan halaman aktif
        onTap: (index) {
          // Implementasi navigasi ke halaman lain jika diperlukan
        },
      ),
    );
  }
}

// Halaman untuk mengedit profil
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
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  backgroundColor: Color(0xFFD6843C), // Button color
                ),
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
