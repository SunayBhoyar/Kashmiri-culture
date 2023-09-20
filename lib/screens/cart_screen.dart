import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../widgets/cartItem.dart';
import '../providers/orders.dart';

class CartScreen extends StatefulWidget {
  static const routeName = "/cart-screen";

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var isLoading = false;
  @override
  Widget build(BuildContext context) {
    final cartItemObj = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,

        title: const Text('YOUR CART'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    backgroundColor: Colors.purple,
                    label: Text(
                      '₹${cartItemObj.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: (cartItemObj.itemCount <= 0 || isLoading)
                        ? null
                        : () async {
                            final sc = ScaffoldMessenger.of(context);
                            try {
                              setState(() {
                                isLoading = true;
                              });
                              await Provider.of<Orders>(context, listen: false)
                                  .addOrder(
                                cartItemObj.items.values.toList(),
                                cartItemObj.totalAmount,
                              )
                                  .then((_) {
                                sc.hideCurrentSnackBar();
                                sc.showSnackBar(const SnackBar(
                                  content: Text(
                                    'Order Placed!',
                                    textAlign: TextAlign.center,
                                  ),
                                ));
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            } catch (error) {
                              sc.hideCurrentSnackBar();
                              sc.showSnackBar(
                                const SnackBar(
                                  content: Text('Order could not be placed...'),
                                  duration: Duration(milliseconds: 500),
                                ),
                              );
                            }
                            cartItemObj.clear();
                          },
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            "ORDER NOW",
                            style: TextStyle(color: Colors.purple),
                          ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: cartItemObj.itemCount.toInt(),
            itemBuilder: (context, index) => cartItem(
              obj: cartItemObj.items.values.toList()[index],
            ),
          ))
        ],
      ),
    );
  }
}
