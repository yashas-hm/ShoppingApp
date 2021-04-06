import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../api_key.dart';
import '../model/HTTPException.dart';

import 'product.dart';

class Products with ChangeNotifier {

  final String authToken;

  Products(this.authToken);

  List<Product> _list = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

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

  Future<void> updateProduct(String id, Product product) async{
    final index = _list.indexWhere((element) => element.id == id);
    if (index >= 0) {
      final url = Uri.http(APIKey.databaseUrl,'$id.json?auth=$authToken',);
      await http.patch(url, body: json.encode({
        'title': product.title,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'isFavourite': product.isFavorite,
      }));
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async{
    final url = Uri.http(APIKey.databaseUrl,'$id.json?auth=$authToken');
    final index = _list.indexWhere((element) => element.id==id);
    var product = _list[index];
    _list.removeAt(index);
    notifyListeners();
    final response = await http.delete(url);
    if(response.statusCode>=400){
      _list.insert(index, product);
      notifyListeners();
      throw HTTPException('Couldn\'t delete product');
    }
    product = null;
  }

  Future<void> fetchAndSync() async {
    final _url = Uri.http(
      APIKey.databaseUrl,
      'products.json?auth=$authToken',);
    try {
      final result = await http.get(_url);
      final extractedData = json.decode(result.body) as Map<String, dynamic>;
      final loaded  = [];
      if(extractedData==null){
        return;
      }
      extractedData.forEach((id, data) {
        loaded.insert(0, Product(
          id: id,
          title: data['title'],
          description: data['description'],
          price: data['price'],
          imageUrl: data['imageUrl'],
          isFavorite: data['isFavourite']
        ));
      });
      _list = loaded;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final _url = Uri.http(
      APIKey.databaseUrl,
      'products.json?auth=$authToken',);
    try {
      final response = await http.post(
        _url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavourite': product.isFavorite,
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
      throw error;
    }
  }
}
