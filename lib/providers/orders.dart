import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart' show CartItem;
import '../api_key.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> items, double amount) async {
    final url = Uri.http(
        APIKey.databaseUrl,
        'orders.json');
    final timeStamp = DateTime.now();

    final response = await http.post(url,
        body: json.encode({
          'amount': amount,
          'dateTime': timeStamp.toIso8601String(),
          'products': items
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }));

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: amount,
        products: items,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }

  Future<void> fetchAndSync() async {
    final url = Uri.http(
        APIKey.databaseUrl,
        'orders.json');
    final response = await http.get(url);
    final List<OrderItem> orderItems = [];
    final jsonData = json.decode(response.body) as Map<String, dynamic>;
    if(jsonData==null){
      return;
    }
    jsonData.forEach((id, item) {
      orderItems.add(OrderItem(
          id: id,
          amount: item['amount'],
          dateTime: DateTime.parse(item['dateTime']),
          products: (item['products'] as List<dynamic>)
              .map((data) => CartItem(
                    id: data['id'],
                    title: data['title'],
                    price: data['price'],
                    quantity: data['quantity'],
                  ))
              .toList()));
    });
    _orders = orderItems.reversed.toList();
    notifyListeners();
  }
}
