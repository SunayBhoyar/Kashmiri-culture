import 'package:flutter/material.dart';
import '../screens/product_details_screen.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final ProductModel obj;
  // const ProductItem({required this.obj});

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<ProductModel>(context);
    final cartproduct = Provider.of<Cart>(context, listen: false);
    final authToken = Provider.of<Auth>(context, listen: false);

    // print("REBUILDING WHOLE WIDGET TREE");
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          leading: Consumer<ProductModel>(
            builder: (context, value, child) {
              // print("BUILDING ONLY ${product.title.toUpperCase()}");
              return IconButton(
                color: product.isFav ? Colors.red : Colors.black,
                icon: product.isFav
                    ? const Icon(Icons.favorite)
                    : const Icon(Icons.favorite_border),
                onPressed: (() async {
                  final sc = ScaffoldMessenger.of(context);
                  try {
                    await product.toggleFavorite(authToken.userID);
                  } catch (error) {
                    sc.showSnackBar(const SnackBar(
                      content: Text('Could not Add to Favorites...'),
                      duration: Duration(milliseconds: 500),
                    ));
                  }
                }),
              );
            },
            // child: Text("NEVER CHANGES!!"),
          ),
          subtitle: Text(
            product.title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: Consumer<ProductModel>(
              builder: (context, value, child) {
                // print("BUILDER CALLED, itemcount: ${product.countInCart}");
                return IconButton(
                  icon: product.countInCart > 0
                      ? (product.countInCart == 1
                          ? const Icon(
                              Icons.shopping_cart,
                              color: Colors.yellow,
                            )
                          : const Icon(
                              Icons.shopping_cart,
                              color: Colors.yellow,
                            ))
                      : const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.black,
                        ),
                  onPressed: () {
                    final sc = ScaffoldMessenger.of(
                        context); //establish a connection to the nearest scaffold
                    sc.hideCurrentSnackBar();
                    sc.showSnackBar(
                      SnackBar(
                        action: SnackBarAction(
                          label: "Undo",
                          onPressed: (() {
                            cartproduct.undoItem(product.id);
                          }),
                        ),
                        duration: const Duration(
                          milliseconds: 2000,
                        ),
                        content: Text(
                          " x ${product.countInCart}",
                        ),
                      ),
                    );
                    cartproduct.addItem(
                      product.id,
                      product.title,
                      product.price,
                    );
                    product.incrementCountInCart();
                  },
                );
              },
              child: null),
        ),
        child: Card(
          child: GestureDetector(
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                  placeholder:
                      AssetImage('assets/images/product-placeholder.png'),
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover),
            ),
            onTap: (() {
              Navigator.of(context).pushNamed(
                ProductDetailsScreen.routeName,
                arguments: product.id,
              );
            }),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.grey,
          elevation: 20,
        ),
      ),
    );
  }
}
