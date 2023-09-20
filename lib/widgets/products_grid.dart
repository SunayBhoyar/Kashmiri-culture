import 'package:flutter/material.dart';
import '../widgets/product_item.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';

class ProductsGrid extends StatelessWidget {
  final bool isFavoriteOn;
  ProductsGrid({required this.isFavoriteOn});

  @override
  Widget build(BuildContext context) {
    final productObj = Provider.of<Product>(context);
    final p = isFavoriteOn ? productObj.favItems : productObj.items;

    return 
    p.isEmpty ? 
    Center(child: Container(child: Text('NO PRODUCTS'),))
    :GridView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: p.length,
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        // create: (c) => p[index],
        value: p[
            index], //use this instead of create if we do not need the context i.e. if our state does not depend on it
        child: ProductItem(
            // obj: p[index],
            ),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
    );
  }
}
