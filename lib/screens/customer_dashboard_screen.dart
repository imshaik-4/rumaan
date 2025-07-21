import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/coupon_provider.dart';
import '../models/coupon.dart';
import '../widgets/coupon_card.dart';

class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final couponProvider = Provider.of<CouponProvider>(context);

    if (!authProvider.isAuthenticated || authProvider.appUser == null) {
      // Redirect to login if not authenticated or user data not loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final availableCoupons = couponProvider.getAvailableCoupons(authProvider.appUser);
    final redeemedCoupons = couponProvider.getRedeemedCoupons(authProvider.appUser);

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${authProvider.appUser?.email ?? authProvider.appUser?.phoneNumber ?? 'Customer'}', style: TextStyle(fontSize: 20.sp)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              context.go('/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine if it's a wide screen (web) or narrow (mobile)
            bool isWideScreen = constraints.maxWidth > 600;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWideScreen ? 1200.w : double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Coupons', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: availableCoupons.isEmpty
                          ? Center(child: Text('No available coupons at the moment.', style: TextStyle(fontSize: 18.sp, color: Colors.grey[600])))
                          : GridView.builder(
                              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: isWideScreen ? 350.w : 400.w, // Max width for each card, adjusted for web
                                childAspectRatio: isWideScreen ? 1.2 : 3 / 2, // Aspect ratio of each card, adjusted for web
                                crossAxisSpacing: 20.w,
                                mainAxisSpacing: 20.h,
                              ),
                              itemCount: availableCoupons.length,
                              itemBuilder: (context, index) {
                                final coupon = availableCoupons[index];
                                return CouponCard(
                                  coupon: coupon,
                                  onRedeem: () async {
                                    await couponProvider.redeemCoupon(coupon.id, authProvider.currentUser!.uid);
                                    // No need to refresh user explicitly here, as FirestoreService updates user doc
                                    // and AuthProvider listens to changes.
                                  },
                                  isRedeemable: true,
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 32.h),
                    Text('Redeemed Coupons', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: redeemedCoupons.isEmpty
                          ? Center(child: Text('You have not redeemed any coupons yet.', style: TextStyle(fontSize: 18.sp, color: Colors.grey[600])))
                          : GridView.builder(
                              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: isWideScreen ? 350.w : 400.w,
                                childAspectRatio: isWideScreen ? 1.2 : 3 / 2,
                                crossAxisSpacing: 20.w,
                                mainAxisSpacing: 20.h,
                              ),
                              itemCount: redeemedCoupons.length,
                              itemBuilder: (context, index) {
                                final coupon = redeemedCoupons[index];
                                return CouponCard(
                                  coupon: coupon,
                                  isRedeemable: false, // Already redeemed
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
      ),
    );
  }
}
