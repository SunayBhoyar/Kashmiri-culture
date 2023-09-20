import 'package:flutter/material.dart';
import '../screens/user_products_screen.dart';
import '../screens/orders_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../helpers/custom_route.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
        backgroundColor: Colors.purple,

            title: const Text(
              'Hello!',
            ),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('SHOP'),
            onTap: () {
              Navigator.of(context).pushNamed('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text("ORDERS"),
            onTap: () {
              Navigator.of(context).pushReplacement(CustomPageRoute(
                builder: ((context) {
                  return OrderScreen();
                }),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('ADD ITEM'),
            onTap: (() {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            }),
          ),
          const Divider(),
          TextButton(
            child: const Text('LOGOUT',
            style: TextStyle(color: Colors.purple),
            ),
            onPressed: () {
              Navigator.of(context)
                  .pop(); // to close thr drawer before logging out
              Navigator.pushReplacementNamed(context, '/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          )
        ],
      ),
    );
  }
}
