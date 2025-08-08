import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/storage_service.dart';

class TodoProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Todo> _todos = [];
  List<Todo> _filteredTodos = [];
  bool _isLoading = true;
  
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, completed
  
  List<Todo> get todos => _filteredTodos;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;
  
  // สถิติ
  int get totalTodos => _todos.length;
  int get completedTodos => _todos.where((t) => t.isCompleted).length;
  int get activeTodos => _todos.where((t) => !t.isCompleted).length;
  int get pinnedTodos => _todos.where((t) => t.isPinned).length;
  
  TodoProvider() {
    loadTodos();
  }
  
  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _todos = await _storageService.getTodos();
      _applyFilters();
    } catch (e) {
      print('Error loading todos: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> saveTodos() async {
    try {
      await _storageService.saveTodos(_todos);
    } catch (e) {
      print('Error saving todos: $e');
    }
  }
  
  void _applyFilters() {
    _filteredTodos = _todos.where((todo) {
      // ค้นหา
      final matchesSearch = _searchQuery.isEmpty ||
          todo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          todo.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // กรองตามสถานะ
      final matchesStatus = _filterStatus == 'all' ||
          (_filterStatus == 'active' && !todo.isCompleted) ||
          (_filterStatus == 'completed' && todo.isCompleted);
      
      return matchesSearch && matchesStatus;
    }).toList();
    
    // เรียงลำดับ - งานที่ปักหมุดจะแสดงก่อน และเรียงตามความเร่งด่วน
    _filteredTodos.sort((a, b) {
      // ถ้า a ปักหมุด แต่ b ไม่ปักหมุด ให้ a มาก่อน
      if (a.isPinned && !b.isPinned) return -1;
      // ถ้า b ปักหมุด แต่ a ไม่ปักหมุด ให้ b มาก่อน
      if (!a.isPinned && b.isPinned) return 1;
      
      // ถ้าทั้งคู่ปักหมุด หรือทั้งคู่ไม่ปักหมุด ให้เรียงตามความเร่งด่วน
      // ignore: unused_local_variable
      final now = DateTime.now();
      
      // ตรวจสอบว่ามีวันครบกำหนดหรือไม่
      final bool aHasDueDate = a.reminderDateTime != null;
      final bool bHasDueDate = b.reminderDateTime != null;
      
      // ถ้า a มีวันครบกำหนด แต่ b ไม่มี ให้ a มาก่อน
      if (aHasDueDate && !bHasDueDate) return -1;
      // ถ้า b มีวันครบกำหนด แต่ a ไม่มี ให้ b มาก่อน
      if (!aHasDueDate && bHasDueDate) return 1;
      // ถ้าทั้งคู่มีวันครบกำหนด ให้เปรียบเทียบวันที่
      if (aHasDueDate && bHasDueDate) {
        return a.reminderDateTime!.compareTo(b.reminderDateTime!);
      }
      // ถ้าทั้งคู่ไม่มีวันครบกำหนด ให้เรียงตามวันที่สร้าง
      return b.createdAt.compareTo(a.createdAt);
    });
    
    notifyListeners();
  }
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }
  
  void setFilterStatus(String status) {
    _filterStatus = status;
    _applyFilters();
  }
  
  void addTodo(Todo todo) {
    _todos.add(todo);
    _applyFilters();
    saveTodos();
  }
  
  void updateTodo(Todo updatedTodo) {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      _todos[index] = updatedTodo;
      _applyFilters();
      saveTodos();
    }
  }
  
  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    _applyFilters();
    saveTodos();
  }
  
  void toggleTodoStatus(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      _applyFilters();
      saveTodos();
    }
  }
  
  void updateTodoColor(String id, Color color) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].color = color;
      _applyFilters();
      saveTodos();
    }
  }
  
  void togglePinStatus(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].isPinned = !_todos[index].isPinned;
      _applyFilters();
      saveTodos();
    }
  }
  
  void clearCompleted() {
    _todos.removeWhere((todo) => todo.isCompleted);
    _applyFilters();
    saveTodos();
  }
}