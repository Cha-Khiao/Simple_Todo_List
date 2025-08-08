import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/todo_model.dart';

class StorageService {
  // จัดการไฟล์ JSON สำหรับ Todo
  Future<File> get _localFile async {
    try {
      // ถ้าเป็นเว็บ ใช้ SharedPreferences แทนไฟล์
      if (kIsWeb) {
        throw UnsupportedError('Web platform uses SharedPreferences');
      }
      
      // ใช้ package path_provider จริงๆ
      final directory = await getApplicationDocumentsDirectory();
      return File('${directory.path}/todos.json');
    } catch (e) {
      print('Error getting documents directory: $e');
      
      // Fallback สำหรับ mobile
      try {
        final tempDir = await getTemporaryDirectory();
        return File('${tempDir.path}/todos.json');
      } catch (e) {
        print('Error getting temporary directory: $e');
        
        // Fallback สุดท้าย: ใช้ current directory
        try {
          final currentDir = Directory.current;
          return File('${currentDir.path}/todos.json');
        } catch (e) {
          print('Error getting current directory: $e');
          throw Exception('Cannot access any storage directory');
        }
      }
    }
  }
  
  Future<List<Todo>> getTodos() async {
    try {
      // สำหรับเว็บ ใช้ SharedPreferences แทนไฟล์
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final todosJson = prefs.getString('todos');
        if (todosJson != null && todosJson.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(todosJson);
          return jsonList.map((json) => Todo.fromJson(json)).toList();
        }
        return [];
      }
      
      // สำหรับ mobile ใช้ไฟล์ตามปกติ
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(contents);
          return jsonList.map((json) => Todo.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error loading todos: $e');
      return [];
    }
  }
  
  Future<void> saveTodos(List<Todo> todos) async {
    try {
      final jsonList = todos.map((todo) => todo.toJson()).toList();
      final todosJson = jsonEncode(jsonList);
      
      // สำหรับเว็บ ใช้ SharedPreferences แทนไฟล์
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('todos', todosJson);
        return;
      }
      
      // สำหรับ mobile ใช้ไฟล์ตามปกติ
      final file = await _localFile;
      await file.writeAsString(todosJson);
    } catch (e) {
      print('Error saving todos: $e');
    }
  }
  
  // จัดการ SharedPreferences สำหรับสถานะการล็อกอิน
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }
  
  Future<void> setLoginStatus(bool status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', status);
    } catch (e) {
      print('Error setting login status: $e');
    }
  }
  
  Future<String?> getUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('username');
    } catch (e) {
      print('Error getting username: $e');
      return null;
    }
  }
  
  Future<void> setUsername(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
    } catch (e) {
      print('Error setting username: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('username');
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}