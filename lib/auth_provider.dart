import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class AuthProvider with ChangeNotifier {
  String? _token;

  String? get token => _token;

  void login(String token) {
    _token = token;
    _storeToken(token); // Store token in SharedPreferences
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    _token = null;
    await _clearToken(); // Clear the token from SharedPreferences
    notifyListeners();

    // Navigate back to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _storeToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token); // Store token
  }

  Future<void> _clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Clear the token from storage
  }
}
