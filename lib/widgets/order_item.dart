import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as order;

class OrderItem extends StatefulWidget {
  final order.OrderItem _orderItem;

  OrderItem(this._orderItem);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _expanded
          ? min(
              widget._orderItem.products.length * 20.0 + 130.0,
              250,
            )
          : 95,
      curve: Curves.easeIn,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('\$${widget._orderItem.amount}'),
              subtitle: Text(DateFormat('dd/MM/yyyy hh:mm')
                  .format(widget._orderItem.dateTime)),
              trailing: IconButton(
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                ),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                height: _expanded?min(
                  widget._orderItem.products.length * 20.0 + 30.0,
                  130,
                ):0,
                child: ListView(
                  children: widget._orderItem.products
                      .map(
                        (prod) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              prod.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${prod.quantity} X \$${prod.price}',
                              style: TextStyle(fontSize: 18, color: Colors.cyan),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
