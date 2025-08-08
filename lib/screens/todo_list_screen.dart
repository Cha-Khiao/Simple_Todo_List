import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart' as app_date_utils;
import 'todo_detail_screen.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final todoProvider = Provider.of<TodoProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Simple Todo List',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(context, todoProvider, authProvider),
                  _buildProgressIndicator(context, todoProvider),
                  _buildSearchAndFilter(context, todoProvider),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Consumer<TodoProvider>(
                      builder: (context, todoProvider, child) {
                        if (todoProvider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                            ),
                          );
                        }
                        if (todoProvider.todos.isEmpty) {
                          return _buildEmptyState(context);
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            await todoProvider.loadTodos();
                          },
                          child: AnimationLimiter(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: todoProvider.todos.length,
                              itemBuilder: (context, index) {
                                final todo = todoProvider.todos[index];
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: _buildTodoCard(context, todo, todoProvider),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildHeader(BuildContext context, TodoProvider todoProvider, AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สวัสดี, ${authProvider.username.isNotEmpty ? authProvider.username : 'ผู้ใช้'} 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'วันนี้คุณมี ${todoProvider.activeTodos} งานที่ต้องทำ',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  app_date_utils.DateUtils.formatThaiDateShort(DateTime.now()),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('ทั้งหมด', todoProvider.totalTodos, Icons.task_alt, AppConstants.primaryColor),
              _buildStatItem('เสร็จ', todoProvider.completedTodos, Icons.check_circle, AppConstants.successColor),
              _buildStatItem('คงเหลือ', todoProvider.activeTodos, Icons.pending, AppConstants.warningColor),
              _buildStatItem('ปักหมุด', todoProvider.pinnedTodos, Icons.push_pin, AppConstants.accentColor),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 30, end: 0);
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, TodoProvider todoProvider) {
    if (todoProvider.totalTodos == 0) return const SizedBox.shrink();
    
    final progress = todoProvider.completedTodos / todoProvider.totalTodos;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ความคืบหน้า',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 100))
        .slideY(begin: 30, end: 0);
  }

  Widget _buildSearchAndFilter(BuildContext context, TodoProvider todoProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'ค้นหา Todo...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: GoogleFonts.poppins(),
                    onChanged: (value) {
                      todoProvider.setSearchQuery(value);
                    },
                  ),
                ),
                if (todoProvider.searchQuery.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      todoProvider.setSearchQuery('');
                    },
                    icon: const Icon(Icons.clear, color: Colors.grey),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('ทั้งหมด', todoProvider.filterStatus == 'all', () {
                  todoProvider.setFilterStatus('all');
                }, Icons.list),
                const SizedBox(width: 8),
                _buildFilterChip('ยังไม่เสร็จ', todoProvider.filterStatus == 'active', () {
                  todoProvider.setFilterStatus('active');
                }, Icons.radio_button_unchecked),
                const SizedBox(width: 8),
                _buildFilterChip('เสร็จแล้ว', todoProvider.filterStatus == 'completed', () {
                  todoProvider.setFilterStatus('completed');
                }, Icons.check_circle),
                const SizedBox(width: 8),
                if (todoProvider.completedTodos > 0)
                  _buildFilterChip('ล้างเสร็จแล้ว', false, () {
                    _showClearCompletedDialog(context, todoProvider);
                  }, Icons.delete_sweep, isDanger: true),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 300))
        .slideY(begin: 30, end: 0);
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, IconData icon, {bool isDanger = false}) {
    return Container(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? (isDanger ? AppConstants.errorColor : AppConstants.primaryColor)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox,
                size: 60,
                color: AppConstants.primaryColor,
              ),
            )
                .animate()
                .scale(duration: const Duration(milliseconds: 600), curve: Curves.elasticOut)
                .then(delay: const Duration(milliseconds: 300))
                .shake(),
            const SizedBox(height: 24),
            Text(
              'ยังไม่มีรายการ Todo',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'กดปุ่ม + เพื่อเพิ่มรายการใหม่',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TodoDetailScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('เพิ่ม Todo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoCard(BuildContext context, Todo todo, TodoProvider todoProvider) {
    // ตรวจสอบความเร่งด่วนของงาน
    final bool isOverdue = todo.reminderDateTime != null && 
        todo.reminderDateTime!.isBefore(DateTime.now()) && 
        !todo.isCompleted;
    
    final bool isDueToday = todo.reminderDateTime != null && 
        app_date_utils.DateUtils.isSameDay(todo.reminderDateTime!, DateTime.now()) && 
        !todo.isCompleted;
    
    final bool isDueSoon = todo.reminderDateTime != null && 
        !todo.isCompleted && 
        !isOverdue && 
        !isDueToday &&
        todo.reminderDateTime!.difference(DateTime.now()).inDays <= 3;
        
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: todo.isPinned ? 6 : 4,
        shadowColor: todo.color.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isOverdue 
                ? AppConstants.errorColor 
                : isDueToday 
                    ? AppConstants.warningColor 
                    : isDueSoon 
                        ? AppConstants.accentColor 
                        : todo.color.withOpacity(0.2),
            width: isOverdue || isDueToday || isDueSoon ? 2 : 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white,
                isOverdue 
                    ? AppConstants.errorColor.withOpacity(0.05)
                    : isDueToday 
                        ? AppConstants.warningColor.withOpacity(0.05)
                        : isDueSoon 
                            ? AppConstants.accentColor.withOpacity(0.05)
                            : todo.color.withOpacity(0.05),
              ],
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Checkbox(
              value: todo.isCompleted,
              onChanged: (value) {
                todoProvider.toggleTodoStatus(todo.id);
              },
              activeColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            title: Text(
              todo.title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                color: todo.isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
            subtitle: todo.reminderDateTime != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOverdue 
                            ? AppConstants.errorColor.withOpacity(0.1)
                            : isDueToday 
                                ? AppConstants.warningColor.withOpacity(0.1)
                                : isDueSoon 
                                    ? AppConstants.accentColor.withOpacity(0.1)
                                    : app_date_utils.DateUtils.getDueDateColor(todo.reminderDateTime).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isOverdue 
                              ? AppConstants.errorColor.withOpacity(0.3)
                              : isDueToday 
                                  ? AppConstants.warningColor.withOpacity(0.3)
                              : isDueSoon 
                                  ? AppConstants.accentColor.withOpacity(0.3)
                                  : app_date_utils.DateUtils.getDueDateColor(todo.reminderDateTime).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event,
                            size: 12,
                            color: isOverdue 
                                ? AppConstants.errorColor 
                                : isDueToday 
                                    ? AppConstants.warningColor 
                                    : isDueSoon 
                                        ? AppConstants.accentColor 
                                        : app_date_utils.DateUtils.getDueDateColor(todo.reminderDateTime),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            app_date_utils.DateUtils.formatThaiDueDateRelative(todo.reminderDateTime!),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: isOverdue 
                                  ? AppConstants.errorColor 
                                  : isDueToday 
                                      ? AppConstants.warningColor 
                                      : isDueSoon 
                                          ? AppConstants.accentColor 
                                          : app_date_utils.DateUtils.getDueDateColor(todo.reminderDateTime),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
            onTap: () {
              // เมื่อกดที่รายการ Todo → ไปหน้ารายละเอียดแบบอ่านอย่างเดียว
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TodoDetailScreen(
                    todo: todo,
                    isReadOnly: true,
                  ),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // การปักหมุดเป็นรูปหมุด (ย้ายมาไว้ใน trailing)
                todo.isPinned
                    ? Icon(
                        Icons.push_pin,
                        color: isOverdue 
                            ? AppConstants.errorColor 
                            : isDueToday 
                                ? AppConstants.warningColor 
                                : isDueSoon 
                                    ? AppConstants.accentColor 
                                    : AppConstants.primaryColor,
                        size: 18,
                      )
                    : Icon(
                        Icons.push_pin_outlined,
                        color: Colors.grey.withOpacity(0.5),
                        size: 18,
                      ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => TodoDetailScreen(todo: todo),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              )),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    } else if (value == 'pin') {
                      todoProvider.togglePinStatus(todo.id);
                    } else if (value == 'color') {
                      _showColorPicker(context, todo, todoProvider);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, todo, todoProvider);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, color: AppConstants.primaryColor),
                        title: Text('แก้ไข'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'pin',
                      child: ListTile(
                        leading: Icon(
                          todo.isPinned ? Icons.push_pin : Icons.push_pin_outlined, 
                          color: AppConstants.primaryColor,
                        ),
                        title: Text(todo.isPinned ? 'เลิกปักหมุด' : 'ปักหมุด'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'color',
                      child: ListTile(
                        leading: Icon(Icons.color_lens, color: AppConstants.primaryColor),
                        title: Text('เปลี่ยนสี'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: AppConstants.errorColor),
                        title: Text('ลบ', style: TextStyle(color: AppConstants.errorColor)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const TodoDetailScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      backgroundColor: AppConstants.primaryColor,
      elevation: 4,
      child: const Icon(Icons.add, color: Colors.white),
    )
        .animate()
        .scale(duration: const Duration(milliseconds: 300))
        .then(delay: const Duration(milliseconds: 100))
        .shake();
  }

  void _showColorPicker(BuildContext context, Todo todo, TodoProvider todoProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'เลือกสี',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: 300,
          height: 200,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
            ),
            itemCount: AppConstants.predefinedColors.length,
            itemBuilder: (context, index) {
              final color = AppConstants.predefinedColors[index];
              return GestureDetector(
                onTap: () {
                  todoProvider.updateTodoColor(todo.id, color);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: todo.color == color ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.poppins(
                color: AppConstants.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Todo todo, TodoProvider todoProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'ลบ Todo',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'คุณแน่ใจหรือไม่ว่าต้องการลบ Todo นี้?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.poppins(
                color: AppConstants.primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              todoProvider.deleteTodo(todo.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'ลบ',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCompletedDialog(BuildContext context, TodoProvider todoProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'ล้างรายการที่เสร็จแล้ว',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'คุณแน่ใจหรือไม่ว่าต้องการล้างรายการที่เสร็จแล้ว ${todoProvider.completedTodos} รายการ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.poppins(
                color: AppConstants.primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              todoProvider.clearCompleted();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'ล้าง',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}