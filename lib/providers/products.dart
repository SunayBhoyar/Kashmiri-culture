import 'package:flutter/material.dart';
import '../models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductModel with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFav;
  int countInCart;
  String authToken;
  String userId;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.authToken = '',
    this.userId = '',
    this.isFav = false,
    this.countInCart = 0,
  });

  Future<void> toggleFavorite(String? userID) async {
    isFav = !isFav;
    notifyListeners(); //optimistic updating
    final url = Uri.parse(
        'https://shopapp-83802-default-rtdb.firebaseio.com/userFavorites/$userID/$id.json?auth=$authToken'); // userID is the ID for each user, id is the product ID
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFav.toString(),
        ),
      );

      if (response.statusCode >= 400) {
        throw HttpException(message: 'Deletion');
      }
    } catch (error) {
      isFav = !isFav;
      notifyListeners();
      rethrow;
    }
  }

  void incrementCountInCart() {
    countInCart++;
    notifyListeners();
  }

  void resetCount() {
    countInCart = 0;
    // print("Reseting the count to zero");
    notifyListeners();
  }
}
