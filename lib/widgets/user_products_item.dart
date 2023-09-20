import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_6/providers/product.dart';
import '../screens/added_product_screen.dart';
import '../providers/product.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String imgUrl;
  final String id;

  const UserProductItem({
    required this.id,
    required this.title,
    required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    final sc = ScaffoldMessenger.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Container(
        height: 70,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(imgUrl),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(title),
              const Spacer(),
              IconButton(
                onPressed: () {
                  print("ID: $id");
                  Navigator.of(context)
                      .pushNamed(AddedProduct.routeName, arguments: id);
                },
                icon: const Icon(Icons.edit),
                color: Colors.blue,
              ),
              const VerticalDivider(
                color: Colors.black45,
              ),
              IconButton(
                onPressed: () async {
                  try {
                    await Provider.of<Product>(context, listen: false)
                        .deleteProduct(id);
                  } catch (error) {
                    sc.showSnackBar(
                      const SnackBar(
                        content: Text('Deleting failed!...'),
                        duration: Duration(milliseconds: 400),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.delete),
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
