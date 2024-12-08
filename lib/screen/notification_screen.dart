// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_id/screen/home.dart';
import 'package:skin_id/screen/home_screen.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Fungsi untuk memeriksa status pembaruan skintone dan menentukan halaman tujuan
  Future<int?> _getSkintoneId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please log in.');
      }

      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_PROFILE_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.get(url, headers: {'Authorization': token});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Response Data: $data");  // Log data untuk memeriksa struktur data
        
        // Mengakses skintone_id yang ada dalam objek skintone dan memastikan ia merupakan tipe int
        final skintoneId = data['skintone']?['skintone_id'] ?? null;

        print("Skintone ID: $skintoneId");  // Log untuk memeriksa nilai skintone_id

        return skintoneId is int ? skintoneId : null;  // Mengembalikan skintone_id jika tipe int
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else {
        print("Error: Failed to fetch skintone data. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching skintone: $e");
      return null;
    }
  }

  // Fungsi untuk menangani aksi ketika kembali ditekan
  Future<bool> _onWillPop() async {
    int? skintoneId = await _getSkintoneId();

    // Menentukan halaman berdasarkan skintone_id
    if (skintoneId != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Home()),  // Halaman Home jika skintone_id ada
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),  // Halaman HomeScreen jika skintone_id tidak ada
        (Route<dynamic> route) => false,
      );
    }
    return false;  // Menghentikan aksi kembali default
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,  // Menangani aksi tombol back
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              int? skintoneId = await _getSkintoneId();
              // Tentukan halaman tujuan berdasarkan skintone_id
              if (skintoneId != null) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),  // Jika skintone_id ada
                  (Route<dynamic> route) => false,
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),  // Jika skintone_id tidak ada
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Notification',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: Center(
          child: Text("Konten Layar Notifikasi Di Sini"),
        ),
      ),
    );
  }
}
