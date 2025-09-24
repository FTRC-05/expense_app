import 'package:expense_app/models/transaction.dart';
import 'package:expense_app/provider/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewTransaction extends StatefulWidget {
  // final Function addTx;
  final String? id;
  const NewTransaction(this.id);

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  @override
  // final _form = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  var _isLoading = false;
  final GlobalKey<FormState> _form = GlobalKey();

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  var _editedProduct = Transaction(
    id: '',
    title: '',
    amount: 0,
    date: DateTime.now(),
  );
  var isInit = true;
  var initValues = {'title': '', 'amount': '', 'date': ''};
  void didChangeDependencies() {
    final prodId = widget.id;
    if (isInit) {
      if (prodId != null) {
        _editedProduct = Provider.of<Product>(
          context,
          listen: false,
        ).findById(prodId);

        initValues = {
          'title': _editedProduct.title,
          'amount': _editedProduct.amount.toString(),
          'date': _editedProduct.date.toString(),
        };
      }
      print(initValues);
    }
    isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_editedProduct.id != '') {
        await Provider.of<Product>(
          context,
          listen: false,
        ).updateProduct(
          widget.id!,
          _editedProduct,
        );
      } else {
        await Provider.of<Product>(
          context,
          listen: false,
        ).addProduct(_editedProduct);
      }
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
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                TextFormField(
                  initialValue: initValues['title'],
                  decoration: InputDecoration(labelText: 'Title'),
                  // controller: _titleController,
                  // onSubmitted: (_) => _submitData(),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please provide a title.';
                    }
                    return null;
                  },
                  onSaved: (title) {
                    _editedProduct = Transaction(
                      title: title!,
                      id: _editedProduct.id,
                      amount: _editedProduct.amount,
                      date: _selectedDate!,
                    );
                  },
                ),
                TextFormField(
                  initialValue: initValues['amount'],
                  decoration: InputDecoration(labelText: 'Amount'),
                  // controller: _amountController,
                  keyboardType: TextInputType.number,
                  // onSubmitted: (_) => _submitData(),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an amount.';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Please enter a number greater than zero.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _editedProduct = Transaction(
                      title: _editedProduct.title,
                      amount: double.parse(value!),
                      id: _editedProduct.id,
                      date: _selectedDate!,
                    );
                  },
                ),
                SizedBox(
                  height: 70,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'No Date Chosen!'
                              : 'Picked Date: ${DateFormat.yMd().format(_selectedDate!)}',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _presentDatePicker,
                        child: Text(
                          'Choose Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveForm,
                  child: Text('Add Transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
