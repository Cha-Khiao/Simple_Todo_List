import 'package:flutter/material.dart' hide DateUtils;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart' as app_date_utils;
import 'todo_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.primaryColor,
              AppConstants.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with animation
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.task_alt,
                        size: 70,
                        color: Color(0xFF6750A4),
                      ),
                    )
                        .animate()
                        .scale(duration: 800.ms, curve: Curves.elasticOut)
                        .then(delay: 300.ms)
                        .rotate(begin: 0, end: 0.05, duration: 600.ms),
                    const SizedBox(height: 40),
                    
                    // App name
                    Text(
                      AppConstants.appName,
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideY(begin: 30, end: 0),
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Text(
                      'จัดการงานของคุณอย่างมีประสิทธิภาพ',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 600.ms)
                        .slideY(begin: 20, end: 0),
                    const SizedBox(height: 60),
                    
                    // Username field
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 😎,
                      child: TextFormField(
                        controller: _usernameController,
                        focusNode: _usernameFocus,
                        decoration: InputDecoration(
                          labelText: 'ชื่อผู้ใช้',
                          hintText: 'ใส่ชื่อผู้ใช้ของคุณ',
                          hintStyle: GoogleFonts.poppins(color: Colors.white70),
                          prefixIcon: const Icon(Icons.person, color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: GoogleFonts.poppins(color: Colors.white),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_passwordFocus);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'กรุณาใส่ชื่อผู้ใช้';
                          }
                          return null;
                        },
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 800.ms)
                        .slideY(begin: 30, end: 0),
                    const SizedBox(height: 16),
                    
                    // Password field
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 😎,
                      child: TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'รหัสผ่าน',
                          hintText: 'ใส่รหัสผ่านของคุณ',
                          hintStyle: GoogleFonts.poppins(color: Colors.white70),
                          prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: GoogleFonts.poppins(color: Colors.white),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'กรุณาใส่รหัสผ่าน';
                          }
                          if (value.length < 6) {
                            return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
                          }
                          return null;
                        },
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 1000.ms)
                        .slideY(begin: 30, end: 0),
                    const SizedBox(height: 24),
                    
                    // Error message
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.error != null) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 😎,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(😎,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.white),
                                const SizedBox(width: 😎,
                                Expanded(
                                  child: Text(
                                    authProvider.error!,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .shake(duration: 500.ms, delay: 200.ms);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Login button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Container(
                          width: double.infinity,
                          height: 56,
                          margin: const EdgeInsets.symmetric(horizontal: 😎,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: authProvider.isLoading ? null : _handleLogin,
                              child: Center(
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6750A4)),
                                        ),
                                      )
                                    : Text(
                                        'เริ่มต้นใช้งาน',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF6750A4),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1200.ms)
                            .slideY(begin: 30, end: 0);
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Date and time
                    Text(
                      app_date_utils.DateUtils.formatThaiDateFull(DateTime.now()),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 1400.ms),
                    
                    // Decorative elements
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        )
                            .animate()
                            .scale(duration: 600.ms, delay: 1600.ms)
                            .then(delay: 200.ms)
                            .scale(delay: 200.ms),
                        const SizedBox(width: 😎,
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                        )
                            .animate()
                            .scale(duration: 600.ms, delay: 1800.ms)
                            .then(delay: 200.ms)
                            .scale(delay: 200.ms),
                        const SizedBox(width: 😎,
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                        )
                            .animate()
                            .scale(duration: 600.ms, delay: 2000.ms)
                            .then(delay: 200.ms)
                            .scale(delay: 200.ms),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
      
      final success = await authProvider.login(
        _usernameController.text,
        _passwordController.text,
      );
      
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const TodoListScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }
} 