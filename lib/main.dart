import 'package:flutter/material.dart';
import 'package:flutter_application_6/providers/products.dart';
import '../providers/orders.dart';
import './screens/orders_screen.dart';
import 'package:provider/provider.dart';
import '../screens/products_overview_screen.dart';
import './screens/product_details_screen.dart';
import './providers/product.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';
import './screens/user_products_screen.dart';
import './screens/added_product_screen.dart';
import './screens/auth_screen.dart';
import './providers/auth.dart';
import './screens/splash_screen.dart';
import './helpers/custom_route.dart';

void main() {
  runApp(const myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  Widget func() {
    print("in product");
    return ProductsOverview();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        // ChangeNotifierProvider(
        //   //use this 'create' method instead of the ChangeNotifierProvider.value constructor for more efficiency
        //   create: (context) => Product(),
        //   // value: Product(),
        // ),
        ChangeNotifierProxyProvider<Auth, Product>(
          // to get the token from auth.dart file into the product() class constructor every time the authToken changes
          update: (ctx, auth, prevState) => Product(
            auth.token == null ? '' : auth.token!,
            auth.userID == null ? '' : auth.userID!,
            prevState == null
                ? []
                : prevState
                    .items, // initially when prevState will be null we need to set _items to an empty list
          ),
          create: (ctx) => Product('', '', []),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, authObj, prevState) => Orders(
            authObj.token == null ? '' : authObj.token!,
            prevState == null ? [] : prevState.items,
            authObj.userID == null ? '' : authObj.userID!,
          ),
          create: (context) => Orders('', [], ''),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductModel(
              id: '_', title: '_', description: '_', price: 0.0, imageUrl: '_'),
        ),
        // ChangeNotifierProvider(
        //   create: ((context) => ProductModel(
        //       id: "_", title: '_', description: "_", price: 1, imageUrl: "_")),
        // ),
      ],
      child: Consumer<Auth>(
        builder: (context, authObj, _) => MaterialApp(
          // theme: PageTransitionsTheme(builders: {
          //   TargetPlatform.android : CustomPageTransitionsBuilder,
          //   TargetPlatform.iOS : ,
          // }),
          home: authObj
                  .isAuth // To show Product Overview screen if we are authenticated, else show some other screens
              ? ProductsOverview()
              : FutureBuilder(
                  future: authObj
                      .tryAutoLogin(), // tryAutoLogin returns a future whose state will decide what screen is to be displayed
                  builder: (context, snapshot) => (snapshot.connectionState ==
                          ConnectionState.waiting)
                      ? const SplashScreen() // show a loading spinner until we get a response from the API about the authentication succeding or failing
                      : snapshot.data == null
                          ? AuthScreen()
                          : snapshot.data!
                              ? ProductsOverview()
                              : AuthScreen(),
                ),
          routes: {
            ProductDetailsScreen.routeName: (context) => ProductDetailsScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrderScreen.routeName: (context) => OrderScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            AddedProduct.routeName: (context) => AddedProduct(),
            AuthScreen.routeName: (context) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
