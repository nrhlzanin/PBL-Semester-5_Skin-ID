import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skin_id/button/navbar.dart';
import 'package:skin_id/screen/home.dart';

class Recomendation2 extends StatefulWidget {
  final String? skinToneResult;
  final String? skinDescription;

  Recomendation2({this.skinToneResult, this.skinDescription});

  @override
  _RecommendationState2 createState() => _RecommendationState2();
}

class _RecommendationState2 extends State<Recomendation2> {
  String? skinToneResult;
  String? skinDescription;
  List<dynamic>? recommendedProducts;
  bool isLoading = true;
  String product_name = '';
  String brand = '';
  String product_type = '';
  String product_description = '';
  String image_url = '';
  String hex_color = '';
  String colour_name = '';

  @override
  void initState() {
    super.initState();
    skinToneResult = widget.skinToneResult;
    skinDescription = widget.skinDescription;
    _getRecommendations();
  }

  Future<void> _getRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('User is not logged in or token is missing.');
    }
    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final endpoint = dotenv.env['GET_RECOMMENDATION_ENDPOINT'];
      final url = Uri.parse('$baseUrl$endpoint');
      final response =
          await http.get(url, headers: {'Authorization': '$token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // image_url = data['image_url'] ?? "No image";
          // product_name = data['product_name'] ?? "Unknown";
          // brand = data['brand'] ?? "Unknown brand";
          // colour_name = data['colour_name'] ?? "";
          recommendedProducts = data['recommendations'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          recommendedProducts = [];
        });
        throw Exception('Failed to fetch recommendations');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        recommendedProducts = [];
      });
      print("Error getting recommendations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Recommendations'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : recommendedProducts!.isEmpty
              ? Center(child: Text('No recommendations available.'))
              : ListView.builder(
                  itemCount: recommendedProducts!.length,
                  itemBuilder: (context, index) {
                    final product = recommendedProducts![index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: Image.network(
                          product['image_url'] ?? '',
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image),
                        ),
                        title:
                            Text(product['product_name'] ?? 'Unknown Product'),
                        subtitle: Text(
                            '${product['brand'] ?? 'Unknown Brand'} - ${product['product_type'] ?? 'Unknown Type'}'),
                        trailing: Text(product['colour_name'] ?? ''),
                      ),
                    );
                  },
                ),
    );
  }
}
