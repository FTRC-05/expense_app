import 'package:expense_app/main.dart';
import 'package:provider/provider.dart';
import '../provider/auth.dart';
import '../models/http_exception.dart';

import 'package:flutter/material.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatefulWidget {
  // const Auth({super.key});

  @override
  State<AuthScreen> createState() => _AuthState();
}

class _AuthState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authmode = AuthMode.Login;

  void _switchAuthMode() {
    if (_authmode == AuthMode.Login) {
      setState(() {
        _authmode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authmode == AuthMode.Login;
      });
    }
  }

  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occured'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  Map<String, String> _authData = {'email': '', 'password': ''};
  var _isLoading = false;

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
      if (_authmode == AuthMode.Login) {
        await Provider.of<Auth>(
          context,
          listen: false,
        ).login(_authData['email']!, _authData['password']!);
      } else {
        // Sign user up
        await Provider.of<Auth>(
          context,
          listen: false,
        ).signup(_authData['email']!, _authData['password']!);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email address';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not authenticate you. Please try again later';
      _showErrorDialog(errorMessage);
    }
    // Navigator.of(context).pushReplacementNamed(MyHomePage.routeName);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sign Up'),
                  SizedBox(height: 20),
                  // if (_authmode == AuthMode.Signup)
                  TextFormField(
                    controller: _emailController,
                    onSaved: (newValue) {
                      _authData['email'] = newValue!;
                    },
                    // enabled: _authmode == AuthMode.SignUp,
                    decoration: InputDecoration(
                      hintText: 'email',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Invalid Email format';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),

                  TextFormField(
                    obscureText: true,
                    controller: _passwordController,
                    onSaved: (newValue) {
                      _authData['password'] = newValue!;
                    },
                    // enabled: _authmode == AuthMode.Login,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),

                    validator: (value) {
                      if (value!.isEmpty || value.length < 6) {
                        return 'Password is too short!';
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  if (_authmode == AuthMode.Signup)
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match!';
                        }
                      },
                    ),

                  // enabled: _authmode == AuthMode.SignUp,
                  SizedBox(height: 10),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submit,
                          child: Text(
                            _authmode == AuthMode.Login ? 'LOGIN' : 'SIGNUP',
                          ),
                        ),
                  ElevatedButton(
                    onPressed: () {
                      _switchAuthMode();
                    },
                    child: Text(
                      '${_authmode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'}INSTEAD',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
