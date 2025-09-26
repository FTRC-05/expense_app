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
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCIwx_o-w7t9VxgEIwOz06rDmbxFF3UW14',
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
      autoLogout();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': response['idToken'],
          'userId': response['localId'],
          'expiryDate': _expiryDate!.toIso8601String(),
        },
      );

      prefs.setString('userData', userData);
      print(userData);
      print(_userId);
      if (request.statusCode != 200) {
        throw HttpException(response['error']['message']);
      }
    } catch (e) {
      throw e;
    }
  }
 Future <void> logout() async {
    _token =null;
    _userId = null;
    _expiryDate = null;
    if(_authTimer != null){
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogout(){
    if(_authTimer != null){
      _authTimer!.cancel();
    }
    // final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    final expiryTime = _expiryDate!.difference(DateTime.now()).inSeconds;

    _authTimer = Timer(Duration(seconds: expiryTime), logout);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.containsKey('userData');
    if(!prefs.containsKey('userData')){
      return false;
    }
    final extractedData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']);

    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }

    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    autoLogout();
    return true;
  }
}
