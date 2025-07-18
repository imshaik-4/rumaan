import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Alias firebase_auth's AuthProvider
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart'; // Our custom AuthProvider

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _verificationId;
  bool _otpSent = false;
  int _adminTapCount = 0; // Counter for admin access taps

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
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

  Future<void> _verifyPhoneNumber() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Ensure the phone number is in E.164 format (e.g., +919876543210)
    String phoneNumber = _phoneController.text.trim();
    if (!phoneNumber.startsWith('+') || phoneNumber.length < 10) {
      _showError('Please enter phone number in E.164 format (e.g., +919876543210).');
      return;
    }

    await authProvider.signInWithPhoneNumber(
      phoneNumber,
      verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
        await authProvider.signInWithPhoneCredential(credential);
        _showSuccess('Phone verification completed!');
        _navigateToDashboard(authProvider);
      },
      verificationFailed: (fb_auth.FirebaseAuthException e) {
        _showError('Phone verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _otpSent = true;
        });
        _showSuccess('OTP sent to your phone!');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
        _showError('OTP auto-retrieval timed out.');
      },
    );
  }

  Future<void> _signInWithOtp() async {
    if (_verificationId == null) {
      _showError('Please verify phone number first.');
      return;
    }
    if (_otpController.text.isEmpty) {
      _showError('Please enter the OTP.');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    fb_auth.PhoneAuthCredential credential = fb_auth.PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: _otpController.text,
    );

    bool success = await authProvider.signInWithPhoneCredential(credential);
    if (success) {
      _showSuccess('Logged in successfully!');
      _navigateToDashboard(authProvider);
    } else {
      _showError('Invalid OTP or sign-in failed.');
    }
  }

  void _navigateToDashboard(AuthProvider authProvider) {
    if (authProvider.isAdmin || authProvider.isReceptionist) {
      context.go('/admin-dashboard');
    } else if (authProvider.isCustomer) {
      context.go('/customer-dashboard');
    } else {
      // Fallback for unknown roles, maybe redirect to a generic page or show error
      _showError('User role not recognized. Please contact support.');
      authProvider.signOut(); // Sign out if role is unknown
    }
  }

  void _handleAdminTap() {
    setState(() {
      _adminTapCount++;
      if (_adminTapCount >= 5) {
        _adminTapCount = 0; // Reset counter
        context.push('/admin-auth'); // Navigate to the new admin login screen
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
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
                  GestureDetector( // Wrap the title with GestureDetector for 5-tap
                    onTap: _handleAdminTap,
                    child: Text(
                      'Ruman Hotel Coupons',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Customer Login (Phone OTP)',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[700]),
                  ),
                  SizedBox(height: 24.h),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'e.g., +919876543210 (E.164 format)',
                      prefixIcon: const Icon(Icons.phone),
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    ),
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _verifyPhoneNumber,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Send OTP', style: TextStyle(fontSize: 16.sp)),
                  ),
                  if (_otpSent) ...[
                    SizedBox(height: 16.h),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'OTP',
                        prefixIcon: const Icon(Icons.vpn_key),
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                      ),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _signInWithOtp,
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Login with OTP', style: TextStyle(fontSize: 16.sp)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
