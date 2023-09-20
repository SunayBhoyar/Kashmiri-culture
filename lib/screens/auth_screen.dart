import 'dart:math';
import 'package:flutter/material.dart';
import '../models/http_exception.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0): .. is the offset operator,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Text(
                        'MyShop',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  // To show an error passed to it as a string
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Text('An Error Occured!'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  var _isLoading = false;
  final _passwordController = TextEditingController();
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  //ANIMATION
  late AnimationController _controller;
  late Animation<Size> _heightAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opactityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heightAnimation = Tween<Size>(
            begin: const Size(double.infinity, 260),
            end: const Size(double.infinity, 320))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _opactityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceIn,
      ),
    );

    // _slideAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
          _authData["email"]!,
          _authData["password"]!,
        );
      }
    } on HttpException catch (error) {
      // ONLY CATCHES HttpException TYPE OF ERRORS using "ON" keyword  -> Filtered Catch Block
      var errorMessage =
          'Authentication Failed! Please try again later!'; //default error message which will be overwritten later incase any specific type of error occurs
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'Email already exists! Please login...';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address!';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak!';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email!';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Please enter a valid password!';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      // print(error);
      const errorMessage = 'Authentication Failed! Please try again later!';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 10.0,
        // child: Container(
        //   height: _slideAnimation.value.height,
        //   constraints: BoxConstraints(minHeight: _slideAnimation.value.height),
        //   width: deviceSize.width * 0.75,
        //   padding: const EdgeInsets.all(16.0),
        //   child: Form(
        //     key: _formKey,
        //     child: SingleChildScrollView(
        //       child: Column(
        //         children: <Widget>[
        //           TextFormField(
        //             decoration: const InputDecoration(labelText: 'E-Mail'),
        //             keyboardType: TextInputType.emailAddress,
        //             validator: (value) {
        //               if (value!.isEmpty || !value.contains('@')) {
        //                 return 'Invalid email!';
        //               }
        //               return null;
        //             },
        //             onSaved: (value) {
        //               _authData['email'] = value!;
        //             },
        //           ),
        //           TextFormField(
        //             decoration: const InputDecoration(labelText: 'Password'),
        //             obscureText: true,
        //             controller: _passwordController,
        //             validator: (value) {
        //               if (value!.isEmpty || value.length < 5) {
        //                 return 'Password is too short!';
        //               }
        //             },
        //             onSaved: (value) {
        //               _authData['password'] = value!;
        //             },
        //           ),
        //           if (_authMode == AuthMode.Signup)
        //             TextFormField(
        //               enabled: _authMode == AuthMode.Signup,
        //               decoration:
        //                   const InputDecoration(labelText: 'Confirm Password'),
        //               obscureText: true,
        //               validator: (_authMode == AuthMode.Signup)
        //                   ? (value) {
        //                       if (value != _passwordController.text) {
        //                         return 'Passwords do not match!';
        //                       }
        //                     }
        //                   : null,
        //             ),
        //           const SizedBox(
        //             height: 20,
        //           ),
        //           if (_isLoading)
        //             const CircularProgressIndicator()
        //           else
        //             ElevatedButton(
        //               onPressed: _submit,
        //               child:
        //                   Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
        //             ),
        //           TextButton(
        //             onPressed: _switchAuthMode,
        //             child: Text(
        //                 '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),

        child: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, ch) => Container(
              height: _heightAnimation.value.height,
              constraints:
                  BoxConstraints(minHeight: _heightAnimation.value.height),
              width: deviceSize.width * 0.75,
              padding: const EdgeInsets.all(16.0),
              child: ch),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'E-Mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Invalid email!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 5) {
                        return 'Password is too short!';
                      }
                    },
                    onSaved: (value) {
                      _authData['password'] = value!;
                    },
                  ),
                  if (_authMode == AuthMode.Signup)
                    AnimatedContainer(
                      constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.Login ? 0 : 60,
                        maxHeight: _authMode == AuthMode.Login ? 0 : 120,
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      child: FadeTransition(
                        opacity: _opactityAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: TextFormField(
                            enabled: _authMode == AuthMode.Signup,
                            decoration: const InputDecoration(
                                labelText: 'Confirm Password'),
                            obscureText: true,
                            validator: (_authMode == AuthMode.Signup)
                                ? (value) {
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match!';
                                    }
                                  }
                                : null,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP',
                      ),
                    ),
                  TextButton(
                    onPressed: _switchAuthMode,
                    child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
