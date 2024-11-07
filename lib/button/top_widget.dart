// lib/top_widget.dart

// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:skin_id/screen/notification_screen.dart'; // Impor halaman NotificationScreen

class TopWidget extends StatelessWidget implements PreferredSizeWidget {
  const TopWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Home"),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            // Fungsi untuk search bar
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications_none),
          onPressed: () {
            // Navigasi ke halaman notifikasi
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NotificationScreen(), // Arahkan ke halaman NotificationScreen
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
