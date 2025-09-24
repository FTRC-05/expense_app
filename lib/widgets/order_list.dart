import 'package:expense_app/models/order.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/orders.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  @override

  final GlobalKey<FormState> _form = GlobalKey();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  var isLoading = false;

    var _editedOrder = Order(
    id: DateTime.now(),
    userId: 'u1',
    price: 0,
    quantity: 0,
    items: '',
  );

  Future<void> _saveOrder() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    _form.currentState!.save();
    
    try {
      await Provider.of<Orders>(
        context,
        listen: false,
      ).addOrder(_editedOrder);
    } catch (error) {
      print(error);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SafeArea(child: Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a item.';
                      }
                      return null;
                    },
                    onSaved: (item) {
                      _editedOrder = Order(
                        id: _editedOrder.id,
                        userId: _editedOrder.userId,
                        price: _editedOrder.price,
                        quantity: _editedOrder.quantity,
                        items: item!,
                      );
                    },
                    decoration: InputDecoration(labelText: 'Item'),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a amount.';
                      }
                      return null;
                    },
                    onSaved: (price) {
                      _editedOrder = Order(
                        id: _editedOrder.id,
                        userId: _editedOrder.userId,
                        price: double.parse(price!),
                        quantity: _editedOrder.quantity,
                        items: _editedOrder.items,
                      );
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Amount'),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a quantity.';
                      }
                      return null;
                    },
                    onSaved: (quantity) {
                      _editedOrder = Order(
                        id: _editedOrder.id,
                        userId: _editedOrder.userId,
                        price: _editedOrder.price,
                        quantity: int.parse(quantity!),
                        items: _editedOrder.items,
                      );
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Quantity'),
                  ),
                    isLoading
                      ? CircularProgressIndicator()
                      :
                  ElevatedButton(onPressed: _saveOrder, child: Text('Add Order')),
                ],
                
              ),
              
            )
            ),
          ],
        ),
      ),
    );
  }
}