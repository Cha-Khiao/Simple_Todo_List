import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String _username = '';
  String? _error;
  
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get username => _username;
  String? get error => _error;
  
  AuthProvider() {
    _initializeAuth();
  }
  
  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();
    
    await _loadUserInfo();
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _username = prefs.getString('username') ?? '';
      _error = null;
    } catch (e) {
      _error = 'Failed to load user info: $e';
    }
    notifyListeners();
  }
  
  Future<bool> login(String username, String text) async {
    if (username.trim().isEmpty) {
      _error = 'Please enter your name';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Simulate login delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username.trim());
      
      _isLoggedIn = true;
      _username = username.trim();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Login failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('username');
      
      _isLoggedIn = false;
      _username = '';
      _error = null;
    } catch (e) {
      _error = 'Logout failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}