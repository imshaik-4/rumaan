import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/coupon_provider.dart';
import '../models/coupon.dart';
import '../widgets/coupon_card.dart';
import '../widgets/sidebar_item.dart'; // Import the new SidebarItem

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0; // 0: My Coupons, 1: Available Offers
  final List<Widget> _widgetOptions = const <Widget>[
    _MyCouponsTab(),
    _AvailableOffersTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isAuthenticated || authProvider.appUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    bool isWideScreen = MediaQuery.of(context).size.width > 900;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Rumaan Hotel Coupon System', style: TextStyle(fontSize: 20.sp)),
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
                    authProvider.appUser?.email?.split('@').first ?? 'Customer',
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
              color: colorScheme.background, // Use theme background color
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
                  authProvider.appUser?.email ?? 'Customer User',
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
            icon: Icons.local_activity,
            title: 'My Coupons',
            isSelected: _selectedIndex == 0,
            onTap: () {
              _onItemTapped(0);
              Navigator.pop(context);
            },
            isDrawerItem: true,
          ),
          SidebarItem(
            icon: Icons.local_offer,
            title: 'Available Offers',
            isSelected: _selectedIndex == 1,
            onTap: () {
              _onItemTapped(1);
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
      color: colorScheme.primary,
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
                ),
                Text(
                  'Coupon System',
                  style: TextStyle(
                    color: colorScheme.onPrimary.withOpacity(0.7),
                    fontSize: 16.sp,
                  ),
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
                  icon: Icons.local_activity,
                  title: 'My Coupons',
                  isSelected: _selectedIndex == 0,
                  onTap: () => _onItemTapped(0),
                ),
                SidebarItem(
                  icon: Icons.local_offer,
                  title: 'Available Offers',
                  isSelected: _selectedIndex == 1,
                  onTap: () => _onItemTapped(1),
                ),
                SidebarItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  isSelected: false, // Placeholder for settings, not a real tab yet
                  onTap: () {
                    Fluttertoast.showToast(msg: 'Settings coming soon!');
                  },
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
                        authProvider.appUser?.role.toString() ?? 'Role',
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

class _MyCouponsTab extends StatelessWidget {
  const _MyCouponsTab();
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final couponProvider = Provider.of<CouponProvider>(context);
    final redeemedCoupons = couponProvider.getRedeemedCoupons(authProvider.appUser);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWideScreen ? 1200.w : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Redeemed Coupons', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24.h),
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
                                isRedeemable: false,
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

class _AvailableOffersTab extends StatelessWidget {
  const _AvailableOffersTab();
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final couponProvider = Provider.of<CouponProvider>(context);
    final availableCoupons = couponProvider.getAvailableCoupons(authProvider.appUser);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWideScreen ? 1200.w : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available Offers', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24.h),
                  Expanded(
                    child: availableCoupons.isEmpty
                        ? Center(child: Text('No available coupons at the moment.', style: TextStyle(fontSize: 18.sp, color: Colors.grey[600])))
                        : GridView.builder(
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: isWideScreen ? 350.w : 400.w,
                              childAspectRatio: isWideScreen ? 1.2 : 3 / 2,
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
                                },
                                isRedeemable: true,
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

// Assuming this extension is defined somewhere accessible, e.g., in a utils file or directly in the main file.
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}