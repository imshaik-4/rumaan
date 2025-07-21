import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer' as dev;

import 'package:rumaan/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate loading time
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Wait for auth state to be fully loaded
    while (authProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    if (authProvider.isAuthenticated) {
      if (authProvider.isAdmin || authProvider.isReceptionist) {
        dev.log('Splash: User is Admin/Receptionist. Redirecting to /admin_dashboard');
        context.go('/admin_dashboard');
      } else if (authProvider.isCustomer) {
        dev.log('Splash: User is Customer. Redirecting to /customer_dashboard');
        context.go('/customer_dashboard');
      } else {
        dev.log('Splash: User role unknown. Redirecting to /home');
        context.go('/home'); // Fallback for users with no defined role
      }
    } else {
      dev.log('Splash: User not authenticated. Redirecting to /home');
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/hotel_logo.png', // Replace with your hotel logo
              width: 150.w,
              height: 150.h,
            ),
            SizedBox(height: 24.h),
            Text(
              'Rumaan Hotel Coupons',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 32.h),
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
