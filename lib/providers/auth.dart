import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart' as sp;

import '../api_key.dart';
import '../model/HTTPException.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiry;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String get token {
    if (_expiry != null && _expiry.isAfter(DateTime.now()) && _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
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
      _autoLogout();
      notifyListeners();
      final pref = await sp.SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiry': _expiry.toIso8601String(),
      });
      pref.setString('data', userData);
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

  Future<bool> tryAutoLogin() async {
    final pref = await sp.SharedPreferences.getInstance();
    if (!pref.containsKey('data')) {
      return false;
    }
    final extracted =
        json.decode(pref.getString('data')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extracted['expiry']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extracted['token'];
    _userId = extracted['userId'];
    _expiry = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async{
    _token = null;
    _userId = null;
    _expiry = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final pref = await sp.SharedPreferences.getInstance();
    pref.clear();
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiry.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), () => logout());
  }
}
