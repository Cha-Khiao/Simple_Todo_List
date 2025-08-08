import 'package:flutter/material.dart' hide DateUtils;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart' as app_date_utils;

class TodoDetailScreen extends StatefulWidget {
  final Todo? todo;
  final bool isReadOnly;
  const TodoDetailScreen({
    Key? key,
    this.todo,
    this.isReadOnly = false,
  }) : super(key: key);
  
  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  Color _selectedColor = const Color(0xFF6750A4);
  DateTime? _dueDateTime;
  bool _selectedPinned = false;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');
    _selectedColor = widget.todo?.color ?? const Color(0xFF6750A4);
    _dueDateTime = widget.todo?.reminderDateTime;
    _selectedPinned = widget.todo?.isPinned ?? false;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      final todoProvider = Provider.of<TodoProvider>(context, listen: false);
      final newTodo = Todo(
        id: widget.todo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        isCompleted: widget.todo?.isCompleted ?? false,
        createdAt: widget.todo?.createdAt ?? DateTime.now(),
        color: _selectedColor,
        reminderDateTime: _dueDateTime,
        isPinned: _selectedPinned,
      );
      
      if (widget.todo == null) {
        todoProvider.addTodo(newTodo);
      } else {
        todoProvider.updateTodo(newTodo);
      }
      
      Navigator.of(context).pop();
    }
  }
  
  Future<void> _selectDueDateTime(BuildContext context) async {
    DateTime initialDate = _dueDateTime ?? DateTime.now();
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('th', 'TH'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            primaryColor: AppConstants.primaryColor,
            colorScheme: ColorScheme.light(
              primary: AppConstants.primaryColor,
              secondary: AppConstants.secondaryColor,
            ),
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                textStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                textStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate == null) return;
    if (!context.mounted) return;
    
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueDateTime != null
          ? TimeOfDay.fromDateTime(_dueDateTime!)
          : TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            primaryColor: AppConstants.primaryColor,
            colorScheme: ColorScheme.light(
              primary: AppConstants.primaryColor,
              secondary: AppConstants.secondaryColor,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? AppConstants.primaryColor
                      : Colors.grey.shade200),
              hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? Colors.white
                      : AppConstants.primaryColor),
              dialHandColor: AppConstants.primaryColor,
              dialTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? Colors.white
                      : Colors.black),
              entryModeIconColor: AppConstants.primaryColor,
            ),
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                textStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                textStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: true,
            ),
            child: child!,
          ),
        );
      },
    );
    
    if (pickedTime == null) return;
    
    setState(() {
      _dueDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isReadOnly ? 'รายละเอียด Todo' : (widget.todo == null ? 'เพิ่ม Todo' : 'แก้ไข Todo'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          // เพิ่มปุ่มปักหมุดใน AppBar
          if (!widget.isReadOnly && widget.todo != null)
            IconButton(
              icon: Icon(
                widget.todo!.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                final todoProvider = Provider.of<TodoProvider>(context, listen: false);
                todoProvider.togglePinStatus(widget.todo!.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'หัวข้อ',
                      hintText: 'ใส่หัวข้อของคุณ',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(Icons.title, color: AppConstants.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppConstants.primaryColor.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppConstants.primaryColor.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: GoogleFonts.poppins(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณาใส่หัวข้อ';
                      }
                      return null;
                    },
                    enabled: !widget.isReadOnly,
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 600))
                      .slideY(begin: 30, end: 0),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'รายละเอียด',
                      hintText: 'ใส่รายละเอียดเพิ่มเติม',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(Icons.description, color: AppConstants.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppConstants.primaryColor.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppConstants.primaryColor.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: GoogleFonts.poppins(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    enabled: !widget.isReadOnly,
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 100))
                      .slideY(begin: 30, end: 0),
                  const SizedBox(height: 16),
                  if (!widget.isReadOnly) ...[
                    _buildColorPicker()
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 200))
                        .slideY(begin: 30, end: 0),
                    const SizedBox(height: 16),
                    _buildDueDatePicker()
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 300))
                        .slideY(begin: 30, end: 0),
                    const SizedBox(height: 24),
                    // เพิ่มส่วนการปักหมุด
                    _buildPinSection()
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 400))
                        .slideY(begin: 30, end: 0),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveTodo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          widget.todo == null ? 'เพิ่ม Todo' : 'อัปเดต Todo',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 500))
                        .slideY(begin: 30, end: 0),
                  ] else ...[
                    _buildReadOnlyColorDisplay()
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 200))
                        .slideY(begin: 30, end: 0),
                    const SizedBox(height: 16),
                    _buildReadOnlyDueDateDisplay()
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 300))
                        .slideY(begin: 30, end: 0),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.color_lens,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'สี',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.predefinedColors.length,
            itemBuilder: (context, index) {
              final color = AppConstants.predefinedColors[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color ? Colors.black : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildDueDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.event,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'วันครบกำหนด',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          child: InkWell(
            onTap: () => _selectDueDateTime(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dueDateTime != null
                          ? app_date_utils.DateUtils.formatThaiDateTime(_dueDateTime!)
                          : 'แตะเพื่อเลือกวันครบกำหนด',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _dueDateTime != null ? AppConstants.primaryColor : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  if (_dueDateTime != null)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _dueDateTime = null;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Icon(
                        Icons.clear,
                        color: Colors.grey.shade700,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_dueDateTime != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppConstants.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'กำหนดให้เสร็จภายในวันที่ ${app_date_utils.DateUtils.formatThaiDateFull(_dueDateTime!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildPinSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.push_pin,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'การปักหมุด',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedPinned = !_selectedPinned;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedPinned ? 'ปักหมุดงานนี้ไว้ด้านบน' : 'ไม่ได้ปักหมุดงานนี้',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Switch(
                    value: _selectedPinned,
                    onChanged: (value) {
                      setState(() {
                        _selectedPinned = value;
                      });
                    },
                    activeColor: AppConstants.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildReadOnlyColorDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.color_lens,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'สี',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _selectedColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: _selectedColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildReadOnlyDueDateDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.event,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'วันครบกำหนด',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppConstants.primaryColor.withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _dueDateTime != null
                      ? app_date_utils.DateUtils.formatThaiDateTime(_dueDateTime!)
                      : 'ไม่ได้กำหนด',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _dueDateTime != null ? AppConstants.primaryColor : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_dueDateTime != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppConstants.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'กำหนดให้เสร็จภายในวันที่ ${app_date_utils.DateUtils.formatThaiDateFull(_dueDateTime!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}