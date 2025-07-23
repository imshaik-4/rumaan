import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../providers/auth_provider.dart';

class AdminAuthScreen extends StatefulWidget {
  const AdminAuthScreen({super.key});

  @override
  State<AdminAuthScreen> createState() => _AdminAuthScreenState();
}

class _AdminAuthScreenState extends State<AdminAuthScreen> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  int _selectedRole = 0; // 0 = Admin, 1 = Receptionist

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthState();
    
    // Pre-fill admin credentials for convenience
    _usernameController.text = 'admin';
    _passwordController.text = 'admin123';
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  void _checkAuthState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.shouldRedirectFromAuth()) {
        context.go(authProvider.getRedirectRoute());
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.red[600],
      textColor: Colors.white,
      fontSize: 16.sp,
    );
  }

  void _showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green[600],
      textColor: Colors.white,
      fontSize: 16.sp,
    );
  }

  Future<void> _handleAdminLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Validate credentials based on selected role
    bool isValidCredentials = false;
    
    if (_selectedRole == 0) {
      // Admin credentials
      isValidCredentials = _usernameController.text == 'admin' && 
                          _passwordController.text == 'admin123';
    } else {
      // Receptionist credentials (you can customize these)
      isValidCredentials = _usernameController.text == 'receptionist' && 
                          _passwordController.text == 'recep123';
    }

    if (isValidCredentials) {
      if (_selectedRole == 0) {
        authProvider.setHardcodedAdminUser();
        _showSuccess('Welcome Admin!');
      } else {
        authProvider.setHardcodedReceptionistUser();
        _showSuccess('Welcome Receptionist!');
      }
      context.go('/admin-dashboard');
    } else {
      _showError('Invalid username or password.');
    }
  }

  void _updateCredentials() {
    if (_selectedRole == 0) {
      // Admin credentials
      _usernameController.text = 'admin';
      _passwordController.text = 'admin123';
    } else {
      // Receptionist credentials
      _usernameController.text = 'receptionist';
      _passwordController.text = 'recep123';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Redirect if already authenticated
    if (authProvider.shouldRedirectFromAuth()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(authProvider.getRedirectRoute());
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: true,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple[700]!,
                Colors.deepPurple[500]!,
                Colors.purple[400]!,
              ],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Staff Login',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(width: 40.w), // Balance the back button
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.admin_panel_settings,
                              size: 48.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Rumaan Hotel',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Admin Portal',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 24.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.r),
                            topRight: Radius.circular(30.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.r),
                            topRight: Radius.circular(30.r),
                          ),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(32.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20.h),
                                Text(
                                  'Select Role',
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Choose your access level',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),

                                SizedBox(height: 24.h),

                                // Role Selection Cards
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildRoleCard(
                                        title: 'Admin',
                                        subtitle: 'Full Access',
                                        icon: Icons.admin_panel_settings,
                                        color: Colors.red,
                                        isSelected: _selectedRole == 0,
                                        onTap: () {
                                          setState(() => _selectedRole = 0);
                                          _updateCredentials();
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: _buildRoleCard(
                                        title: 'Receptionist',
                                        subtitle: 'Limited Access',
                                        icon: Icons.person_pin,
                                        color: Colors.orange,
                                        isSelected: _selectedRole == 1,
                                        onTap: () {
                                          setState(() => _selectedRole = 1);
                                          _updateCredentials();
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 32.h),

                                // Login Form
                                Text(
                                  'Login Credentials',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 16.h),

                                // Username Field
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: TextField(
                                    controller: _usernameController,
                                    style: TextStyle(fontSize: 16.sp),
                                    decoration: InputDecoration(
                                      labelText: 'Username',
                                      hintText: _selectedRole == 0 ? 'admin' : 'receptionist',
                                      prefixIcon: Container(
                                        margin: EdgeInsets.all(12.w),
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: (_selectedRole == 0 ? Colors.red : Colors.orange)[100],
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          color: (_selectedRole == 0 ? Colors.red : Colors.orange)[700],
                                          size: 20.sp,
                                        ),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 20.h,
                                        horizontal: 16.w,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 16.h),

                                // Password Field
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: TextStyle(fontSize: 16.sp),
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      hintText: _selectedRole == 0 ? 'admin123' : 'recep123',
                                      prefixIcon: Container(
                                        margin: EdgeInsets.all(12.w),
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: (_selectedRole == 0 ? Colors.red : Colors.orange)[100],
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Icon(
                                          Icons.lock,
                                          color: (_selectedRole == 0 ? Colors.red : Colors.orange)[700],
                                          size: 20.sp,
                                        ),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword 
                                              ? Icons.visibility_outlined 
                                              : Icons.visibility_off_outlined,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 20.h,
                                        horizontal: 16.w,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 24.h),

                                // Demo Credentials Info
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[50],
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: Colors.amber[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.amber[700],
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Demo Credentials',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        _selectedRole == 0 
                                            ? 'Admin: admin / admin123'
                                            : 'Receptionist: receptionist / recep123',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.amber[700],
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 32.h),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: authProvider.isLoading ? null : _handleAdminLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _selectedRole == 0 
                                          ? Colors.red[700] 
                                          : Colors.orange[700],
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 16.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: authProvider.isLoading
                                        ? SizedBox(
                                            height: 20.h,
                                            width: 20.w,
                                            child: const CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Text(
                                            'Login as ${_selectedRole == 0 ? 'Admin' : 'Receptionist'}',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),

                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[400],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                color: isSelected ? color.withOpacity(0.8) : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}