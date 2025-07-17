import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/provider/auth_provider.dart';
import 'dart:developer' as dev; // Corrected import for debugPrint

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    dev.log('HomeScreen: Building widget tree. IsAuthenticated: ${authProvider.isAuthenticated}, UserRole: ${authProvider.userRole}');

    // Use a Consumer to react to changes in authProvider.isLoading
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isLoading) {
          dev.log('HomeScreen: AuthProvider is still loading. Showing CircularProgressIndicator.');
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (auth.isAuthenticated) {
          dev.log('HomeScreen: User is authenticated. Redirecting based on role.');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (auth.userRole == UserRole.customer) {
              Navigator.pushReplacementNamed(context, '/customer_dashboard');
            } else if (auth.userRole == UserRole.admin || auth.userRole == UserRole.receptionist) {
              Navigator.pushReplacementNamed(context, '/admin_dashboard');
            } else {
              // Fallback for unknown role, maybe show an error or default to customer
              dev.log('HomeScreen: Authenticated user with unknown role. Defaulting to customer dashboard.');
              Navigator.pushReplacementNamed(context, '/customer_dashboard');
            }
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        dev.log('HomeScreen: User is not authenticated. Showing login options.');
        return Scaffold(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hotel,
                          size: 60.w,
                          color: Colors.amber.shade700,
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ruman Hotel',
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              'Luxury & Comfort Redefined',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.amber.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) => Icon(
                        Icons.star,
                        size: 24.w,
                        color: Colors.amber.shade500,
                      )),
                    ),

                    SizedBox(height: 32.h),

                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              size: 48.w,
                              color: Colors.amber.shade700,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Exclusive Coupons Await!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Dear valued guest, we\'re delighted to offer you exclusive discounts and special offers. Choose your login method below.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/customer_login');
                        },
                        icon: Icon(Icons.phone_android, size: 24.w),
                        label: Text(
                          'Login as Customer',
                          style: TextStyle(fontSize: 18.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/admin_login');
                        },
                        icon: Icon(Icons.admin_panel_settings, size: 24.w),
                        label: Text(
                          'Login as Admin/Receptionist',
                          style: TextStyle(fontSize: 18.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue.shade600,
                          side: BorderSide(color: Colors.blue.shade600, width: 2.w),
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    Card(
                      elevation: 2,
                      color: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: Colors.blue.shade200, width: 1.w),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 24.w,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Demo Mode',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'For customer login, enter any phone number and use any 6-digit code. For admin, use ID: admin@rumanhotel, Pass: RumanAdmin2024!',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
