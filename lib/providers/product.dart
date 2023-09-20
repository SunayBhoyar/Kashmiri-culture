import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'products.dart';
import 'dart:convert';
import '../models/http_exception.dart';

class Product with ChangeNotifier {
  List<ProductModel> _items = [
    ProductModel(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    ProductModel(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    ProductModel(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    ProductModel(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

  var _showFav = false;
  late final String authToken;
  late final String userID;

  Product(this.authToken, this.userID,
      this._items); // A provider can also have a constructor as they r just normal classes

  List<ProductModel> get items {
    // if (_showFav) {
    //   return _items.where((element) => element.isFav).toList();
    // }
    return [..._items];
  }

  List<ProductModel> get favItems {
    return _items.where((element) => element.isFav).toList();
  }

  // void showFavoritesOnly() {
  //   _showFav = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFav = false;
  //   notifyListeners();
  // }

  ProductModel findByID(String ProductID) {
    return (_items.firstWhere((element) => element.id == ProductID));
  }

  int compare(ProductModel a, ProductModel b) {
    return (a.title.compareTo(b.title));
  }

  // Future<void> addProduct(Map<String, String> p) {
  //   final url = Uri.parse(
  //       'https://shopapp-83802-default-rtdb.firebaseio.com/products.json');

  //   return http
  //       .post(
  //     url,
  //     body: json.encode(
  //       {
  //         'id': p["id"],
  //         'title': p["title"],
  //         'description': p["description"],
  //         'imageUrl': p["imageUrl"],
  //         'price': p["price"],
  //         'isFav': p["isFav"],
  //       },
  //     ),
  //   )
  //       .then((response) {
  //     // print('response from server: $response');
  //     var newProduct = ProductModel(
  //       // id: p["id"]!,
  //       id: json.decode(response.body)['name'],
  //       title: p["title"]!,
  //       description: p["description"]!,
  //       price: double.parse(p["price"]!),
  //       imageUrl: p["imageUrl"]!,
  //       isFav: (p["isFav"] == "true") ? true : false,
  //     );
  //     _items.add(newProduct);
  //     _items.sort(compare);
  //     notifyListeners();
  //   }).catchError((error) {
  //     // print(error);
  //     throw error;
  //   });
  // }

  Future<void> fetchData([bool filterByUser = false]) async {
    // On the Products Overview screen, we want to display all products so we don't filter by user, but on the User Products Screen, we want to filter only the user's added products so we must have filtering by user
    // square brackets around a positional argument make it optional but we need to provide a defualt value to it as <ret type> <func name> ([pos arg. = <def. value>])
    final filterString = filterByUser // if we want to filter by user or not
        ? 'orderBy="creatorID"&equalTo="$userID"'
        : ''; // FILTERING IS A SERVER-SIDE TASK
    var url = Uri.parse(
        'https://shopapp-83802-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString'); // getting all products
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData.isEmpty) {
        // print('extracted data is empty!');
        _items = [];
        // notifyListeners();
        return;
      }
      // print('extracted data: ${extractedData.keys}');

      // Here we need to fetch the favourite products
      url = Uri.parse(
          'https://shopapp-83802-default-rtdb.firebaseio.com/userFavorites/$userID.json?auth=$authToken');
      final favResponse = await http.get(url);
      final favData = json.decode(favResponse.body);

      final List<ProductModel> loadedProducts = [];
      extractedData.forEach((key, value) {
        // key is the productID, value is the product description
        loadedProducts.add(
          ProductModel(
            id: key,
            title: value["title"],
            description: value["description"],
            price: double.parse(value["price"]),
            imageUrl: value["imageUrl"],
            isFav: favData == null // if true means the user has no fav data
                ? false
                : (favData[key] ?? false) ==
                        "true" // ?? operator checks if the value before it is null, if it is then it will take the
                    ? true // value given after it, else it will take the non-null value
                    : false,
            authToken: authToken,
          ),
        );
      });
      for (int i = 0; i < loadedProducts.length; i++) {
        //to avoid duplicate entries in the _items
        bool flag = false;
        for (int j = 0; j < _items.length; j++) {
          if (_items[j].id == loadedProducts[i].id) {
            flag = true;
          }
        }
        if (!flag) {
          _items.add(loadedProducts[i]);
        }
      }
      _items.sort(compare);
      print("items are:  $_items");
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> addProduct(Map<String, String> p) async {
    final url = Uri.parse(
        'https://shopapp-83802-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'id': p["id"],
            'title': p["title"],
            'description': p["description"],
            'imageUrl': p["imageUrl"],
            'price': p["price"],
            'creatorID':
                userID, // setting the creator ID as the user who has logged in as he would have only added that product into the global pool of the products in the app
          },
        ),
      );
      // print('response from server: $response');
      var newProduct = ProductModel(
          // id: p["id"]!,
          id: json.decode(response.body)['name'],
          title: p["title"]!,
          description: p["description"]!,
          price: double.parse(p["price"]!),
          imageUrl: p["imageUrl"]!,
          // isFav: (p["isFav"] == "true") ? true : false,
          authToken: authToken);
      _items.add(newProduct);
      _items.sort(compare);
      notifyListeners();
    } catch (error) {
      print("error: $error");
      rethrow;
      // rethrow;
    }
  }

  // void updateProduct(Map<String, String> p, String id) {
  //   final prodIndex = _items.indexWhere((element) => (element.id == id));
  //   if (prodIndex >= 0) {
  //     _items[prodIndex] = ProductModel(
  //       id: id,
  //       title: p["title"]!,
  //       description: p["description"]!,
  //       price: double.parse(p["price"]!),
  //       imageUrl: p["imageUrl"]!,
  //       isFav: (p["isFav"] == "true") ? true : false,
  //     );
  //   }
  //   notifyListeners();
  // }

  Future<void> updateProduct(Map<String, String> p, String id) async {
    final prodIndex = _items.indexWhere((element) => (element.id == id));
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://shopapp-83802-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

      await http.patch(
        url,
        body: json.encode(
          {
            'title': p["title"]!,
            'description': p["description"]!,
            'price': p["price"]!,
            'imageUrl': p["imageUrl"],
            'creatorID': userID,
          },
        ),
      );

      _items[prodIndex] = ProductModel(
          id: id,
          title: p["title"]!,
          description: p["description"]!,
          price: double.parse(p["price"]!),
          imageUrl: p["imageUrl"]!,
          isFav: (p["isFav"] == "true") ? true : false,
          authToken: authToken);
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    //OLD FUNCTION: this will remove the item from the _items list but not from the database
    //and so when we delete the item and then go back to the shop screen the
    //the screen fetches the data from the database and gets the deleted item back
    //into the _items list
    final url = Uri.parse(
      'https://shopapp-83802-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken',
    );

    //OPTIMISTIC UPDATING:
    var deleteIndex = _items.indexWhere((element) => element.id == id);
    ProductModel? deleteItem = _items[deleteIndex];
    _items.removeWhere((element) => (element.id == id));
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(deleteIndex, deleteItem);
      notifyListeners();
      throw HttpException(message: 'Could not delete...');
    }
    deleteItem = null;
    notifyListeners();
  }
}
