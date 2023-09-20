import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../widgets/user_products_item.dart';
import './added_product_screen.dart';

// SCREEN TO SHOW WHICH PRODUCTS THE USER HAS ENTERED INTO THE GLOBAL POOL OF ALL THE PRODUCTS AVAILABLE IN THE APP

class UserProductsScreen extends StatefulWidget {
  static const routeName = '/user-products-screen';

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  var _isInit = true;
  var isLoading = false;
  var isempty = true;

  Future<void> _getProducts() async {
    // print('fetching data');
    await Provider.of<Product>(context, listen: false).fetchData(
        true); // setting filterbyUsers as true as this is the user products screen
    // print('done');
  }

  @override
  void didChangeDependencies() {    // to avoid using this we can also even use a FutureBuilder with future as 'Provider.of<Product>(context, listen: false).fetchData(true)'
    // TODO: implement didChangeDependencies
    if (_isInit) {
      setState(() {
        isLoading = true;
      });
      // print('isInit');
      _getProducts().then((value) {
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
    final itemObj = Provider.of<Product>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        
        title: const Text(
          'YOUR PRODUCTS',
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AddedProduct.routeName);
            },
            icon: const Icon(
              Icons.add,
            ),
          )
        ],
      ),
      drawer: const MyDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            await Provider.of<Product>(context, listen: false).fetchData(true);
            // print(
            // "FETCHED DATA AFTER REFRESH: ${Provider.of<Product>(context, listen: false).items}");
            setState(() {});
          } catch (error) {
            print(error);
          }
        },
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : itemObj.items.isEmpty
                ? const Center(
                    child: Text(
                      'YOU HAVE NO PRODUCTS',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: itemObj.items.length,
                      itemBuilder: (context, index) {
                        print(itemObj.items);
                        return Column(
                          children: [
                            UserProductItem(
                              id: itemObj.items[index].id,
                              title: itemObj.items[index].title,
                              imgUrl: itemObj.items[index].imageUrl,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
