import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/provider/auth_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer' as dev; // Corrected import for debugPrint

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _adminTapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    dev.log('SplashScreen: initState called.');
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    dev.log('SplashScreen: _checkAuthStatus started.');

    // Wait for Firebase auth state to be determined
    // Use a listener or a more robust check if authProvider.isLoading isn't immediately accurate
    while (authProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 50)); // Small delay to allow initial state
    }
    dev.log('SplashScreen: AuthProvider finished loading. Current user: ${authProvider.currentUser?.uid}, Role: ${authProvider.userRole}');

    if (authProvider.currentUser != null) {
      if (authProvider.userRole == UserRole.admin || authProvider.userRole == UserRole.receptionist) {
        dev.log('SplashScreen: Navigating to /admin_dashboard');
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        dev.log('SplashScreen: Navigating to /customer_dashboard');
        Navigator.pushReplacementNamed(context, '/customer_dashboard');
      }
    } else {
      dev.log('SplashScreen: Navigating to /home');
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _handleAdminTap() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _adminTapCount = 1;
    } else {
      _adminTapCount++;
    }
    _lastTapTime = now;

    dev.log('Admin tap count: $_adminTapCount');
    if (_adminTapCount >= 5) {
      _adminTapCount = 0;
      dev.log('Admin taps detected. Navigating to /admin_login');
      Navigator.pushNamed(context, '/admin_login');
    }
  }

  @override
  Widget build(BuildContext context) {
    dev.log('SplashScreen: Building widget tree.');
    return Scaffold(
      body: GestureDetector(
        onTap: _handleAdminTap,
        child: Container(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hotel,
                  size: 150.w,
                  color: Colors.amber.shade800,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Ruman Hotel',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
                Text(
                  'Exclusive Coupons & Offers',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 40.h),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
