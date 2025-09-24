import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/http_exception.dart';
import '../models/products.dart';
import '../models/transaction.dart';
import '../models/order.dart';

class Orders with ChangeNotifier {
  List<Order> _items = [];

  // final String? authToken;
  // final String? userId;

// Product(this.userId);
  // Product(this.authToken, this.userId);

  Future <void> addOrder(Order item) async {
    final link = 'https://class-expense-app-default-rtdb.firebaseio.com/orders.json';
    final url = Uri.parse(link);
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'id': item.id.toIso8601String(),
          'price': item.price,
          'userId': item.userId,
          'quantity': item.quantity,
          'item': item.items
        }),
      );
      final newOrder = Order(
        id: item.id,
        price: item.price,
        userId: item.userId,
        quantity: item.quantity,
        items: item.items
      );
      _items.add(newOrder);
      notifyListeners();
      print(json.decode(response.body));
    } catch (error) {
      print(error);
      rethrow;
    }
      }
  }