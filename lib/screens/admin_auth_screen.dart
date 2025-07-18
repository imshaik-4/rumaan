import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class AdminAuthScreen extends StatefulWidget {
  const AdminAuthScreen({super.key});

  @override
  State<AdminAuthScreen> createState() => _AdminAuthScreenState();
}

class _AdminAuthScreenState extends State<AdminAuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill admin credentials for convenience
    _usernameController.text = 'admin';
    _passwordController.text = 'admin123';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  // Handles the simplified admin login (NOT using Firebase)
  Future<void> _handleAdminLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_usernameController.text == 'admin' && _passwordController.text == 'admin123') {
      // Directly set the hardcoded admin user state
      authProvider.setHardcodedAdminUser();
      _showSuccess('Logged in as Admin!');
      // Navigate to admin dashboard
      context.go('/admin-dashboard');
    } else {
      _showError('Invalid username or password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Login', style: TextStyle(fontSize: 20.sp)),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            child: Container(
              constraints: BoxConstraints(maxWidth: 400.w),
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ruman Hotel Admin Access',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  TextField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Username (admin)',
                      prefixIcon: const Icon(Icons.person),
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    ),
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password (admin123)',
                      prefixIcon: const Icon(Icons.lock),
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    ),
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleAdminLogin,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Login as Admin', style: TextStyle(fontSize: 16.sp)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
