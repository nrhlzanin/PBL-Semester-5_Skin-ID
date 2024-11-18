// lib/bottom_navigation.dart

// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:skin_id/screen/account_screen.dart';
import 'package:skin_id/screen/face-scan_screen.dart';
import 'package:skin_id/screen/home.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return; // Avoids redundant navigation

        // Navigate to the selected page based on index
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
            break;
          case 1:
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) =>
            //           CameraPage()), // Ganti `[]` dengan daftar kamera jika diperlukan
            // );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AccountScreen()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
