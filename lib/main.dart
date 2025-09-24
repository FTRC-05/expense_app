import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/transaction.dart';
import 'widgets/transaction_list.dart';
import 'widgets/new_transaction.dart';
import 'widgets/auth_screen.dart';
import 'package:expense_app/widgets/chart.dart';
import './provider/auth.dart';
import './provider/product.dart';
import './models/order.dart';
import 'widgets/order_list.dart';
import './provider/orders.dart';
// import 'models/products.dart';
// import 'widgets/products_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProxyProvider<Auth, Product>(
          create: (context) => Product('', '', []),
          update: (context, authData, productData) => Product(
            authData.token,
            authData.userId,
            productData == null ? [] : productData.items,
          ),
        ),
        // ChangeNotifierProxyProvider<Auth, Orders>(
        //   create: (context) => Orders(),
        //   update: (context, authData, orderData) =>
        //    Orders()
        // ),
      ],

      child: Consumer<Auth>(
        builder: (context, auth, _) {
          print(auth.isAuth);
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            home: auth.isAuth ? MyHomePage() : AuthScreen(),
            routes: {MyHomePage.routeName: (ctx) => MyHomePage()},
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const routeName = '/home-screen';
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransactions = [
    Transaction(
      id: 't1',
      title: 'New Shoes',
      amount: 69.99,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't2',
      title: 'Weekly Groceries',
      amount: 16.53,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't3',
      title: 'Gym Membership',
      amount: 29.99,
      date: DateTime.now(),
    ),
  ];
  final List<Order> _order = [
    Order(
      id: DateTime.now(),
      price: 69.99,
      quantity: 3,
      items: 'Shoes',
      userId: 'u1',
    ),
    Order(
      id: DateTime.now(),
      price: 69.99,
      quantity: 3,
      items: 'Shoes',
      userId: 'u2',
    ),
    Order(
      id: DateTime.now(),
      price: 69.99,
      quantity: 3,
      items: 'Shoes',
      userId: 'u3',
    ),
  ];

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  void _addNewTransaction(
    String txTitle,
    double txAmount,
    DateTime chosenDate,
  ) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );
    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: NewTransaction(''),
        );
      },
    );
  }

  List<Transaction> get _recentTransactions {
    return Provider.of<Product>(context).items.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Expense App'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _startAddNewTransaction(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Chart(_recentTransactions),
            Container(height: 500, child: TransactionList()),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewTransaction(context),
        child: Icon(Icons.add),
      ),
    );
  }
}


// class MyHomePage extends StatefulWidget {
//   final String title;
//   const MyHomePage({super.key, required this.title});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final List<Products> _userProducts = [

//     Products(
//       id: 'p1',
//       title: 'Laptop',
//       description: 'A high performance laptop',
//       price: 999.99,
//       date: DateTime.now(),
//     ),
//     Products(
//       id: 'p2',
//       title: 'Smartphone',
//       description: 'Latest model smartphone',
//       price: 499.99,
//       date: DateTime.now(),
//     ),
//     Products(
//       id: 'p3',
//       title: 'Headphones',
//       description: 'Noise-cancelling headphones',
//       price: 199.99,
//       date: DateTime.now(),
//     ),
//     Products(
//       id: 'p4',
//       title: 'Smartwatch',
//       description: 'Feature-packed smartwatch',
//       price: 299.99,
//       date: DateTime.now(),
//     ),
//     Products(
//       id: 'p5',
//       title: 'Tablet',
//       description: 'Lightweight and powerful tablet',
//       price: 349.99,
//       date: DateTime.now(),
//     ),
//   ];
  
//   void _deleteProduct(String id) {
//     setState(() {
//       _userProducts.removeWhere((prod) => prod.id == id);
//     });
//   }
//   @override

//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: ProductsList(_userProducts, _deleteProduct),
//     );
//   }
// }