import 'package:flutter/material.dart';
import 'package:skin_id/screen/account_screen.dart';
import 'package:skin_id/screen/notification_screen.dart';

class Navbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.33, // Sepertiga layar
      color: Color(0xFF2E2E2E), // Warna hitam keabuan
      child: Column(
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Skin_id',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.white),
            title: Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Aksi ketika item Home ditekan
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
            title: Text('Rekomendasi', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Aksi ketika item Rekomendasi ditekan
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.white),
            title: Text('Notifikasi', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.white),
            title: Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Aksi ketika item Logout ditekan
            },
          ),
        ],
      ),
    );
  }
}
