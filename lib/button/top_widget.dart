// lib/top_widget.dart

// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';

class TopWidget extends StatelessWidget implements PreferredSizeWidget {
  const TopWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Home Page (before login)"),
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
            // Fungsi untuk notifikasi
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
