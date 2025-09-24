import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }
  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }
  String? get userId {
    return _userId;
  }

  Future<void> signup(email, password) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCIwx_o-w7t9VxgEIwOz06rDmbxFF3UW14',
    );

    try {
      final request = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final response = json.decode(request.body);
    } catch (e) {
      throw e;
    }
  }

  Future<void> login(email, password) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=AIzaSyCIwx_o-w7t9VxgEIwOz06rDmbxFF3UW14',
    );

    try {
      final request = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final response = json.decode(request.body);

      _token = response['idToken'];
      _userId = response['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(response['expiresIn'])));
      notifyListeners();
      // _autoLogout();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': response['idToken'],
          'userId': response['localId'],
          'expiryDate': _expiryDate!.toIso8601String(),
        },
      );

      prefs.setString('userData', userData);
      if (request.statusCode != 200) {
        throw HttpException(response['error']['message']);
      }
    } catch (e) {
      throw e;
    }
  }
}
