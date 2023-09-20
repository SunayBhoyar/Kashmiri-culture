import 'package:flutter/material.dart';
import 'cart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userID;

  Orders(this.authToken, this._orders, this.userID);

  List<OrderItem> get items {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://shopapp-83802-default-rtdb.firebaseio.com/orders/$userID.json?auth=$authToken');
    try {
      final time = DateTime.now();
      final response = await http.post(
        url,
        body: json.encode({
          'id': "N/A",
          'amount': total.toString(),
          'dateTime': time.toIso8601String(),
          'products':
              cartProducts //all the products are maps so we need nested maps
                  .map((e) => {
                        'id': e.id,
                        'title': e.title,
                        'price': e.price,
                        'quantity': e.quantity,
                      })
                  .toList(),
        }),
      );
      // print('posted');
      _orders.insert(
        0,
        OrderItem(
          id: json
              .decode(response.body)['name'], //auto generated ID from Firebase
          amount: total,
          products: cartProducts,
          dateTime: time,
        ),
      );
      notifyListeners();
    } catch (error) {
      // print('error');
      // rethrow;
    }
    // print('done');
  }

  int compare(OrderItem a, OrderItem b) {
    return (a.dateTime.isBefore(b.dateTime)) ? 1 : 0;
  }

  Future<void> fetchOrders() async {
    List<OrderItem> temp = [];
    final url = Uri.parse(
        'https://shopapp-83802-default-rtdb.firebaseio.com/orders/$userID.json?auth=$authToken');

    final response = await http.get(url);
    // print(response.body);
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((key, value) {
      temp.add(
        OrderItem(
          id: value["id"],
          amount: double.parse(value["amount"]),
          dateTime: DateTime.parse(value["dateTime"]),
          products: (value["products"] as List<dynamic>).map((item) {
            return CartItem(
              id: item["id"],
              title: item["title"],
              price: item["price"],
              quantity: item["quantity"],
            );
          }).toList(),
        ),
      );
    });

    _orders = temp;
    _orders.sort(compare);
    notifyListeners();
  }
}
