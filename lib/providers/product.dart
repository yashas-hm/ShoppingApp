import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/model/HTTPException.dart';

import '../api_key.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavourite(String authToken, String userId) async {
    final url = Uri.http(APIKey.databaseUrl,'/favourites/$userId/$id.json', {"auth" : authToken},);
    isFavorite = !isFavorite;
    notifyListeners();
    try{
      final response = await http.put(url,
          body: json.encode({
            isFavorite,
          }));
      if(response.statusCode>=400){
        throw HTTPException('Could not mark');
      }
    }catch(error){
      isFavorite = !isFavorite;
      notifyListeners();
    }
  }
}
