import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../providers/product.dart';

class AddedProduct extends StatefulWidget {
  static const routeName = '/added-screen';

  @override
  State<AddedProduct> createState() => _AddedProductState();
}

class _AddedProductState extends State<AddedProduct> {
  var view = false;
  final _imageController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var isInit;
  late final productId;
  var isLoading = false;

  Map<String, String> editedModel = {
    "id": '',
    "title": '',
    "description": '',
    "price": "",
    "imageUrl": '',
    "isFav": "false",
  };

  @override
  void initState() {
    super.initState();
    isInit = true;
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      productId = ModalRoute.of(context)!.settings.arguments;
      if (productId != null) {
        ProductModel obj = Provider.of<Product>(context).findByID(productId);
        editedModel["id"] = obj.id;
        editedModel["title"] = obj.title;
        editedModel["description"] = obj.description;
        editedModel["price"] = obj.price.toString();
        editedModel["imageUrl"] = obj.imageUrl;
        editedModel["isFav"] = obj.isFav.toString();
        _imageController.text = obj.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  //  WITHOUT ASYNC, AWAIT, .then(), and .catchError()

  // void saveForm() {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   _form.currentState?.validate();
  //   _form.currentState?.save();
  //   // print('saving form');
  //   if (editedModel["id"] == '') {
  //     //new product
  //     // print("adding");
  //     Provider.of<Product>(context, listen: false)
  //         .addProduct(editedModel)
  //         .catchError((error) {
  //           //we need to rethrow from addProduct method in product.dart as it gives us the convenience to update something in our
  //           //widget once we are faced with an error from the database
  //       return showDialog<Null>(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text('An error occurred!'),
  //           content: const Text('Something went wrong...'),
  //           actions: [
  //             TextButton(
  //               child: const Text('Got it!'),
  //               onPressed: () => Navigator.of(context).pop(),
  //             )
  //           ],
  //         ),
  //       );
  //     }).then(
  //       (_) => Navigator.of(context).pop(),
  //     );
  //   } else {
  //     //edit product
  //     // print("editing");
  //     Provider.of<Product>(context, listen: false)
  //         .updateProduct(editedModel, productId);
  //     setState(() {
  //       isLoading = false;
  //     });
  //     Navigator.of(context).pop();
  //   }
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       duration: const Duration(
  //         milliseconds: 500,
  //       ),
  //       content: Text(editedModel["title"]! + " Updated!"),
  //     ),
  //   );
  // }

  // METHOD 2 - USING ASYNC, AWAIT, TRY, CATCH, FINALLY

  Future<void> saveForm() async {
    setState(() {
      isLoading = true;
    });
    _form.currentState?.validate();
    _form.currentState?.save();
    if (editedModel["id"] == '') {
      try {
        await Provider.of<Product>(context, listen: false)
            .addProduct(editedModel);     //PUT request
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('An error occurred!'),
            content: const Text('Something went wrong...'),
            actions: [
              TextButton(
                child: const Text('Got it!'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
      }
      // finally {
      //   setState(() {
      //     isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    } else {
      //edit product
      // print("editing");
      await Provider.of<Product>(context, listen: false)
          .updateProduct(editedModel, productId);       //PATCH request
      // setState(() {
      //   isLoading = false;
      // });
      // Navigator.of(context).pop();
    }

    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(
          milliseconds: 500,
        ),
        content: Text(editedModel["title"]! + " Updated!"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,

        title: const Text('EDIT PRODUCT'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.done,
            ),
            onPressed: () {
              saveForm();
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                //here instead of using a listview use a singlechildscrollview with a column as for forms
                //if any form field goes out of the listview then the listview might dynamically remove it
                // and so the data written onto that form field may get lost
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: editedModel["title"],
                        decoration: const InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == "") {
                            return 'Please enter a valid title';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          editedModel["id"] = editedModel["id"]!;
                          editedModel["isFav"] = editedModel["isFav"]!;
                          editedModel["title"] = newValue!;
                        },
                      ),
                      TextFormField(
                        initialValue: editedModel["price"],
                        decoration: const InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == "") {
                            return 'Please enter a price';
                          }
                          if (double.parse(value!) <= 0) {
                            return 'Please enter a non-negative value of price!';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          editedModel["price"] = newValue!;
                        },
                      ),
                      TextFormField(
                        initialValue: editedModel["description"],
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        validator: (value) {
                          if (value == "") {
                            return 'Please enter a description';
                          }
                          if (value!.length <= 5) {
                            return 'A valid description must be atleast 5 characters long!';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          editedModel["description"] = newValue!;
                        },
                      ),
                      TextFormField(
                        // initialValue: editedModel["imageUrl"],
                        decoration:
                            const InputDecoration(labelText: 'Image URL'),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageController,
                        validator: (value) {
                          if (value == "") {
                            return 'Please enter a valid Image URL';
                          }
                          if (!value!.startsWith("https://") &&
                              !value.endsWith(".jpg") &&
                              !value.endsWith(".jpeg") &&
                              !value.endsWith(".png")) return null;
                        },
                        onFieldSubmitted: (_) => saveForm(),
                        onEditingComplete: () {
                          setState(() {});
                        },
                        onSaved: (newValue) {
                          editedModel["imageUrl"] = newValue!;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        onPressed: () {
                          view = !view;
                          setState(() {});
                        },
                        child: const Text('View Image',
                        style: TextStyle(color: Colors.purple),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (view)
                        Container(
                          height: 200,
                          width: 200,
                          child: Card(
                            elevation: 20,
                            child: _imageController.text.isEmpty
                                ? const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Image Preview',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : FittedBox(
                                    fit: BoxFit.cover,
                                    child: Image.network(_imageController.text),
                                  ),
                          ),
                        ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
