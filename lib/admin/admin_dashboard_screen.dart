import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/model/coupon.dart';
import 'package:intl/intl.dart';
import 'package:rumaan/provider/analytics_provider.dart'; // Corrected import
import 'package:rumaan/provider/auth_provider.dart';
import 'package:rumaan/provider/coupon_provider.dart';
import 'dart:developer' as dev;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _newCouponTitleController = TextEditingController();
  final _newCouponDescriptionController = TextEditingController();
  final _newCouponDiscountController = TextEditingController();
  DateTime? _newCouponValidUntil;
  CouponCategory? _newCouponCategory;
  bool _isCreatingCoupon = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    dev.log('AdminDashboardScreen: initState called.');
    // Ensure providers are loaded and listening
    Provider.of<AnalyticsProvider>(context, listen: false).analyticsData;
    Provider.of<CouponProvider>(context, listen: false).coupons;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newCouponTitleController.dispose();
    _newCouponDescriptionController.dispose();
    _newCouponDiscountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _newCouponValidUntil ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _newCouponValidUntil) {
      setState(() {
        _newCouponValidUntil = picked;
      });
    }
  }

  void _createCoupon() async {
    if (_newCouponTitleController.text.isEmpty ||
        _newCouponDiscountController.text.isEmpty ||
        _newCouponCategory == null ||
        _newCouponValidUntil == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() {
      _isCreatingCoupon = true;
    });

    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);

    final newCoupon = Coupon(
      id: FirebaseFirestore.instance.collection('coupons').doc().id, // Generate new Firestore ID
      title: _newCouponTitleController.text,
      description: _newCouponDescriptionController.text,
      discount: _newCouponDiscountController.text,
      validUntil: _newCouponValidUntil!,
      createdAt: DateTime.now(),
      qrCode: 'RH-${_newCouponCategory!.name.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      category: _newCouponCategory!,
      isUsed: false,
      isActive: true,
      usageCount: 0,
    );

    await couponProvider.addCoupon(newCoupon);
    await analyticsProvider.updateAnalytics(
      totalCouponsIncrement: 1,
      activeCouponsChange: 1,
    );

    setState(() {
      _isCreatingCoupon = false;
      _newCouponTitleController.clear();
      _newCouponDescriptionController.clear();
      _newCouponDiscountController.clear();
      _newCouponValidUntil = null;
      _newCouponCategory = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coupon created successfully!')),
    );
  }

  void _toggleCouponStatus(Coupon coupon) async {
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);

    coupon.isActive = !coupon.isActive;
    await couponProvider.updateCoupon(coupon);

    // Update analytics for active coupons count
    await analyticsProvider.updateAnalytics(
      activeCouponsChange: coupon.isActive ? 1 : -1,
      totalCouponsIncrement: 0, // Not changing total coupons, just active status
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Coupon ${coupon.title} is now ${coupon.isActive ? 'Active' : 'Inactive'}')),
    );
  }

  void _deleteCoupon(String couponId) async {
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);

    // Fetch the coupon to check its active status before deleting
    final couponToDelete = couponProvider.coupons.firstWhere((c) => c.id == couponId);

    await couponProvider.deleteCoupon(couponId);
    await analyticsProvider.updateAnalytics(
      totalCouponsIncrement: -1,
      activeCouponsChange: couponToDelete.isActive ? -1 : 0, // Only decrement active if it was active
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coupon deleted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context);
    final couponProvider = Provider.of<CouponProvider>(context);

    dev.log('AdminDashboardScreen: Building widget tree. Auth Loading: ${authProvider.isLoading}, Analytics Loading: ${analyticsProvider.isLoading}, Coupon Loading: ${couponProvider.isLoading}');

    if (authProvider.isLoading || analyticsProvider.isLoading || couponProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.userRole != UserRole.admin && authProvider.userRole != UserRole.receptionist) {
      dev.log('AdminDashboardScreen: User is not admin/receptionist. Redirecting to home.');
      // Redirect if not admin/receptionist
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return const SizedBox.shrink();
    }

    final analytics = analyticsProvider.analyticsData;
    final allCoupons = couponProvider.coupons;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel', style: TextStyle(fontSize: 20.sp)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.analytics, size: 20.w),
              text: 'Analytics',
            ),
            Tab(
              icon: Icon(Icons.card_giftcard, size: 20.w),
              text: 'Manage Coupons',
            ),
            Tab(
              icon: Icon(Icons.add_circle_outline, size: 20.w),
              text: 'Create Coupon',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.pushNamed(context, '/admin/scanner');
            },
            tooltip: 'Scan Coupon',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.signOut();
              Navigator.pushReplacementNamed(context, '/home');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Analytics Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: ScreenUtil().screenWidth > 600 ? 4 : 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  children: [
                    _buildStatCard(
                      context,
                      icon: Icons.people,
                      title: 'Total Users',
                      value: analytics.totalUsers.toString(),
                      subtitle: '+${analytics.thisWeekSignups} this week',
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      context,
                      icon: Icons.login,
                      title: 'Total Logins',
                      value: analytics.totalLogins.toString(),
                      subtitle: '${analytics.todayLogins} today',
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      icon: Icons.card_giftcard,
                      title: 'Active Coupons',
                      value: analytics.activeCoupons.toString(),
                      subtitle: '${analytics.totalCoupons} total',
                      color: Colors.amber,
                    ),
                    _buildStatCard(
                      context,
                      icon: Icons.savings,
                      title: 'Total Savings',
                      value: '\$${analytics.totalSavings.toStringAsFixed(2)}',
                      subtitle: '${analytics.usedCoupons} coupons used',
                      color: Colors.purple,
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        _buildActivityRow(context, 'Coupon Used', 'Welcome Discount - User #1234', '2 min ago'),
                        _buildActivityRow(context, 'New User Signup', 'Phone: +1234567890', '5 min ago'),
                        _buildActivityRow(context, 'Coupon Created', 'Spa Relaxation - 30% OFF', '1 hour ago'),
                        _buildActivityRow(context, 'Coupon Used', 'Room Upgrade - User #5678', '2 hours ago', isLast: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Manage Coupons Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Coupons',
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                if (allCoupons.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, size: 80.w, color: Colors.grey.shade400),
                          SizedBox(height: 16.h),
                          Text(
                            'No coupons created yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allCoupons.length,
                    itemBuilder: (context, index) {
                      final coupon = allCoupons[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      coupon.title,
                                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(coupon.category.name.toUpperCase(), style: TextStyle(fontSize: 10.sp)),
                                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                    labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                coupon.description,
                                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Discount: ${coupon.discount}', style: TextStyle(fontSize: 12.sp)),
                                        Text('Valid Until: ${DateFormat('MMM dd, yyyy').format(coupon.validUntil)}', style: TextStyle(fontSize: 12.sp)),
                                        Text('Usage: ${coupon.usageCount} times', style: TextStyle(fontSize: 12.sp)),
                                        Text('QR Code: ${coupon.qrCode}', style: TextStyle(fontSize: 12.sp)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Chip(
                                        label: Text(coupon.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 10.sp)),
                                        backgroundColor: coupon.isActive ? Colors.green.shade100 : Colors.red.shade100,
                                        labelStyle: TextStyle(color: coupon.isActive ? Colors.green.shade700 : Colors.red.shade700),
                                      ),
                                      SizedBox(height: 8.h),
                                      ElevatedButton(
                                        onPressed: () => _toggleCouponStatus(coupon),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: coupon.isActive ? Colors.red.shade600 : Colors.green.shade600,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                          textStyle: TextStyle(fontSize: 12.sp),
                                        ),
                                        child: Text(coupon.isActive ? 'Deactivate' : 'Activate'),
                                      ),
                                      SizedBox(height: 8.h),
                                      OutlinedButton(
                                        onPressed: () => _deleteCoupon(coupon.id),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.grey.shade600,
                                          side: BorderSide(color: Colors.grey.shade400),
                                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                          textStyle: TextStyle(fontSize: 12.sp),
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // Create Coupon Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Coupon',
                      style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 24.h),
                    TextFormField(
                      controller: _newCouponTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Coupon Title',
                        hintText: 'e.g., Welcome Discount',
                      ),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _newCouponDiscountController,
                      decoration: const InputDecoration(
                        labelText: 'Discount',
                        hintText: 'e.g., 20% OFF',
                      ),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _newCouponDescriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the coupon offer...',
                      ),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(height: 16.h),
                    DropdownButtonFormField<CouponCategory>(
                      value: _newCouponCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: CouponCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name.toUpperCase(), style: TextStyle(fontSize: 14.sp)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _newCouponCategory = value;
                        });
                      },
                      style: TextStyle(fontSize: 14.sp, color: Colors.black),
                    ),
                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: _newCouponValidUntil == null
                                ? ''
                                : DateFormat('MMM dd, yyyy').format(_newCouponValidUntil!),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Valid Until',
                            hintText: 'Select date',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _isCreatingCoupon ? null : _createCoupon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(fontSize: 16.sp),
                        ),
                        child: _isCreatingCoupon
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Create Coupon'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required IconData icon, required String title, required String value, String? subtitle, required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 36.w, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(BuildContext context, String action, String detail, String time, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(action, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  Text(detail, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                ],
              ),
              Text(time, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
            ],
          ),
          if (!isLast)
            Divider(height: 16.h, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}
