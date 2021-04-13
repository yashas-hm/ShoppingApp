import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api_key.dart';
import '../model/HTTPException.dart';
import 'product.dart';

class Products with ChangeNotifier {
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._list);

  List<Product> _list = [];

  List<Product> get items {
    return _showFavOnly
        ? _list.where((element) => element.isFavorite).toList()
        : [..._list];
  }

  bool _showFavOnly = false;

  void showFav(bool check) {
    _showFavOnly = check;
    notifyListeners();
  }

  Product itemById(String id) {
    return _list.firstWhere((element) => element.id == id);
  }

  Future<void> updateProduct(String id, Product product) async {
    final index = _list.indexWhere((element) => element.id == id);
    if (index >= 0) {
      final url = Uri.https(
        APIKey.databaseUrl,
        '/products/$id.json', {"auth" : authToken},
      );
      await http.patch(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavourite': product.isFavorite,
          }));
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        Uri.https(APIKey.databaseUrl, '/products/$id.json',{"auth" : authToken},);
    final index = _list.indexWhere((element) => element.id == id);
    var product = _list[index];
    _list.removeAt(index);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _list.insert(index, product);
      notifyListeners();
      throw HTTPException('Couldn\'t delete product');
    }
    product = null;
  }

  Future<void> fetchAndSync() async {
    var url = Uri.https(
      APIKey.databaseUrl,
      '/products.json',
        {
          "auth": authToken
        },
    );
    try {
      final result = await http.get(url);

      final extractedData = json.decode(result.body) as Map<String, dynamic>;
      final List<Product> loaded = [];
      if (extractedData == null) {
        return;
      }
      url = Uri.https(
          APIKey.databaseUrl, '/favourites/$userId.json', {"auth": authToken});
      final favResponse = await http.get(url);
      final favourite = json.decode(favResponse.body);
      extractedData.forEach((id, data) {
        loaded.insert(
            0,
            Product(
              id: id,
              title: data['title'],
              description: data['description'],
              price: data['price'],
              imageUrl: data['imageUrl'],
              isFavorite: favourite == null ? false : favourite[id] ?? false,
            ));
      });
      _list = loaded;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> addProduct(Product product) async {
    final _url = Uri.http(
      APIKey.databaseUrl,
      'products.json',{"auth" : authToken},
    );
    try {
      final response = await http.post(
        _url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );

      final productData = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        imageUrl: product.imageUrl,
        price: product.price,
        description: product.description,
      );
      _list.add(productData);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
