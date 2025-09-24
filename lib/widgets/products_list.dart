import 'package:flutter/material.dart';
import '../models/products.dart';

class ProductsList extends StatelessWidget {
  final List<Products> products;
  final Function deletefunc;
  const ProductsList(this.products, this.deletefunc);

  @override
  Widget build(BuildContext context) {
    return products.isEmpty
        ? LayoutBuilder(
            builder: (ctx, constraints) {
              return Column(
                children: [
                  Text(
                    'No products available!',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          )
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemCount: products.length,
            itemBuilder: (ctx, index) {
              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: Column(
                  children: [
                    Text(
                      products[index].title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₦${products[index].price.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.delete),
                      label: Text('Delete'),
                      onPressed: () => deletefunc(products[index].id),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
