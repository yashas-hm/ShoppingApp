import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../providers/orders.dart' show Orders;
import '../widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart-screen';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    var _isLoading = false;
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 50),
                  ),
                  Spacer(),
                  Chip(
                    label: Text('\$${cart.totalAmt.toStringAsFixed(2)}'),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  _isLoading
                      ? CircularProgressIndicator()
                      : TextButton(
                          onPressed: cart.totalAmt <= 0 || _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await Provider.of<Orders>(context,
                                          listen: false)
                                      .addOrder(
                                    cart.items.values.toList(),
                                    cart.totalAmt,
                                  );
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  cart.clear();
                                },
                          child: Text('ORDER NOW'),
                        )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, i) {
                var values = cart.items.values.toList();
                return CartItem(
                  id: values[i].id,
                  title: values[i].title,
                  price: values[i].price,
                  quantity: values[i].quantity,
                );
              },
              itemCount: cart.itemCount,
            ),
          )
        ],
      ),
    );
  }
}
