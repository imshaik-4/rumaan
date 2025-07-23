// customer_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui'; // For ImageFilter.blur
import 'package:intl/intl.dart'; // For DateFormat

import '../providers/auth_provider.dart';
import '../providers/coupon_provider.dart';
import '../models/coupon.dart'; // Ensure CouponCategory enum is here
import '../models/app_user.dart'; // <--- ADDED: Explicit import for AppUser
import '../widgets/sidebar_item.dart';
// import '../widgets/barcode_display.dart'; // Not directly needed in customer view for now

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Widget options are now defined late because _onItemTapped depends on 'this'
  // which is available after super.initState()
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Initialize coupon data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CouponProvider>(context, listen: false).refreshCoupons();
    });

    // Initialize _widgetOptions here, after _onItemTapped is available
    _widgetOptions = <Widget>[
      // Pass the _onItemTapped callback to MyCouponsTab to enable switching tabs
      _MyCouponsTab(onNavigateToOffers: () => _onItemTapped(1)),
      const _AvailableOffersTab(),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // Redirect if not authenticated or if appUser data is not fully loaded (which implies not authenticated)
    if (!authProvider.isAuthenticated || authProvider.appUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    bool isWideScreen = MediaQuery.of(context).size.width > 900;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context, authProvider, colorScheme),
      drawer: isWideScreen ? null : _buildDrawer(context, authProvider),
      body: Row(
        children: [
          if (isWideScreen) _buildSidebar(context, authProvider),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.surface,
                      colorScheme.surface.withOpacity(0.95),
                    ],
                  ),
                ),
                child: _widgetOptions.elementAt(_selectedIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AuthProvider authProvider, ColorScheme colorScheme) {
    return AppBar(
      elevation: 0,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.hotel, size: 24.sp, color: colorScheme.onPrimary),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rumaan Hotel',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Customer Portal',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
          onPressed: () {
            Provider.of<CouponProvider>(context, listen: false).refreshCoupons();
            Fluttertoast.showToast(
              msg: 'Refreshing coupons...',
              backgroundColor: colorScheme.primary,
            );
          },
        ),
        Container(
          margin: EdgeInsets.only(right: 16.w),
          child: PopupMenuButton<String>(
            offset: Offset(0, 50.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            onSelected: (value) async {
              if (value == 'logout') {
                await authProvider.signOut();
                context.go('/');
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20.sp),
                    SizedBox(width: 12.w),
                    Text('Profile', style: TextStyle(fontSize: 16.sp)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20.sp),
                    SizedBox(width: 12.w),
                    Text('Settings', style: TextStyle(fontSize: 16.sp)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20.sp, color: Colors.red),
                    SizedBox(width: 12.w),
                    Text('Logout', style: TextStyle(fontSize: 16.sp, color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: colorScheme.onPrimary,
                    child: Text(
                      // Prioritize email first initial, then phone number initial (last digit), else 'C'
                      (authProvider.appUser?.email?.isNotEmpty == true
                          ? authProvider.appUser!.email![0].toUpperCase()
                          : authProvider.appUser?.phoneNumber?.isNotEmpty == true
                              ? authProvider.appUser!.phoneNumber![authProvider.appUser!.phoneNumber!.length - 1].toUpperCase()
                              : 'C'),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    // Display email prefix if available, else phone, else 'Customer'
                    authProvider.appUser?.email?.split('@').first ??
                    authProvider.appUser?.phoneNumber ??
                    'Customer',
                    style: TextStyle(fontSize: 14.sp, color: colorScheme.onPrimary),
                  ),
                  Icon(Icons.arrow_drop_down, color: colorScheme.onPrimary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          // This Container's height was adjusted to mitigate overflow issues.
          Container(
            height: 200.h, // Adjusted height based on common overflow scenarios
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 35.r,
                      backgroundColor: colorScheme.onPrimary,
                      child: Text(
                        // Prioritize email initial, then phone number initial (last digit), else 'C'
                        (authProvider.appUser?.email?.isNotEmpty == true
                            ? authProvider.appUser!.email![0].toUpperCase()
                            : authProvider.appUser?.phoneNumber?.isNotEmpty == true
                                ? authProvider.appUser!.phoneNumber![authProvider.appUser!.phoneNumber!.length - 1].toUpperCase()
                                : 'C'),
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      authProvider.appUser?.email ??
                      authProvider.appUser?.phoneNumber ??
                      'Customer User',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      authProvider.appUser?.role.toString().split('.').last.capitalize() ?? 'Customer', // Capitalize role
                      style: TextStyle(
                        color: colorScheme.onPrimary.withOpacity(0.8),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  child: SidebarItem(
                    icon: Icons.local_activity,
                    title: 'My Coupons',
                    isSelected: _selectedIndex == 0,
                    onTap: () {
                      _onItemTapped(0);
                      Navigator.pop(context);
                    },
                    isDrawerItem: true,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  child: SidebarItem(
                    icon: Icons.local_offer,
                    title: 'Available Offers',
                    isSelected: _selectedIndex == 1,
                    onTap: () {
                      _onItemTapped(1);
                      Navigator.pop(context);
                    },
                    isDrawerItem: true,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(16.w),
            child: ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.logout, size: 24.sp, color: Colors.red[700]),
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              onTap: () async {
                Navigator.pop(context);
                await authProvider.signOut();
                context.go('/');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AuthProvider authProvider) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.hotel,
                    size: 32.sp,
                    color: colorScheme.onPrimary,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rumaan Hotel',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Customer Portal',
                        style: TextStyle(
                          color: colorScheme.onPrimary.withOpacity(0.8),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  child: SidebarItem(
                    icon: Icons.local_activity,
                    title: 'My Coupons',
                    isSelected: _selectedIndex == 0,
                    onTap: () => _onItemTapped(0),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  child: SidebarItem(
                    icon: Icons.local_offer,
                    title: 'Available Offers',
                    isSelected: _selectedIndex == 1,
                    onTap: () => _onItemTapped(1),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    // Prioritize email initial, then phone initial, else 'C'
                    (authProvider.appUser?.email?.isNotEmpty == true
                        ? authProvider.appUser!.email![0].toUpperCase()
                        : authProvider.appUser?.phoneNumber?.isNotEmpty == true
                            ? authProvider.appUser!.phoneNumber![authProvider.appUser!.phoneNumber!.length - 1].toUpperCase()
                            : 'C'),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.appUser?.email?.split('@').first ?? 'Customer', // Display email prefix if available, else 'Customer'
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        authProvider.appUser?.role.toString().split('.').last.capitalize() ?? 'Customer', // Capitalize role
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await authProvider.signOut();
                      context.go('/');
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20.sp, color: Colors.red),
                          SizedBox(width: 8.w),
                          Text('Logout', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyCouponsTab extends StatelessWidget {
  final VoidCallback onNavigateToOffers; // Callback to navigate to Available Offers tab

  const _MyCouponsTab({required this.onNavigateToOffers});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final couponProvider = Provider.of<CouponProvider>(context);
    // Get coupons redeemed by the current user
    final redeemedCoupons = couponProvider.getRedeemedCoupons(authProvider.appUser);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.local_activity,
                    size: 32.sp,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Redeemed Coupons',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Your savings history',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${redeemedCoupons.length} Total',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          redeemedCoupons.isEmpty
              ? _buildEmptyState(
                  context,
                  icon: Icons.local_activity,
                  title: 'No Redeemed Coupons',
                  subtitle: 'You haven\'t redeemed any coupons yet. Browse available offers to get started!',
                  actionText: 'Browse Available Offers',
                  onAction: onNavigateToOffers, // Use the callback to navigate
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWideScreen = constraints.maxWidth > 600;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: isWideScreen ? 350.w : 400.w,
                        childAspectRatio: isWideScreen ? 1.3 : 1.4,
                        crossAxisSpacing: 20.w,
                        mainAxisSpacing: 20.h,
                      ),
                      itemCount: redeemedCoupons.length,
                      itemBuilder: (context, index) {
                        final coupon = redeemedCoupons[index];
                        return _RedeemedCouponCard(coupon: coupon);
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              icon,
              size: 64.sp,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16.sp,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: Icon(Icons.local_offer), // Icon for Browse offers
            label: Text(actionText),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
          ),
        ],
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
    // Get available coupons that user hasn't redeemed yet
    final availableCoupons = couponProvider.getAvailableCoupons(authProvider.appUser);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.local_offer,
                    size: 32.sp,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Offers',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Tap to reveal and redeem',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${availableCoupons.length} Available',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    IconButton(
                      icon: Icon(Icons.refresh, color: colorScheme.onSurface.withOpacity(0.6)),
                      onPressed: () {
                        couponProvider.refreshCoupons();
                        Fluttertoast.showToast(msg: 'Refreshing offers...');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          availableCoupons.isEmpty
              ? _buildEmptyState(
                  context,
                  icon: Icons.local_offer,
                  title: 'No Available Offers',
                  subtitle: 'Check back later for new exciting offers!',
                  actionText: 'Refresh Offers',
                  onAction: () {
                    couponProvider.refreshCoupons();
                    Fluttertoast.showToast(msg: 'Refreshing offers...');
                  },
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWideScreen = constraints.maxWidth > 600;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: isWideScreen ? 350.w : 400.w,
                        childAspectRatio: isWideScreen ? 1.3 : 1.4,
                        crossAxisSpacing: 20.w,
                        mainAxisSpacing: 20.h,
                      ),
                      itemCount: availableCoupons.length,
                      itemBuilder: (context, index) {
                        final coupon = availableCoupons[index];
                        return _BlurredCouponCard(
                          coupon: coupon,
                          onRedeem: () async {
                            if (authProvider.appUser?.uid == null) {
                              Fluttertoast.showToast(msg: 'Error: User not logged in.');
                              return;
                            }
                            await couponProvider.redeemCoupon(
                              coupon.id,
                              authProvider.appUser!.uid,
                            );
                            // The real-time listener in CouponProvider should update the UI automatically
                            // no need for explicit refresh here if the listener is robust.
                          },
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              icon,
              size: 64.sp,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16.sp,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: Icon(Icons.refresh), // Changed to refresh icon for "Refresh Offers"
            label: Text(actionText),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurredCouponCard extends StatefulWidget {
  final Coupon coupon;
  final VoidCallback onRedeem;

  const _BlurredCouponCard({
    required this.coupon,
    required this.onRedeem,
  });

  @override
  State<_BlurredCouponCard> createState() => _BlurredCouponCardState();
}

class _BlurredCouponCardState extends State<_BlurredCouponCard>
    with SingleTickerProviderStateMixin {
  bool _isRevealed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _blurAnimation = Tween<double>(begin: 5.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleReveal() {
    setState(() {
      _isRevealed = !_isRevealed;
    });
    if (_isRevealed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Color _getCategoryColor() {
    switch (widget.coupon.category) {
      case CouponCategory.food:
        return Colors.orange;
      case CouponCategory.spa:
        return Colors.purple;
      case CouponCategory.room:
        return Colors.blue;
      case CouponCategory.entertainment: // Added explicit case
        return Colors.red;
      case CouponCategory.other: // Handle the 'other' category
        return Colors.green;
      default:
        return Colors.green; // Fallback
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.coupon.category) {
      case CouponCategory.food:
        return Icons.restaurant;
      case CouponCategory.spa:
        return Icons.spa;
      case CouponCategory.room:
        return Icons.hotel;
      case CouponCategory.entertainment: // Added explicit case
        return Icons.movie;
      case CouponCategory.other: // Added 'other' case
        return Icons.local_offer;
      default:
        return Icons.local_offer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _toggleReveal,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Stack(
                  children: [
                    // Background gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            categoryColor.withOpacity(0.8),
                            categoryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  _getCategoryIcon(),
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                child: Text(
                                  '${widget.coupon.discount.toInt()}% OFF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // Title and Description (with blur effect)
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: _blurAnimation.value,
                              sigmaY: _blurAnimation.value,
                            ),
                            // Only enable the blur filter if not revealed
                            enabled: !_isRevealed,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.coupon.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  widget.coupon.description,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14.sp,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Bottom section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Valid until',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Text(
                                    widget.coupon.formattedValidUntil,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (_isRevealed)
                                ElevatedButton(
                                  onPressed: () => _showRedeemDialog(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: categoryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  ),
                                  child: Text(
                                    'Redeem',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Tap to reveal overlay
                    if (!_isRevealed)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  color: Colors.white,
                                  size: 32.sp,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Tap to Reveal',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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

  void _showRedeemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CouponRedeemDialog(
        coupon: widget.coupon,
        onRedeem: widget.onRedeem,
      ),
    );
  }
}

class _RedeemedCouponCard extends StatelessWidget {
  final Coupon coupon;

  const _RedeemedCouponCard({required this.coupon});

  Color _getCategoryColor() {
    switch (coupon.category) {
      case CouponCategory.food:
        return Colors.orange;
      case CouponCategory.spa:
        return Colors.purple;
      case CouponCategory.room:
        return Colors.blue;
      case CouponCategory.entertainment:
        return Colors.red;
      case CouponCategory.other:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (coupon.category) {
      case CouponCategory.food:
        return Icons.restaurant;
      case CouponCategory.spa:
        return Icons.spa;
      case CouponCategory.room:
        return Icons.hotel;
      case CouponCategory.entertainment:
        return Icons.movie;
      case CouponCategory.other:
        return Icons.local_offer;
      default:
        return Icons.local_offer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Redeemed stamp
          Positioned(
            top: 16.h,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'REDEEMED',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        _getCategoryIcon(),
                        color: categoryColor,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coupon.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${coupon.discount.toInt()}% OFF',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: categoryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                Text(
                  coupon.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Bottom info
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Redeemed on',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            // Currently using validUntil as placeholder for redeemedDate
                            // Consider adding a 'redeemedAt' field to Coupon model for accuracy
                            coupon.formattedValidUntil,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      // Example static saving display
                      Text(
                        'Saved \$${(coupon.discount * 0.5).toStringAsFixed(0)}', // This calculation is arbitrary
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponRedeemDialog extends StatelessWidget {
  final Coupon coupon;
  final VoidCallback onRedeem;

  const _CouponRedeemDialog({
    required this.coupon,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barcode/QR Code placeholder
            // This is shown for staff to scan on their device.
            Container(
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code, size: 48.sp, color: colorScheme.primary),
                  SizedBox(height: 8.h),
                  Text(
                    'Barcode: ${coupon.barcodeData}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Coupon details
            Text(
              coupon.title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.h),

            Text(
              '${coupon.discount.toInt()}% OFF',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),

            SizedBox(height: 12.h),

            Text(
              coupon.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 20.h),

            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: colorScheme.primary, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'How to redeem:',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '1. Show this barcode to staff\n2. Staff will scan the code\n3. Enjoy your discount!',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog first
                      onRedeem(); // Trigger redemption logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Redeem Now',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}