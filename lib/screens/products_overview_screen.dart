import 'package:flutter/material.dart';
import '../screens/cart_screen.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
// import '../providers/products.dart';
import '../providers/cart.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart' as bd;

enum FilterOptions { All, Favorites }

class ProductsOverview extends StatefulWidget {
  @override
  State<ProductsOverview> createState() => _ProductsOverviewState();
}

class _ProductsOverviewState extends State<ProductsOverview> {
  bool _isFavOn = false;
  var _isInit = true;
  var isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        isLoading = true;
      });
      final data = Provider.of<Product>(context).fetchData().then((_) {
        setState(() {
          isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final ProductList = Provider.of<Product>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          "PRODUCTS OVERVIEW",
        ),
        actions: [
          PopupMenuButton(
            onSelected: (selectedItem) {
              setState(() {
                if (selectedItem == FilterOptions.All) {
                  // ProductList.showFavoritesOnly();
                  _isFavOn = false;
                } else if (selectedItem == FilterOptions.Favorites) {
                  // ProductList.showAll();
                  _isFavOn = true;
                }
              });
            },
            itemBuilder: ((context) => [
                  const PopupMenuItem(
                    // value: FilterOptions.All,
                    value: FilterOptions.All,
                    child: Text("Show All"),
                  ),
                  const PopupMenuItem(
                    // value: FilterOptions.Favorites,
                    value: FilterOptions.Favorites,
                    child: Text("Show Favorites"),
                  ),
                ]),
          ),
          Consumer<Cart>(
            builder: (_, cartData, ch) => bd.Badge(
              value: cartData.itemCount.toString(),
              color: Colors.red,
              child: ch!,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(isFavoriteOn: _isFavOn),
    );
  }
}
