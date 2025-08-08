import 'dart:ui';

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
    this.color = const Color(0xFF6750A4),
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