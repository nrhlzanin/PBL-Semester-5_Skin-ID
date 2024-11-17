import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          // Foto Profil dan Nama Pengguna

          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                // Foto Profil
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(
                    radius: 30, // Ukuran avatar
                    backgroundImage: AssetImage(
                        'assets/image/avatar1.jpeg'), // Ganti dengan foto profil dari sumber Anda
                  ),
                ),

                // Nama Pengguna
                Expanded(
                  child: Text(
                    'Aku_cantiks', // Ganti dengan nama pengguna
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14, // Ukuran font yang lebih pas
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow
                          .ellipsis, // Jika nama terlalu panjang, akan dipotong
                    ),
                    softWrap:
                        false, // Nama tidak akan dibungkus ke baris berikutnya
                    maxLines: 1, // Membatasi hanya 1 baris untuk nama pengguna
                  ),
                ),
              ],
            ),
          ),
          // Drawer Header (judul sidebar)

          // Daftar menu
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
