import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/provider/auth_provider.dart';
import 'dart:developer' as dev;

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _otpSent = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    dev.log('CustomerLoginScreen: initState called.');
    // Listen to auth changes to automatically navigate after successful login
    Provider.of<AuthProvider>(context, listen: false).addListener(_authProviderListener);
  }

  void _authProviderListener() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null && authProvider.userRole == UserRole.customer) {
      dev.log('CustomerLoginScreen: AuthProvider listener detected customer login. Navigating to dashboard.');
      Navigator.pushReplacementNamed(context, '/customer_dashboard');
    }
  }

  void _sendOtp() async {
    if (_phoneController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid phone number.';
      });
      return;
    }

    setState(() {
      _isSendingOtp = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = _phoneController.text.trim();
    // Ensure phone number starts with '+' for Firebase Phone Auth
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+91$phoneNumber'; // Example: Assuming India (+91)
    }

    final error = await authProvider.sendOtp(phoneNumber);
    setState(() {
      _isSendingOtp = false;
      if (error == null) {
        _otpSent = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent to $phoneNumber')),
        );
      } else {
        _errorMessage = error;
      }
    });
  }

  void _verifyOtp() async {
    if (_otpController.text.length != 6) {
      setState(() {
        _errorMessage = 'Please enter the 6-digit code.';
      });
      return;
    }

    setState(() {
      _isVerifyingOtp = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.verifyOtpAndSignIn(_otpController.text.trim());
    setState(() {
      _isVerifyingOtp = false;
      if (error != null) {
        _errorMessage = error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    dev.log('CustomerLoginScreen: Building widget tree.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Login'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade50,
              Colors.orange.shade50,
              Colors.yellow.shade50,
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
                      Icons.phone_android,
                      size: 60.w,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      _otpSent ? 'Verify OTP' : 'Login with Phone',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _otpSent
                          ? 'Enter the 6-digit code sent to ${_phoneController.text}'
                          : 'Enter your phone number to receive a verification code',
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

                    if (!_otpSent) ...[
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '+1 (555) 123-4567',
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isSendingOtp ? null : _sendOtp,
                          child: _isSendingOtp
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Send Verification Code',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                        ),
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          letterSpacing: 8.w,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Verification Code',
                          hintText: '123456',
                          prefixIcon: Icon(Icons.vpn_key),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isVerifyingOtp ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                          ),
                          child: _isVerifyingOtp
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Verify & Access Coupons',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _otpSent = false;
                            _phoneController.clear();
                            _otpController.clear();
                            _errorMessage = null;
                          });
                        },
                        child: Text(
                          'Change Phone Number',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ],
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
    Provider.of<AuthProvider>(context, listen: false).removeListener(_authProviderListener);
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
