import 'package:flutter/material.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/notification_screen.dart';
import 'package:skin_id/screen/account_screen.dart';
import 'package:skin_id/screen/skin_identification.dart';

class Navbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double navbarWidth = screenWidth * 0.60; // One-third of screen width

    return Container(
      width: navbarWidth,
      color: Color(0xFF2E2E2E), // Dark gray color
      child: Column(
        children: <Widget>[
          // Profile Photo and Username
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                // Profile Photo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(
                    radius: 30, // Avatar size
                    backgroundImage: AssetImage(
                        'assets/image/avatar1.jpeg'), // Profile photo
                  ),
                ),
                // Username
                Expanded(
                  child: Text(
                    'Aku_cantiks', // Username
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14, // Font size
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis, // Truncate if too long
                    ),
                    softWrap: false, // Prevent wrapping to the next line
                    maxLines: 1, // Limit to 1 line
                  ),
                ),
              ],
            ),
          ),
          // Menu List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.home, color: Colors.white),
                  title: Text('Home', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_circle, color: Colors.white),
                  title: Text('Akun', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AccountScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.recommend, color: Colors.white),
                  title: Text('Rekomendasi',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SkinIdentificationPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.notifications, color: Colors.white),
                  title:
                      Text('Notifikasi', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.white),
                  title: Text('Logout', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Action when Logout item is tapped
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}