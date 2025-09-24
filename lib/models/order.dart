import 'package:flutter/material.dart';

class Order with ChangeNotifier {
  final DateTime id;
  final String userId;
  final double price;
  final int quantity;
  final String items;
  Order({
  required this.id,
  required this.userId, 
  required this.price, 
  required this.quantity,
  required this.items,
  });
}
