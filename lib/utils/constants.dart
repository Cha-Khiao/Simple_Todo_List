import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Simple ToDo List';
  
  static const Color primaryColor = Color(0xFF6750A4);
  static const Color secondaryColor = Color(0xFFD0BCFF);
  static const Color accentColor = Color(0xFF7D5260);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFE53935);
  
  // Predefined colors for todos
  static const List<Color> predefinedColors = [
    Color(0xFF6750A4), // Deep Purple
    Color(0xFF7D5260), // Mauve
    Color(0xFF006494), // Ocean Blue
    Color(0xFF386641), // Forest Green
    Color(0xFFBC4B51), // Coral Red
    Color(0xFF9C6644), // Terracotta
    Color(0xFF5E548E), // Lavender
    Color(0xFF9A8C98), // Sage Gray
    Color(0xFF4A4E69), // Storm Blue
    Color(0xFFC9ADA7), // Dusty Rose
  ];
  
  // Theme colors for app
  static const List<Color> themeColors = [
    Color(0xFF6750A4), // Deep Purple
    Color(0xFF006494), // Ocean Blue
    Color(0xFF386641), // Forest Green
    Color(0xFFBC4B51), // Coral Red
    Color(0xFF9C6644), // Terracotta
  ];
  
  // Thai month names
  static const List<String> thaiMonths = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
  ];
  
  // Thai short month names
  static const List<String> thaiShortMonths = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
  ];
  
  // Thai weekdays
  static const List<String> thaiWeekdays = [
    'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์'
  ];
}