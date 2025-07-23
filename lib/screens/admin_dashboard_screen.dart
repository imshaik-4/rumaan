import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev;

import '../providers/auth_provider.dart';
import '../providers/coupon_provider.dart';
import '../providers/analytics_provider.dart';
import '../models/coupon.dart';
import '../widgets/barcode_display.dart';
import '../widgets/sidebar_item.dart'; // Import the new SidebarItem
import '../widgets/metric_card.dart'; // Import the new MetricCard
import 'barcode_scanner_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'manage_users_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0; // 0: Dashboard, 1: Analytics, 2: User Management, 3: Create Coupon, 4: Manage Coupons, 5: Scan Coupon, 6: Settings
  final List<Widget> _widgetOptions = const <Widget>[
    _DashboardTab(),
    _AnalyticsTab(),
    ManageUsersTab(),
    _CreateCouponTab(),
    _ManageCouponsTab(),
    _ScanCouponTab(),
    _SettingsTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isAuthenticated || !(authProvider.isAdmin || authProvider.isReceptionist)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    bool isWideScreen = MediaQuery.of(context).size.width > 900;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rumaan Hotel',
          style: TextStyle(fontSize: 20.sp),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await authProvider.signOut();
                context.go('/');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'profile',
                child: Text('Profile', style: TextStyle(fontSize: 16.sp)),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings', style: TextStyle(fontSize: 16.sp)),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout', style: TextStyle(fontSize: 16.sp)),
              ),
            ],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.onPrimary,
                    child: Icon(Icons.person, color: colorScheme.primary),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    authProvider.appUser?.email?.split('@').first ?? 'Admin',
                    style: TextStyle(fontSize: 16.sp, color: colorScheme.onPrimary),
                  ),
                  Icon(Icons.arrow_drop_down, color: colorScheme.onPrimary),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: isWideScreen ? null : _buildDrawer(context, authProvider),
      body: Row(
        children: [
          if (isWideScreen) _buildSidebar(context, authProvider),
          Expanded(
            child: Container(
              color: colorScheme.surface, // Use theme background color
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: colorScheme.onPrimary,
                  child: Icon(Icons.person, size: 40.sp, color: colorScheme.primary),
                ),
                SizedBox(height: 8.h),
                Text(
                  authProvider.appUser?.email ?? 'Admin User',
                  style: TextStyle(color: colorScheme.onPrimary, fontSize: 18.sp),
                ),
                Text(
                  authProvider.appUser?.role.toString() ?? 'Role',
                  style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7), fontSize: 14.sp),
                ),
              ],
            ),
          ),
          SidebarItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            isSelected: _selectedIndex == 0,
            onTap: () {
              _onItemTapped(0);
              Navigator.pop(context);
            },
            isDrawerItem: true,
          ),
          SidebarItem(
            icon: Icons.analytics,
            title: 'Analytics',
            isSelected: _selectedIndex == 1,
            onTap: () {
              _onItemTapped(1);
              Navigator.pop(context);
            },
            isDrawerItem: true,
          ),
          SidebarItem(
            icon: Icons.people,
            title: 'User Management',
            isSelected: _selectedIndex == 2,
            onTap: () {
              _onItemTapped(2);
              Navigator.pop(context);
            },
            badgeCount: 24, // Example badge
            isDrawerItem: true,
          ),
          SidebarItem(
            icon: Icons.add_circle_outline,
            title: 'Create Coupon',
            isSelected: _selectedIndex == 3,
            onTap: () {
              _onItemTapped(3);
              Navigator.pop(context);
            },
            isDrawerItem: true,
          ),
          SidebarItem(
            icon: Icons.list_alt,
            title: 'Manage Coupons',
            isSelected: _selectedIndex == 4,
            onTap: () {
              _onItemTapped(4);
              Navigator.pop(context);
            },
            isDrawerItem: true,
          ),
          SidebarItem(
            icon: Icons.qr_code_scanner,
            title: 'Scan Coupon',
            isSelected: _selectedIndex == 5,
            onTap: () {
              _onItemTapped(5);
              Navigator.pop(context);
            },
            isDrawerItem: true,
          ),
          SidebarItem(
            icon: Icons.settings,
            title: 'Settings',
            isSelected: _selectedIndex == 6,
            onTap: () {
              _onItemTapped(6);
              Navigator.pop(context);
            },
            isDrawerItem: true,
          ),
          Divider(height: 1.h, color: colorScheme.outline),
          ListTile(
            leading: Icon(Icons.logout, size: 24.sp, color: Colors.red[700]),
            title: Text('Logout', style: TextStyle(fontSize: 16.sp, color: Colors.red[700])),
            onTap: () async {
              Navigator.pop(context);
              await authProvider.signOut();
              context.go('/');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AuthProvider authProvider) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 250.w,
      color: colorScheme.primary, // Darker background for sidebar
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rumaan Hotel',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  'Coupon System',
                  style: TextStyle(
                    color: colorScheme.onPrimary.withOpacity(0.7),
                    fontSize: 16.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Divider(color: colorScheme.onPrimary.withOpacity(0.3), height: 1.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SidebarItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  isSelected: _selectedIndex == 0,
                  onTap: () => _onItemTapped(0),
                ),
                SidebarItem(
                  icon: Icons.analytics,
                  title: 'Analytics',
                  isSelected: _selectedIndex == 1,
                  onTap: () => _onItemTapped(1),
                ),
                SidebarItem(
                  icon: Icons.people,
                  title: 'User Management',
                  isSelected: _selectedIndex == 2,
                  onTap: () => _onItemTapped(2),
                  badgeCount: 24, // Example badge
                ),
                SidebarItem(
                  icon: Icons.add_circle_outline,
                  title: 'Create Coupon',
                  isSelected: _selectedIndex == 3,
                  onTap: () => _onItemTapped(3),
                ),
                SidebarItem(
                  icon: Icons.list_alt,
                  title: 'Manage Coupons',
                  isSelected: _selectedIndex == 4,
                  onTap: () => _onItemTapped(4),
                ),
                SidebarItem(
                  icon: Icons.qr_code_scanner,
                  title: 'Scan Coupon',
                  isSelected: _selectedIndex == 5,
                  onTap: () => _onItemTapped(5),
                ),
                SidebarItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  isSelected: _selectedIndex == 6,
                  onTap: () => _onItemTapped(6),
                ),
              ],
            ),
          ),
          Divider(color: colorScheme.onPrimary.withOpacity(0.3), height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.onPrimary,
                  child: Icon(Icons.person, color: colorScheme.primary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.appUser?.email?.split('@').first ?? 'John Doe',
                        style: TextStyle(color: colorScheme.onPrimary, fontSize: 16.sp, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        authProvider.appUser?.role.toString()?? 'Role',
                        style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7), fontSize: 14.sp),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_up, color: colorScheme.onPrimary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 80.sp, color: colorScheme.onSurface.withOpacity(0.4)),
          SizedBox(height: 16.h),
          Text(
            'Dashboard Overview (Coming Soon!)',
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Your key metrics and quick actions will appear here.',
            style: TextStyle(fontSize: 16.sp, color: colorScheme.onSurface.withOpacity(0.5)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 80.sp, color: colorScheme.onSurface.withOpacity(0.4)),
          SizedBox(height: 16.h),
          Text(
            'Settings (Coming Soon!)',
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Manage your application settings here.',
            style: TextStyle(fontSize: 16.sp, color: colorScheme.onSurface.withOpacity(0.5)),
            textAlign: TextAlign.center,
          ),
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWideScreen ? 900.w : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('App Usage Overview', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: isWideScreen ? 300.w : 400.w,
                      childAspectRatio: isWideScreen ? 1.0 : 1.2,
                      crossAxisSpacing: 24.w,
                      mainAxisSpacing: 24.h,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return MetricCard(
                            title: 'Total Users',
                            value: analyticsProvider.totalUsers.toString(),
                            icon: Icons.people, trend: '', color: Colors.blue,
                          );
                        case 1:
                          return MetricCard(
                            title: 'Active Coupons',
                            value: analyticsProvider.activeCoupons.toString(),
                            icon: Icons.local_activity,  trend: '',  color: Colors.blue,
                          );
                        case 2:
                          return MetricCard(
                            title: 'Total Logins',
                            value: 'N/A', // Placeholder
                            icon: Icons.login, color: Colors.blue, trend: '',
                          );
                        case 3:
                          return MetricCard(
                            title: 'Total Savings',
                            value: 'N/A', // Placeholder
                            icon: Icons.attach_money, color: Colors.blue, trend: '',
                          );
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
}

class _ManageCouponsTab extends StatelessWidget {
  const _ManageCouponsTab();
  @override
  Widget build(BuildContext context) {
    final couponProvider = Provider.of<CouponProvider>(context);
    final allCoupons = couponProvider.allCoupons;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
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
                  Text('Manage Existing Coupons', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24.h),
                  allCoupons.isEmpty
                      ? Center(child: Text('No coupons created yet.', style: TextStyle(fontSize: 18.sp, color: Colors.grey[600])))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: allCoupons.length,
                          itemBuilder: (context, index) {
                            final coupon = allCoupons[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                              // Card theme is applied globally, no need for elevation/shape here
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(coupon.title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                                          SizedBox(height: 4.h),
                                          Text(
                                            '${coupon.discount.toStringAsFixed(0)}% Off - ${coupon.category.toString().split('.').last}',
                                            style: TextStyle(fontSize: 16.sp, color: colorScheme.onSurface.withOpacity(0.7)),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text('Valid until: ${coupon.formattedValidUntil}', style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface.withOpacity(0.6))),
                                          SizedBox(height: 4.h),
                                          Text('Used by: ${coupon.usedBy.length} users', style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface.withOpacity(0.6))),
                                          SizedBox(height: 4.h),
                                          Text('Single Use: ${coupon.isSingleUse ? 'Yes' : 'No'}', style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface.withOpacity(0.6))),
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
                                        Text(coupon.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 12.sp, color: colorScheme.onSurface.withOpacity(0.7))),
                                      ],
                                    ),
                                    SizedBox(width: 16.w),
                                    IconButton(
                                      icon: Icon(Icons.qr_code_2, size: 28.sp, color: colorScheme.primary), // Changed to qr_code_2 for better icon
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
                                      icon: Icon(Icons.delete_outline, size: 28.sp, color: colorScheme.error), // Changed to delete_outline
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
                                                style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error),
                                                child: Text('Delete', style: TextStyle(fontSize: 16.sp, color: colorScheme.onError)),
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
      final couponProvider = Provider.of<CouponProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String? currentUserId = authProvider.appUser?.uid;
      dev.log('DEBUG: _CreateCouponTabState - Attempting to create coupon with createdByUid: $currentUserId');
      await couponProvider.createCoupon(
        title: _titleController.text,
        description: _descriptionController.text,
        discount: double.parse(_discountController.text),
        category: _selectedCategory,
        validUntil: _selectedDate,
        isSingleUse: _isSingleUse,
        createdByUid: currentUserId,
      );
      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      _discountController.clear();
      setState(() {
        _selectedCategory = CouponCategory.food;
        _selectedDate = DateTime.now().add(const Duration(days: 30));
        _isSingleUse = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final couponProvider = Provider.of<CouponProvider>(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600.w),
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
                  ),
                  style: TextStyle(fontSize: 16.sp, color: colorScheme.onSurface),
                  items: CouponCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.toString(), style: TextStyle(fontSize: 16.sp)),
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
                          filled: true,
                          fillColor: colorScheme.surface, // Use surface color for display
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: colorScheme.outline, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: colorScheme.outline, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: colorScheme.secondary, width: 2),
                          ),
                        ),
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: TextStyle(fontSize: 16.sp, color: colorScheme.onSurface),
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
                        ? CircularProgressIndicator(color: colorScheme.onPrimary)
                        : Text('Create Coupon', style: TextStyle(fontSize: 18.sp)),
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
  const _ScanCouponTab();
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
      _foundCoupon = Provider.of<CouponProvider>(context, listen: false).getCouponByBarcodeData(barcodeData);
    });
  }

  void _redeemScannedCoupon() async {
    if (_foundCoupon != null && _userIdController.text.isNotEmpty) {
      final couponProvider = Provider.of<CouponProvider>(context, listen: false);
      await couponProvider.redeemCoupon(_foundCoupon!.id, _userIdController.text.trim());
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
    final couponProvider = Provider.of<CouponProvider>(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Scan Coupon for Redemption', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await context.push<String>('/barcode_scanner');
                  if (result != null) {
                    _handleScanResult(result);
                  }
                },
                icon: Icon(Icons.qr_code_scanner, size: 24.sp),
                label: Text('Open Barcode Scanner', style: TextStyle(fontSize: 18.sp)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                ),
              ),
              SizedBox(height: 32.h),
              if (_scannedBarcodeData != null) ...[
                Text('Scanned Barcode Data:', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Text(_scannedBarcodeData!, style: TextStyle(fontSize: 16.sp, color: colorScheme.primary)),
                SizedBox(height: 24.h),
                if (_foundCoupon != null) ...[
                  Text('Found Coupon:', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Card(
                    // Card theme is applied globally
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_foundCoupon!.title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                          SizedBox(height: 4.h),
                          Text(
                            '${_foundCoupon!.discount.toStringAsFixed(0)}% Off - ${_foundCoupon!.category.toString().split('.').last}',
                            style: TextStyle(fontSize: 16.sp, color: colorScheme.onSurface.withOpacity(0.7)),
                          ),
                          SizedBox(height: 4.h),
                          Text('Valid until: ${_foundCoupon!.formattedValidUntil}', style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface.withOpacity(0.6))),
                          SizedBox(height: 4.h),
                          Text('Active: ${_foundCoupon!.isActive ? 'Yes' : 'No'}', style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface.withOpacity(0.6))),
                          SizedBox(height: 4.h),
                          Text('Single Use: ${_foundCoupon!.isSingleUse ? 'Yes' : 'No'}', style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface.withOpacity(0.6))),
                          SizedBox(height: 4.h),
                          Text('Used by: ${_foundCoupon!.usedBy.length} users', style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface.withOpacity(0.6))),
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
                      prefixIcon: Icon(Icons.person, color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: couponProvider.isLoading ? null : _redeemScannedCoupon,
                    icon: Icon(Icons.check_circle, size: 24.sp),
                    label: couponProvider.isLoading
                        ? CircularProgressIndicator(color: colorScheme.onPrimary)
                        : Text('Redeem Coupon', style: TextStyle(fontSize: 18.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                    ),
                  ),
                ] else ...[
                  Text(
                    'No coupon found for this barcode data.',
                    style: TextStyle(fontSize: 18.sp, color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Assuming this extension is defined somewhere accessible, e.g., in a utils file or directly in the main file.
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}