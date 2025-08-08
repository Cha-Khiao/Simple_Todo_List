import 'package:flutter/material.dart';
import 'package:simple_todo_list/utils/constants.dart';

class DateUtils {
  // แปลงวันที่เป็นภาษาไทยแบบเต็ม
  static String formatThaiDateFull(DateTime date) {
    final weekday = AppConstants.thaiWeekdays[date.weekday - 1];
    final day = date.day;
    final month = AppConstants.thaiMonths[date.month - 1];
    final year = date.year + 543; // แปลงเป็นพ.ศ.
    
    return 'วัน$weekdayที่ $day $month $year';
  }
  
  // แปลงวันที่เป็นภาษาไทยแบบสั้น
  static String formatThaiDateShort(DateTime date) {
    final day = date.day;
    final month = AppConstants.thaiShortMonths[date.month - 1];
    
    return '$day $month';
  }
  
  // แปลงวันที่และเวลาเป็นภาษาไทย (24 ชม.)
  static String formatThaiDateTime(DateTime date) {
    final thaiDate = formatThaiDateShort(date);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$thaiDate $hour:$minute น.';
  }
  
  // แปลงเวลาเป็น 24 ชม. ภาษาไทย
  static String formatThaiTime24H(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    
    return '$hour:$minute น.';
  }
  
  // แปลงเวลาเป็น 12 ชม. ภาษาไทย (สำหรับแสดงผล)
  static String formatThaiTime12H(TimeOfDay time) {
    int hour = time.hour;
    String period = 'เช้า';
    
    if (hour >= 12) {
      period = 'บ่าย';
      if (hour > 12) {
        hour -= 12;
      }
    } else if (hour == 0) {
      hour = 12;
    }
    
    final minute = time.minute.toString().padLeft(2, '0');
    
    return '$hour:$minute $period.';
  }
  
  // แปลงวันที่เป็นรูปแบบ "วันนี้", "พรุ่งนี้", "วันอื่นๆ"
  static String formatThaiDateRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'วันนี้';
    } else if (dateOnly == tomorrow) {
      return 'พรุ่งนี้';
    } else {
      return formatThaiDateShort(date);
    }
  }
  
  // แปลงวันที่และเวลาเป็นรูปแบบสัมพันธ์ (24 ชม.)
  static String formatThaiDateTimeRelative(DateTime date) {
    final dateRelative = formatThaiDateRelative(date);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$dateRelative $hour:$minute น.';
  }
  
  // แปลงวันที่และเวลาเป็นรูปแบบสัมพันธ์ (12 ชม.) สำหรับแสดงผล
  static String formatThaiDateTimeRelative12H(DateTime date) {
    final dateRelative = formatThaiDateRelative(date);
    final time12H = formatThaiTime12H(TimeOfDay.fromDateTime(date));
    
    return '$dateRelative $time12H';
  }
  
  // แปลงระยะเวลาเป็นภาษาไทย
  static String formatThaiDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} วัน';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ชั่วโมง';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} นาที';
    } else {
      return 'เมื่อสักครู่';
    }
  }
  
  // แปลงวันที่เป็นรูปแบบ "กำหนดโดยผู้ใช้"
  static String formatThaiDueDate(DateTime date) {
    final thaiDate = formatThaiDateShort(date);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return 'กำหนด: $thaiDate $hour:$minute';
  }
  
  // แปลงวันที่เป็นรูปแบบ "กำหนดโดยผู้ใช้" แบบสัมพันธ์
  static String formatThaiDueDateRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    String dueText;
    if (dateOnly == today) {
      dueText = 'วันนี้';
    } else if (dateOnly == tomorrow) {
      dueText = 'พรุ่งนี้';
    } else {
      dueText = formatThaiDateShort(date);
    }
    
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return 'กำหนด: $dueText $hour:$minute';
  }
  
  // ตรวจสอบสถานะวันครบกำหนด
  static String getDueDateStatus(DateTime? dueDate) {
    if (dueDate == null) return '';
    
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.inDays < 0) {
      return 'ขาดเกินกำหนด';
    } else if (difference.inDays == 0) {
      return 'ใกล้เกินกำหนด';
    } else if (difference.inDays <= 3) {
      return 'ใกล้ถึงกำหนด';
    } else {
      return 'ยังไม่ถึงกำหนด';
    }
  }
  
  // คืนค่าสีตามสถานะวันครบกำหนด
  static Color getDueDateColor(DateTime? dueDate) {
    if (dueDate == null) return Colors.transparent;
    
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.inDays < 0) {
      return const Color(0xFFE53935); // สีแดง (ขาดเกินกำหนด)
    } else if (difference.inDays == 0) {
      return const Color(0xFFFF9800); // สีส้ม (ใกล้เกินกำหนด)
    } else if (difference.inDays <= 3) {
      return const Color(0xFF7D5260); // สีม่วง (ใกล้ถึงกำหนด)
    } else {
      return const Color(0xFF6750A4); // สีม่วง (ยังไม่ถึงกำหนด)
    }
  }
  
  // ตรวจสอบว่าเป็นวันเดียวกันหรือไม่
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}