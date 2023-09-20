import 'package:flutter/material.dart';
import 'package:flutter_application_6/providers/products.dart';
import '../providers/cart.dart';
import 'package:provider/provider.dart';

class cartItem extends StatelessWidget {
  final CartItem obj;
  cartItem({
    required this.obj,
  });

  @override
  Widget build(BuildContext context) {
    final cartObj = Provider.of<Cart>(context, listen: false);
    // final prodModelObj = Provider.of<ProductModel>(context);

    return Dismissible(
      key: ValueKey(obj.id),
      background: Container(
        padding: const EdgeInsets.only(right: 10),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: ((context) {
            return AlertDialog(
              title: const Text('ARE YOU SURE?'),
              content: const Text(
                  'Do you really want to delete this item from the cart?'),
              actions: [
                TextButton(
                  onPressed: () {
                    // The future resolves to a value that was passed to Navigator.of(context).pop(<value>)
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('YES'),
                ),
                TextButton(
                  onPressed: () {
                    // The future resolves to a value that was passed to Navigator.of(context).pop(<value>)
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('NO'),
                ),
              ],
            );
          }),
        );
      },
      onDismissed: (direction) {
        cartObj.removeFromCart(obj.id);
        // prodModelObj.resetCount();
        // Provider.of<ProductModel>(context, listen: false).resetCount();
        // cartListObj.resetCount();
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: FittedBox(
                  child: Text(
                    "₹${obj.price.toStringAsFixed(0)}",
                  ),
                ),
              ),
            ),
            title: Text(obj.title),
            subtitle: Text("₹${(obj.price * obj.quantity).toStringAsFixed(0)}"),
            trailing: Text("x ${obj.quantity.toStringAsFixed(0)}"),
          ),
        ),
      ),
    );
  }
}
