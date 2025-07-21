import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev; // Import for dev.log

import '../providers/auth_provider.dart'
    as AppAuthProvider; // <--- Changed this line
import '../providers/coupon_provider.dart';
import '../providers/analytics_provider.dart';
import '../models/coupon.dart';
import '../widgets/barcode_display.dart';
import 'barcode_scanner_screen.dart'; // Import the new scanner screen
import 'package:fluttertoast/fluttertoast.dart';
import 'manage_users_tab.dart'; // Import the new manage users tab

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 5, vsync: this); // Increased length for Manage Users tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider.AuthProvider>(
        context); // <--- Changed this line

    if (!authProvider.isAuthenticated ||
        !(authProvider.isAdmin || authProvider.isReceptionist)) {
      // Redirect to login if not authenticated or not admin/receptionist
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyle(fontSize: 20.sp)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              context.go('/');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable:
              true, // Make tabs scrollable for smaller screens/more tabs
          indicatorColor: Colors.white, // White indicator for professionalism
          labelColor: Colors.white, // White text for selected tab
          unselectedLabelColor: Colors.white70, // Slightly faded for unselected
          labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 14.sp),
          tabs: [
            Tab(text: 'Analytics', icon: Icon(Icons.analytics, size: 24.sp)),
            Tab(
                text: 'Manage Coupons',
                icon: Icon(Icons.list_alt, size: 24.sp)),
            Tab(
                text: 'Create Coupon',
                icon: Icon(Icons.add_circle_outline, size: 24.sp)),
            Tab(
                text: 'Scan Coupon',
                icon: Icon(Icons.qr_code_scanner, size: 24.sp)),
            Tab(
                text: 'Manage Users',
                icon: Icon(Icons.people, size: 24.sp)), // New tab
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AnalyticsTab(),
          _ManageCouponsTab(),
          _CreateCouponTab(),
          _ScanCouponTab(),
          ManageUsersTab(), // Changed from _ManageUsersTab() to ManageUsersTab()
        ],
      ),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context);
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: isWideScreen ? 900.w : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('App Usage Overview',
                      style: TextStyle(
                          fontSize: 28.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent:
                          isWideScreen ? 300.w : 400.w, // Adjusted for web
                      childAspectRatio:
                          isWideScreen ? 1.0 : 1.2, // Adjusted for web
                      crossAxisSpacing: 24.w,
                      mainAxisSpacing: 24.h,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return _buildMetricCard(
                              context,
                              'Total Users',
                              analyticsProvider.totalUsers.toString(),
                              Icons.people);
                        case 1:
                          return _buildMetricCard(
                              context,
                              'Active Coupons',
                              analyticsProvider.activeCoupons.toString(),
                              Icons.local_activity);
                        case 2:
                          return _buildMetricCard(context, 'Total Logins',
                              'N/A', Icons.login); // Placeholder
                        case 3:
                          return _buildMetricCard(context, 'Total Savings',
                              'N/A', Icons.attach_money); // Placeholder
                        default:
                          return Container();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
      BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 48.sp, color: Colors.blueGrey[700]),
            SizedBox(height: 16.h),
            Text(title,
                style: TextStyle(fontSize: 18.sp, color: Colors.grey[700])),
            SizedBox(height: 8.h),
            Text(value,
                style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ManageCouponsTab extends StatelessWidget {
  const _ManageCouponsTab();

  @override
  Widget build(BuildContext context) {
    final couponProvider = Provider.of<CouponProvider>(context);
    final allCoupons = couponProvider.allCoupons;

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: isWideScreen ? 1000.w : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Manage Existing Coupons',
                      style: TextStyle(
                          fontSize: 28.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24.h),
                  Expanded(
                    child: allCoupons.isEmpty
                        ? Center(
                            child: Text('No coupons created yet.',
                                style: TextStyle(
                                    fontSize: 18.sp, color: Colors.grey[600])))
                        : ListView.builder(
                            itemCount: allCoupons.length,
                            itemBuilder: (context, index) {
                              final coupon = allCoupons[index];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 8.h, horizontal: 4.w),
                                elevation: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(coupon.title,
                                                style: TextStyle(
                                                    fontSize: 20.sp,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(height: 4.h),
                                            Text(
                                                '${coupon.discount.toStringAsFixed(0)}% Off - ${coupon.category.toString().split('.').last.capitalize()}',
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: Colors.grey[700])),
                                            SizedBox(height: 4.h),
                                            Text(
                                                'Valid until: ${coupon.formattedValidUntil}',
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: Colors.grey[600])),
                                            SizedBox(height: 4.h),
                                            Text(
                                                'Used by: ${coupon.usedBy.length} users',
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: Colors.grey[600])),
                                            SizedBox(height: 4.h),
                                            Text(
                                                'Single Use: ${coupon.isSingleUse ? 'Yes' : 'No'}',
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: Colors.grey[600])),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Column(
                                        children: [
                                          Switch(
                                            value: coupon.isActive,
                                            onChanged: (bool value) {
                                              couponProvider.updateCouponStatus(
                                                  coupon, value);
                                            },
                                            activeColor: Colors.green,
                                          ),
                                          Text(
                                              coupon.isActive
                                                  ? 'Active'
                                                  : 'Inactive',
                                              style:
                                                  TextStyle(fontSize: 12.sp)),
                                        ],
                                      ),
                                      SizedBox(width: 16.w),
                                      IconButton(
                                        icon: Icon(Icons.barcode_reader,
                                            size: 28.sp,
                                            color: Colors.blueGrey[700]),
                                        tooltip: 'Show Barcode',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(
                                                  'Barcode for ${coupon.title}',
                                                  style: TextStyle(
                                                      fontSize: 20.sp)),
                                              content: BarcodeDisplay(
                                                  barcodeData:
                                                      coupon.barcodeData),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: Text('Close',
                                                      style: TextStyle(
                                                          fontSize: 16.sp)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(width: 8.w),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            size: 28.sp,
                                            color: Colors.red[700]),
                                        tooltip: 'Delete Coupon',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Confirm Delete',
                                                  style: TextStyle(
                                                      fontSize: 20.sp)),
                                              content: Text(
                                                  'Are you sure you want to delete "${coupon.title}"?',
                                                  style: TextStyle(
                                                      fontSize: 16.sp)),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: Text('Cancel',
                                                      style: TextStyle(
                                                          fontSize: 16.sp)),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    couponProvider.deleteCoupon(
                                                        coupon.id);
                                                    Navigator.of(context).pop();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red),
                                                  child: Text('Delete',
                                                      style: TextStyle(
                                                          fontSize: 16.sp)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
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

class _CreateCouponTab extends StatefulWidget {
  const _CreateCouponTab();

  @override
  State<_CreateCouponTab> createState() => _CreateCouponTabState();
}

class _CreateCouponTabState extends State<_CreateCouponTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  CouponCategory _selectedCategory = CouponCategory.food;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _isSingleUse = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _createCoupon() async {
    if (_formKey.currentState!.validate()) {
      final couponProvider =
          Provider.of<CouponProvider>(context, listen: false);
      final authProvider = Provider.of<AppAuthProvider.AuthProvider>(context,
          listen: false); // <--- Changed this line

      final String? currentUserId = authProvider.appUser?.uid;
      dev.log(
          'DEBUG: _CreateCouponTabState - Attempting to create coupon with createdByUid: $currentUserId'); // Added logging

      await couponProvider.createCoupon(
        title: _titleController.text,
        description: _descriptionController.text,
        discount: double.parse(_discountController.text),
        category: _selectedCategory,
        validUntil: _selectedDate,
        isSingleUse: _isSingleUse,
        createdByUid: currentUserId, // Pass the current user's UID
      );
      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      _discountController.clear();
      setState(() {
        _selectedCategory = CouponCategory.food;
        _selectedDate = DateTime.now().add(const Duration(days: 30));
        _isSingleUse = false; // Reset single use checkbox
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final couponProvider = Provider.of<CouponProvider>(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: 600.w), // Max width for form on web
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create New Coupon',
                    style: TextStyle(
                        fontSize: 28.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 24.h),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Coupon Title',
                    hintText: 'e.g., 20% Off Spa Treatment',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText:
                        'e.g., Enjoy a relaxing spa session with 20% discount.',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Discount Percentage (%)',
                    hintText: 'e.g., 20',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a discount';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0 ||
                        double.parse(value) > 100) {
                      return 'Please enter a valid percentage (1-100)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<CouponCategory>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  ),
                  style: TextStyle(fontSize: 16.sp, color: Colors.black),
                  items: CouponCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                          category.toString().split('.').last.capitalize(),
                          style: TextStyle(fontSize: 16.sp)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                SizedBox(height: 16.h),
                CheckboxListTile(
                  title: Text('Single Use Coupon',
                      style: TextStyle(fontSize: 16.sp)),
                  subtitle: Text(
                      'If checked, this coupon will expire for everyone after the first redemption.',
                      style:
                          TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                  value: _isSingleUse,
                  onChanged: (bool? value) {
                    setState(() {
                      _isSingleUse = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Valid Until',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.h, horizontal: 16.w),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: Text('Select Date',
                          style: TextStyle(fontSize: 16.sp)),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                Center(
                  child: ElevatedButton(
                    onPressed: couponProvider.isLoading ? null : _createCoupon,
                    child: couponProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Create Coupon',
                            style: TextStyle(fontSize: 18.sp)),
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

class _ScanCouponTab extends StatefulWidget {
  const _ScanCouponTab({super.key});

  @override
  State<_ScanCouponTab> createState() => _ScanCouponTabState();
}

class _ScanCouponTabState extends State<_ScanCouponTab> {
  String? _scannedBarcodeData;
  Coupon? _foundCoupon;
  final TextEditingController _userIdController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  void _handleScanResult(String barcodeData) {
    setState(() {
      _scannedBarcodeData = barcodeData;
      _foundCoupon = Provider.of<CouponProvider>(context, listen: false)
          .getCouponByBarcodeData(barcodeData);
    });
  }

  void _redeemScannedCoupon() async {
    if (_foundCoupon != null && _userIdController.text.isNotEmpty) {
      final couponProvider =
          Provider.of<CouponProvider>(context, listen: false);
      await couponProvider.redeemCoupon(
          _foundCoupon!.id, _userIdController.text.trim());
      // Clear state after redemption attempt
      setState(() {
        _scannedBarcodeData = null;
        _foundCoupon = null;
        _userIdController.clear();
      });
    } else if (_userIdController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a User ID to redeem.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider.AuthProvider>(
        context); // <--- Changed this line
    final couponProvider = Provider.of<CouponProvider>(context);

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: 600.w), // Max width for content on web
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text('Scan Coupon for Redemption',
                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () async {
                // Navigate to the scanner screen and wait for a result
                final result = await context.push<String>('/barcode_scanner');
                if (result != null) {
                  _handleScanResult(result);
                }
              },
              icon: Icon(Icons.qr_code_scanner, size: 24.sp),
              label: Text('Open Barcode Scanner',
                  style: TextStyle(fontSize: 18.sp)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
              ),
            ),
            SizedBox(height: 32.h),
            if (_scannedBarcodeData != null) ...[
              Text('Scanned Barcode Data:',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Text(_scannedBarcodeData!,
                  style:
                      TextStyle(fontSize: 16.sp, color: Colors.blueGrey[700])),
              SizedBox(height: 24.h),
              if (_foundCoupon != null) ...[
                Text('Found Coupon:',
                    style: TextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Card(
                  elevation: 4,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_foundCoupon!.title,
                            style: TextStyle(
                                fontSize: 20.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        Text(
                            '${_foundCoupon!.discount.toStringAsFixed(0)}% Off - ${_foundCoupon!.category.toString().split('.').last.capitalize()}',
                            style: TextStyle(
                                fontSize: 16.sp, color: Colors.grey[700])),
                        SizedBox(height: 4.h),
                        Text(
                            'Valid until: ${_foundCoupon!.formattedValidUntil}',
                            style: TextStyle(
                                fontSize: 14.sp, color: Colors.grey[600])),
                        SizedBox(height: 4.h),
                        Text('Active: ${_foundCoupon!.isActive ? 'Yes' : 'No'}',
                            style: TextStyle(
                                fontSize: 14.sp, color: Colors.grey[600])),
                        SizedBox(height: 4.h),
                        Text(
                            'Single Use: ${_foundCoupon!.isSingleUse ? 'Yes' : 'No'}',
                            style: TextStyle(
                                fontSize: 14.sp, color: Colors.grey[600])),
                        SizedBox(height: 4.h),
                        Text('Used by: ${_foundCoupon!.usedBy.length} users',
                            style: TextStyle(
                                fontSize: 14.sp, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                TextFormField(
                  controller: _userIdController,
                  decoration: InputDecoration(
                    labelText: 'User ID (UID) to redeem for',
                    hintText: 'e.g., Firebase user UID',
                    prefixIcon: Icon(Icons.person),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed:
                      couponProvider.isLoading ? null : _redeemScannedCoupon,
                  icon: Icon(Icons.check_circle, size: 24.sp),
                  label: couponProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Redeem Coupon',
                          style: TextStyle(fontSize: 18.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                  ),
                ),
              ] else ...[
                Text(
                  'No coupon found for this barcode data.',
                  style: TextStyle(fontSize: 18.sp, color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ]),
        ),
      ),
    );
  }
}
