import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/firestore_service.dart';

import '../models/app_user.dart';
import '../providers/coupon_provider.dart'; // To get coupon titles

class ManageUsersTab extends StatelessWidget { // Changed from _ManageUsersTab to ManageUsersTab
  const ManageUsersTab({super.key}); // Added super.key

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final couponProvider = Provider.of<CouponProvider>(context);

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWideScreen ? 1000.w : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Manage Users', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24.h),
                  Expanded(
                    child: StreamBuilder<List<AppUser>>(
                      stream: firestoreService.getAllUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 16.sp, color: Colors.red)));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('No users found.', style: TextStyle(fontSize: 18.sp, color: Colors.grey[600])));
                        }

                        final users = snapshot.data!;
                        return ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                              elevation: 2,
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.email ?? user.phoneNumber ?? 'User ID: ${user.uid}',
                                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text('Role: ${user.role.toString().split('.').last.capitalize()}', style: TextStyle(fontSize: 16.sp, color: Colors.grey[700])),
                                    SizedBox(height: 8.h),
                                    Text('Redeemed Coupons (${user.redeemedCoupons.length}):', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4.h),
                                    if (user.redeemedCoupons.isEmpty)
                                      Text('No coupons redeemed.', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]))
                                    else
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: user.redeemedCoupons.map((couponId) {
                                          final redeemedCoupon = couponProvider.allCoupons.firstWhere(
                                            (coupon) => coupon.id == couponId,
                                            orElse: () => null!, // Handle case where coupon might not be found
                                          );
                                          return Padding(
                                            padding: EdgeInsets.only(left: 8.w, bottom: 2.h),
                                            child: Text(
                                              redeemedCoupon != null ? '- ${redeemedCoupon.title}' : '- Unknown Coupon (ID: $couponId)',
                                              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
