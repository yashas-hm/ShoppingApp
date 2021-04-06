import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api_key.dart';
import '../model/HTTPException.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiry;
  String _userId;

  bool get isAuth {
    return _token != null;
  }

  String get token {
    if (_expiry != null && _expiry.isAfter(DateTime.now()) && _token != null) {
    return _token;
    }
    return null;
  }

  Future<void> _authenticate(Uri api, String email, String pass) async {
    final url = api;
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': pass,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HTTPException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiry = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String pass) async {
    return _authenticate(APIKey.signUp, email, pass);
  }

  Future<void> login(String email, String pass) async {
    return _authenticate(APIKey.login, email, pass);
  }
}
