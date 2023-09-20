import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';
import '../widgets/order_item.dart' as or;
import '../widgets/app_drawer.dart';

//We could also use a FutureBuilder instead of using initState() and stateful widget:
//This will prevent re-building the whole UI every time we fetch data

/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    print('building orders');
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              // ...
              // Do error handling stuff
              return Center(
                child: Text('An error occurred!'),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => ListView.builder(
                      itemCount: orderData.orders.length,
                      itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                    ),
              );
            }
          }
        },
      ),
    );
  }
}

*/

class OrderScreen extends StatefulWidget {
  static const routeName = '/order-screen';

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  var _isInit = true;
  var _isLoading = false;

/*  METHOD 1
  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) =>
        Provider.of<Orders>(context, listen: false)
            .fetchOrders()
            .then((value) => setState(() {
                  _isLoading = false;
                })));
    super.initState();
  }*/

  // METHOD 2
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Orders>(context, listen: false).fetchOrders().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ordersObj = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,

        title: const Text(
          'YOUR ORDERS',
        ),
      ),
      drawer: MyDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ordersObj.items.isEmpty
              ? const Align(
                  alignment: Alignment.center,
                  child: Card(
                    elevation: 10,
                    child: Text(
                      "NO ORDERS",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 40,
                      ),
                    ),
                  ),
                )
              : _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemBuilder: ((context, index) {
                        return or.OrderItem(
                          order: ordersObj.items[index],
                        );
                      }),
                      itemCount: ordersObj.items.length,
                    ),
    );
  }
}
