import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'package:provider/provider.dart';
import '../provider/product.dart';
import 'new_transaction.dart';

class TransactionList extends StatefulWidget {
  // final List<Transaction> transactions;
  // final Function deleteTx;
  // const TransactionList(this.transactions, this.deleteTx);

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<Product>(context).fetchTransactions();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _startAddNewTransaction(BuildContext ctx, id) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: NewTransaction(id),
        );
      },
    );
  }

  @override
  // didChangeDependencies();
  Widget build(BuildContext context) {
    final products = Provider.of<Product>(context).items;
    return products.isEmpty
        ? LayoutBuilder(
            builder: (ctx, constraints) {
              return Column(
                children: [
                  Text(
                    'No transactions added yet!',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 440,
                    // child: Image.asset(
                    //   'assets/images/waiting.png',
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                ],
              );
            },
          )
        : ListView.builder(
            itemCount: products.length,
            itemBuilder: (ctx, index) {
              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: FittedBox(
                        child: Text(
                          '₦${products[index].amount.toStringAsFixed(2)}',
                        ),
                      ),
                    ),
                  ),
                  title: Text(products[index].title),
                  subtitle: Text(
                    DateFormat.yMMMd().format(products[index].date),
                  ),
                  trailing: MediaQuery.of(context).size.width > 460
                      ? SizedBox(
                          width: 200,

                          child: Row(
                            children: [
                              ElevatedButton.icon(
                                icon: Icon(Icons.edit),
                                label: Text('Edit'),
                                onPressed: () => {
                                  _startAddNewTransaction(
                                    context,
                                    products[index].id,
                                  ),
                                },
                              ),
                              ElevatedButton.icon(
                                icon: Icon(Icons.delete),
                                label: Text('Delete'),
                                onPressed: () {
                                  Provider.of<Product>(
                                    context,
                                    listen: false,
                                  ).deleteProducts(products[index].id);
                                },
                              ),
                            ],
                          ),
                        )
                      : IconButton(
                          onPressed: () async {
                            try{
                              await Provider.of<Product>(context, listen: false).deleteProducts(products[index].id);
                            } catch (e){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not delete item',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              );
                            }
                          },
                          icon: Icon(Icons.delete),
                        ),
                ),
              );
            },
          );
  }
}
