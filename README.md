# Simple ToDo List

## พัฒนาโดย 

### --ทีมงาน ก้องน้อย นอนนา--

1. นายธนาสุข เครือศรี 6612732113
2. นายประสพผล ตาลหอม 6612732118
3. นายวรพล พรหมคุณ 6612732125
4. นางสาววรรณกานต์ สมทิพย์ 6612732139
 
สาขาวิทยาการคอมพิวเตอร์ คณะศิลปศาสตร์และวิทยาศาสตร์ มหาวิทยาลัยราชภัฏศรีสะเกษ

## Packages หลักที่ใช้

- **path_provider**: การจัดการพาธไฟล์
- **provider**: การจัดการสถานะ (State Management)
- **shared_preferences**: การเก็บข้อมูลแบบ Key-Value
- **flutter_animate**: แอนิเมชั่นสวยงาม
- **flutter_staggered_animations**: แอนิเมชั่นสำหรับรายการ
- **google_fonts**: แบบอักษรสวยงาม

## คำอธิบายโปรเจกต์

โปรแกรม Simple ToDo List เป็นแอปพลิเคชันบันทึกสิ่งที่ต้องทำอย่างง่าย พัฒนาด้วย Flutter โดยมีจุดมุ่งหมายเพื่อใช้เป็นสื่อการเรียนการสอนในรายวิชาการพัฒนาโปรแกรมบนมือถือ

### ฟีเจอร์หลัก

- ✅ การเพิ่ม แก้ไข ลบ Todo
- 📅 การตั้งวันครบกำหนดและเวลา
- 📌 การปักหมุดงานสำคัญ
- 🔍 การค้นหาและกรอง Todo
- 🎨 การเปลี่ยนสี Todo
- 📊 การแสดงสถิติความคืบหน้า
- 🌐 รองรับภาษาไทยเต็มรูปแบบ
- 🔐 ระบบล็อกอิน/ล็อกเอาต์ง่ายๆ
- 💾 การบันทึกข้อมูลแบบ Local (JSON)

## ตัวอย่างโค้ดสำคัญ

### โมเดล Todo

```dart
class Todo {
  final String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  Color color;
  DateTime? reminderDateTime;
  bool isPinned;
  
  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    required this.color,
    this.reminderDateTime,
    this.isPinned = false,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'color': color.value,
      'reminderDateTime': reminderDateTime?.toIso8601String(),
      'isPinned': isPinned,
    };
  }
  
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      color: Color(json['color'] ?? 0xFF6750A4),
      reminderDateTime: json['reminderDateTime'] != null 
          ? DateTime.parse(json['reminderDateTime']) 
          : null,
      isPinned: json['isPinned'] ?? false,
    );
  }
}
```

### การจัดการข้อมูลด้วย Provider

```dart
class TodoProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Todo> _todos = [];
  List<Todo> _filteredTodos = [];
  
  List<Todo> get todos => _filteredTodos;
  
  void addTodo(Todo todo) {
    _todos.add(todo);
    _applyFilters();
    saveTodos();
    notifyListeners();
  }
  
  void toggleTodoStatus(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      _applyFilters();
      saveTodos();
      notifyListeners();
    }
  }
  
  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    _applyFilters();
    saveTodos();
    notifyListeners();
  }
  
  void _applyFilters() {
    // ใช้งานตัวกรองและการค้นหา
    _filteredTodos = List.from(_todos);
  }
  
  Future<void> saveTodos() async {
    await _storageService.saveTodos(_todos);
  }
}
```

### การจัดการวันที่ภาษาไทย

```dart
class DateUtils {
  // แปลงวันที่เป็นภาษาไทยแบบเต็ม
  static String formatThaiDateFull(DateTime date) {
    final weekday = AppConstants.thaiWeekdays[date.weekday - 1];
    final day = date.day;
    final month = AppConstants.thaiMonths[date.month - 1];
    final year = date.year + 543; // แปลงเป็นพ.ศ.
    
    return 'วัน$weekdayที่ $day $month $year';
  }
  
  // ตรวจสอบสถานะวันครบกำหนด
  static String getDueDateStatus(DateTime? dueDate) {
    if (dueDate == null) return '';
    
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.inDays < 0) {
      return 'เลยกำหนดแล้ว';
    } else if (difference.inDays == 0) {
      return 'ครบกำหนดวันนี้';
    } else if (difference.inDays <= 3) {
      return 'ใกล้ถึงกำหนด';
    } else {
      return 'ยังไม่ถึงกำหนด';
    }
  }
}
```

### การบันทึกและอ่านไฟล์ JSON

```dart
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/todos.json');
  }
  
  Future<List<Todo>> getTodos() async {
    try {
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
      final file = await _localFile;
      await file.writeAsString(todosJson);
    } catch (e) {
      print('Error saving todos: $e');
    }
  }
}
```

## การใช้งาน

### การเพิ่ม Todo

1. กดปุ่ม **+** ที่มุมขวาล่าง
2. กรอกข้อมูลและตั้งค่าต่างๆ
3. กดปุ่ม **บันทึก**

### การจัดการ Todo

- **ดูรายละเอียด**: กดที่รายการ Todo
- **เมนูตัวเลือก**: ใช้เมนู (⋮) สำหรับ
  - แก้ไขข้อมูล
  - ปักหมุดงานสำคัญ
  - เปลี่ยนสีประจำ Todo
  - ลบ Todo
- **ค้นหาและกรอง**: ใช้ช่องค้นหาและปุ่มกรองด้านบน

### การติดตั้งและรันโปรเจกต์

```bash
# Clone โปรเจกต์
git clone <repository-url>

# เข้าไปยังโฟลเดอร์โปรเจกต์
cd simple_todo_list

# ติดตั้ง dependencies
flutter pub get

# รันแอปพลิเคชัน
flutter run
```

## License

โปรเจกต์นี้ใช้สำหรับการศึกษาเท่านั้น