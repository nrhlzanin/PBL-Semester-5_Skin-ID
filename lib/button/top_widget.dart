// lib/top_widget.dart

// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:skin_id/screen/notification_screen.dart';

// Contoh daftar tutorial
final List<String> tutorialTitles = [
  "Makeup Basics",
  "Advanced Contouring",
  "Natural Look Makeup",
  // Tambahkan judul tutorial lainnya
];

class TopWidget extends StatelessWidget implements PreferredSizeWidget {
  const TopWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.notifications_none),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationScreen(),
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
