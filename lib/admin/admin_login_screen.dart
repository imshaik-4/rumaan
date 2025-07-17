import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/provider/auth_provider.dart';
import 'dart:developer' as dev;

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    dev.log('AdminLoginScreen: initState called.');
    // Pre-fill for demo convenience
    _idController.text = 'admin@rumanhotel';
    _passwordController.text = 'RumanAdmin2024!';
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.loginAdmin(
      _idController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      dev.log('AdminLoginScreen: Admin login successful. Navigating to dashboard.');
      Navigator.pushReplacementNamed(context, '/admin_dashboard');
    } else {
      setState(() {
        _errorMessage = 'Invalid ID or password. Please try again.';
      });
      dev.log('AdminLoginScreen: Admin login failed.');
    }
  }
  @override
  Widget build(BuildContext context) {
    dev.log('AdminLoginScreen: Building widget tree.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.indigo.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 60.w,
                      color: Colors.blue.shade700,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Admin / Receptionist Login',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter your credentials to access the admin panel.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    if (_errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    TextFormField(
                      controller: _idController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Admin ID',
                        hintText: 'admin@rumanhotel',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'RumanAdmin2024!',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Login',
                                style: TextStyle(fontSize: 16.sp),
                              ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Go back to home screen
                      },
                      child: Text(
                        'Back to Home',
                        style: TextStyle(fontSize: 14.sp),
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

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
