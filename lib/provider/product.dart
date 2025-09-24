import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/http_exception.dart';
import '../models/products.dart';
import '../models/transaction.dart';

class Product with ChangeNotifier {
  List<Transaction> _items = [];

  final String? authToken;
  final String? userId;

  // Product(this.userId);
  Product(this.authToken, this.userId, this._items);

  List<Transaction> get items {
    return [..._items];
  }

  Transaction findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Transaction product) async {
    final link =
        'https://class-expense-app-default-rtdb.firebaseio.com/transaction.json';

    final url = Uri.parse(link);
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'amount': product.amount,
          'date': product.date.toIso8601String(),
          'creatorId': userId,
        }),
      );
      final newProduct = Transaction(
        title: product.title,
        amount: product.amount,
        date: product.date,
        id: product.date.toString(),
      );
      _items.add(newProduct);
      notifyListeners();
      print(json.decode(response.body));
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> fetchTransactions([bool filterByUser = false]) async {

    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';

    final url = Uri.parse(
      'https://class-expense-app-default-rtdb.firebaseio.com/transaction.json?$filterString',
    );
    try {
      final response = await http.get(url);
      print(json.decode(response.body));

      // final List<Transaction> loadedProducts = [];
      final extractedProducts =
          json.decode(response.body) as Map<String, dynamic>;

      extractedProducts.forEach((prodId, prodData) {
        _items.add(
          Transaction(
            id: prodId,
            title: prodData['title'],
            amount: (prodData['amount'] as num).toDouble(),
            date: DateTime.parse(prodData['date']),
          ),
        );
      });
      // _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Transaction newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
        'https://class-expense-app-default-rtdb.firebaseio.com/transaction/$id.json',
      );
      await http.patch(
        url,
        body: json.encode({
          'title': newProduct.title,
          'amount': newProduct.amount,
          'date': newProduct.date.toIso8601String(),
        }),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProducts(String id) async {
    final link =
        'https://class-expense-app-default-rtdb.firebaseio.com/transaction/$id.json';
    final url = Uri.parse(link);

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    Transaction? existingProduct = _items[existingProductIndex];

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }
}
