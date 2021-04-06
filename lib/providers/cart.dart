import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get total {
    int sum = 0;
    _items.forEach((key, value) {
      sum += value.quantity;
    });
    return sum;
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmt {
    double sum = 0.0;
    _items.forEach((key, value) {
      sum += (value.price * value.quantity);
    });
    return sum;
  }

  void addItem(String id, String title, double price) {
    if (_items.containsKey(id)) {
      _items.update(
          id,
          (product) => CartItem(
              id: product.id,
              title: product.title,
              price: product.price,
              quantity: product.quantity + 1));
    } else {
      _items.putIfAbsent(
          id,
          () => CartItem(
                id: id,
                title: title,
                price: price,
                quantity: 1,
              ));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void removeSingleItem(String id) {
    if (!_items.containsKey(id)) {
      return;
    }

    if (_items[id].quantity > 1) {
      _items.update(
        id,
        (value) => CartItem(
          id: value.id,
          title: value.id,
          price: value.price,
          quantity: value.quantity - 1,
        ),
      );
    } else {
      _items.remove(id);
    }

    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
