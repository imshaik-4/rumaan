import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/model/coupon.dart';
import 'package:rumaan/provider/auth_provider.dart';
import 'package:rumaan/provider/coupon_provider.dart';
import 'package:rumaan/widget/coupon_card.dart';

import 'package:rumaan/screens/home_screen.dart'; // For logout navigation
import 'dart:developer' as dev;

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  Set<String> revealedCoupons = {};

  @override
  void initState() {
    super.initState();
    dev.log('CustomerDashboardScreen: initState called.');
    // Ensure coupons are fetched when dashboard loads
    Provider.of<CouponProvider>(context, listen: false).coupons;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final couponProvider = Provider.of<CouponProvider>(context);

    dev.log('CustomerDashboardScreen: Building widget tree. Auth Loading: ${authProvider.isLoading}, Coupon Loading: ${couponProvider.isLoading}');

    if (authProvider.isLoading || couponProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Redirect if not authenticated or not a customer
    if (!authProvider.isAuthenticated || authProvider.userRole != UserRole.customer) {
      dev.log('CustomerDashboardScreen: User not authenticated or not customer. Redirecting to home.');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return const SizedBox.shrink();
    }

    final allCoupons = couponProvider.coupons;
    final activeCoupons = allCoupons.where((c) => c.isActive && !c.isUsed).toList();
    final usedCoupons = allCoupons.where((c) => c.isUsed).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Coupons'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger a re-fetch of coupons
          await couponProvider.coupons; // Accessing getter triggers the stream
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          physics: const AlwaysScrollableScrollPhysics(), // Make it always scrollable for RefreshIndicator
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30.w),
                        ),
                        child: Icon(
                          Icons.hotel,
                          size: 30.w,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to Ruman Hotel!',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Here are your exclusive coupons',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Active',
                      activeCoupons.length.toString(),
                      Icons.local_offer,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      'Used',
                      usedCoupons.length.toString(),
                      Icons.check_circle,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      allCoupons.length.toString(),
                      Icons.card_giftcard,
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Active Coupons
              if (activeCoupons.isNotEmpty) ...[
                Text(
                  'Available Coupons',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeCoupons.length,
                  itemBuilder: (context, index) {
                    final coupon = activeCoupons[index];
                    return CouponCard(
                      coupon: coupon,
                      isRevealed: revealedCoupons.contains(coupon.id),
                      onReveal: () {
                        setState(() {
                          revealedCoupons.add(coupon.id);
                        });
                      },
                    );
                  },
                ),
              ],

              // Used Coupons
              if (usedCoupons.isNotEmpty) ...[
                SizedBox(height: 24.h),
                Text(
                  'Used Coupons',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: usedCoupons.length,
                  itemBuilder: (context, index) {
                    final coupon = usedCoupons[index];
                    return CouponCard(
                      coupon: coupon,
                      isRevealed: true, // Always revealed for used coupons
                      onReveal: () {}, // No action for used coupons
                    );
                  },
                ),
              ],

              if (allCoupons.isEmpty) ...[
                SizedBox(height: 100.h),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 80.w,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No Coupons Available',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Check back later for new exclusive offers!',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.w),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).signOut();
                // Navigate to home screen and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
