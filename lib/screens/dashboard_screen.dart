// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/model/coupon.dart';
import 'package:rumaan/provider/auth_provider.dart';
import 'package:rumaan/widget/coupon_card.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Coupon> coupons = [
    Coupon(
      id: '1',
      title: 'Welcome Discount',
      description: 'Get 20% off on your first dining experience at our premium restaurant',
      discount: '20% OFF',
      validUntil: DateTime(2024, 12, 31),
      isUsed: false,
      isActive: true,
      qrCode: 'RH-WELCOME-001',
      category: CouponCategory.dining,
      createdAt: DateTime(2024, 1, 1),
    ),
    Coupon(
      id: '2',
      title: 'Spa Relaxation',
      description: 'Enjoy a rejuvenating spa session with 30% discount on all treatments',
      discount: '30% OFF',
      validUntil: DateTime.parse('2024-11-30'),
      isUsed: false,
      isActive: true,
      qrCode: 'RH-SPA-002',
      category: CouponCategory.spa,
      createdAt: DateTime(2024, 2, 1),
    ),
    Coupon(
      id: '3',
      title: 'Room Upgrade',
      description: 'Free upgrade to deluxe room for your next stay (subject to availability)',
      discount: 'FREE UPGRADE',
      validUntil: DateTime.parse('2024-10-31'),
      isUsed: false,
      isActive: true,
      qrCode: 'RH-ROOM-003',
      category: CouponCategory.accommodation,
      createdAt: DateTime(2024, 3, 1),
    ),
  
  ];

  Set<String> revealedCoupons = {};

  @override
  Widget build(BuildContext context) {
    final activeCoupons = coupons.where((c) => c.isActive && !c.isUsed).toList();
    final usedCoupons = coupons.where((c) => c.isUsed).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Coupons'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
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
                    coupons.length.toString(),
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
                    isRevealed: true,
                    onReveal: () {},
                  );
                },
              ),
            ],
            
            if (coupons.isEmpty) ...[
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}