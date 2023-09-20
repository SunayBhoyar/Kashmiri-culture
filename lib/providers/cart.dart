import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items =
      {}; /*{
    "1": CartItem(
        id: DateTime.now().toString(),
        title: 'Phone',
        price: 2000,
        quantity: 1),
    "2": CartItem(
        id: DateTime.now().toString(), title: 'Phone', price: 2000, quantity: 1)
  }*/

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var amt = 0.0;
    _items.forEach((key, value) {
      amt += (value.price * value.quantity);
    });
    return amt;
  }

  void addItem(String id, String title, double price) {
    if (_items.containsKey(id)) {
      _items.update(
        id,
        (existingValue) => CartItem(
            id: id,
            title: title,
            price: price,
            quantity: existingValue.quantity + 1),
      );
    } else {
      _items.putIfAbsent(
        id,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    _items.removeWhere((key, value) {
      return value.id == id;
    });
    notifyListeners();
  }

  void undoItem(String id) {
    if (!_items.containsKey(id)) {
      return;
    } else if (_items[id]!.quantity > 1) {
      _items.update(
        id,
        (value) => CartItem(
          id: value.id,
          title: value.title,
          price: value.price,
          quantity: value.quantity - 1,
        ),
      );
    } else {
      _items.removeWhere((key, value) => key == id);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
