import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


import '../providers/auth_provider.dart';
import '../providers/coupon_provider.dart';
import '../providers/analytics_provider.dart';
import '../models/coupon.dart';
import '../widgets/barcode_display.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated || !(authProvider.isAdmin || authProvider.isReceptionist)) {
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
          tabs: [
            Tab(text: 'Analytics', icon: Icon(Icons.analytics, size: 24.sp)),
            Tab(text: 'Manage Coupons', icon: Icon(Icons.list_alt, size: 24.sp)),
            Tab(text: 'Create Coupon', icon: Icon(Icons.add_circle_outline, size: 24.sp)),
          ],
          labelStyle: TextStyle(fontSize: 16.sp),
          unselectedLabelStyle: TextStyle(fontSize: 14.sp),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AnalyticsTab(),
          _ManageCouponsTab(),
          _CreateCouponTab(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('App Usage Overview', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 24.h),
          Wrap(
            spacing: 24.w,
            runSpacing: 24.h,
            children: [
              _buildMetricCard(context, 'Total Users', analyticsProvider.totalUsers.toString(), Icons.people),
              _buildMetricCard(context, 'Active Coupons', analyticsProvider.activeCoupons.toString(), Icons.local_activity),
              // Add more metrics if implemented (e.g., Total Logins, Total Savings)
              _buildMetricCard(context, 'Total Logins', 'N/A', Icons.login), // Placeholder
              _buildMetricCard(context, 'Total Savings', 'N/A', Icons.attach_money), // Placeholder
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: 280.w,
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 48.sp, color: Colors.blueGrey[700]),
            SizedBox(height: 16.h),
            Text(title, style: TextStyle(fontSize: 18.sp, color: Colors.grey[700])),
            SizedBox(height: 8.h),
            Text(value, style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manage Existing Coupons', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 24.h),
          Expanded(
            child: allCoupons.isEmpty
                ? Center(child: Text('No coupons created yet.', style: TextStyle(fontSize: 18.sp, color: Colors.grey[600])))
                : ListView.builder(
                    itemCount: allCoupons.length,
                    itemBuilder: (context, index) {
                      final coupon = allCoupons[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(coupon.title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4.h),
                                    Text('${coupon.discount.toStringAsFixed(0)}% Off - ${coupon.category.toString().split('.').last}', style: TextStyle(fontSize: 16.sp, color: Colors.grey[700])),
                                    SizedBox(height: 4.h),
                                    Text('Valid until: ${coupon.formattedValidUntil}', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                                    SizedBox(height: 4.h),
                                    Text('Used by: ${coupon.usedBy.length} users', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Column(
                                children: [
                                  Switch(
                                    value: coupon.isActive,
                                    onChanged: (bool value) {
                                      couponProvider.updateCouponStatus(coupon, value);
                                    },
                                    activeColor: Colors.green,
                                  ),
                                  Text(coupon.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 12.sp)),
                                ],
                              ),
                              SizedBox(width: 16.w),
                              IconButton(
                                icon: Icon(Icons.barcode_reader, size: 28.sp, color: Colors.blueGrey[700]),
                                tooltip: 'Show Barcode',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Barcode for ${coupon.title}', style: TextStyle(fontSize: 20.sp)),
                                      content: BarcodeDisplay(barcodeData: coupon.barcodeData),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text('Close', style: TextStyle(fontSize: 16.sp)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: 8.w),
                              IconButton(
                                icon: Icon(Icons.delete, size: 28.sp, color: Colors.red[700]),
                                tooltip: 'Delete Coupon',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Confirm Delete', style: TextStyle(fontSize: 20.sp)),
                                      content: Text('Are you sure you want to delete "${coupon.title}"?', style: TextStyle(fontSize: 16.sp)),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text('Cancel', style: TextStyle(fontSize: 16.sp)),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            couponProvider.deleteCoupon(coupon.id);
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          child: Text('Delete', style: TextStyle(fontSize: 16.sp)),
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
  bool _isSingleUse = false; // Add this line

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
      final couponProvider = Provider.of<CouponProvider>(context, listen: false);
      await couponProvider.createCoupon(
        title: _titleController.text,
        description: _descriptionController.text,
        discount: double.parse(_discountController.text),
        category: _selectedCategory,
        validUntil: _selectedDate,
        isSingleUse: _isSingleUse, // Add this line
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create New Coupon', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 24.h),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Coupon Title',
                hintText: 'e.g., 20% Off Spa Treatment',
                contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
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
                hintText: 'e.g., Enjoy a relaxing spa session with 20% discount.',
                contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
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
                contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              ),
              style: TextStyle(fontSize: 16.sp),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a discount';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0 || double.parse(value) > 100) {
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
                contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              ),
              style: TextStyle(fontSize: 16.sp, color: Colors.black),
              items: CouponCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.toString().split('.').last.capitalize(), style: TextStyle(fontSize: 16.sp)),
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
              title: Text('Single Use Coupon', style: TextStyle(fontSize: 16.sp)),
              subtitle: Text('If checked, this coupon will expire for everyone after the first redemption.', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
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
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
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
                  child: Text('Select Date', style: TextStyle(fontSize: 16.sp)),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            Center(
              child: ElevatedButton(
                onPressed: couponProvider.isLoading ? null : _createCoupon,
                child: couponProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Create Coupon', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
