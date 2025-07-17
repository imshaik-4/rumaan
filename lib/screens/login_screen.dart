// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/provider/auth_provider.dart';
import 'dart:developer'; // Add this line
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  
  get dev => null;

  @override
  Widget build(BuildContext context) {
    
    dev.debugPrint('LoginScreen: Building widget tree.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Login'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40.w),
                ),
                child: Icon(
                  Icons.phone_android,
                  size: 40.w,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              SizedBox(height: 24.h),
              
              Text(
                _isOtpSent ? 'Verify Your Phone' : 'Enter Your Phone',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              SizedBox(height: 8.h),
              
              Text(
                _isOtpSent 
                  ? 'Enter the 6-digit code sent to ${_phoneController.text}'
                  : 'We\'ll send you a verification code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              
              SizedBox(height: 40.h),
              
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      if (!_isOtpSent) ...[
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: '+1234567890',
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 56.h,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading 
                                  ? null 
                                  : () => _sendOTP(context),
                                child: authProvider.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      'Send Verification Code',
                                      style: TextStyle(fontSize: 16.sp),
                                    ),
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            letterSpacing: 8.w,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Verification Code',
                            hintText: '123456',
                            counterText: '',
                          ),
                          maxLength: 6,
                        ),
                        SizedBox(height: 24.h),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 56.h,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading 
                                  ? null 
                                  : () => _verifyOTP(context),
                                child: authProvider.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      'Verify & Login',
                                      style: TextStyle(fontSize: 16.sp),
                                    ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isOtpSent = false;
                              _otpController.clear();
                            });
                          },
                          child: const Text('Change Phone Number'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24.h),
              
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20.w,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Demo Mode: Enter any phone number and use "123456" as verification code',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendOTP(BuildContext context) async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    setState(() {
      _isOtpSent = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demo: Use 123456 as verification code')),
    );
  }

  void _verifyOTP(BuildContext context) async {
    if (_otpController.text.trim() == '123456') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid code. Use 123456 for demo')),
      );
    }
  }
}