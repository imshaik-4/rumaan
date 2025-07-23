import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../models/app_user.dart';
import '../providers/coupon_provider.dart';
import '../widgets/metric_card.dart';

class ManageUsersTab extends StatefulWidget {
  const ManageUsersTab({super.key});

  @override
  State<ManageUsersTab> createState() => _ManageUsersTabState();
}

class _ManageUsersTabState extends State<ManageUsersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample users data (replace with your actual data source)
  List<AppUser> _sampleUsers = [];

  @override
  void initState() {
    super.initState();
    _initializeSampleUsers();
  }

  void _initializeSampleUsers() {
    _sampleUsers = [
      AppUser(
        uid: 'user1',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        role: UserRole.customer,
        redeemedCoupons: ['coupon1', 'coupon2'],
      ),
      AppUser(
        uid: 'user2',
        email: 'jane.smith@example.com',
        phoneNumber: '+1234567891',
        role: UserRole.customer,
        redeemedCoupons: ['coupon1'],
      ),
      AppUser(
        uid: 'user3',
        email: 'bob.wilson@example.com',
        phoneNumber: '+1234567892',
        role: UserRole.customer,
        redeemedCoupons: ['coupon1', 'coupon2', 'coupon3'],
      ),
      AppUser(
        uid: 'user4',
        email: 'alice.brown@example.com',
        phoneNumber: '+1234567893',
        role: UserRole.customer,
        redeemedCoupons: [],
      ),
      AppUser(
        uid: 'user5',
        email: 'charlie.davis@example.com',
        phoneNumber: '+1234567894',
        role: UserRole.customer,
        redeemedCoupons: ['coupon2', 'coupon3'],
      ),
    ];
  }

  // Fixed filteredUsers getter
  List<AppUser> get filteredUsers {
    if (_searchQuery.isEmpty) {
      return _sampleUsers;
    }
    return _sampleUsers.where((user) {
      return user.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false ||
       (user.phoneNumber ?? '').contains(_searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final couponProvider = Provider.of<CouponProvider>(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final filteredUsersList = filteredUsers;

    return SingleChildScrollView(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User Management', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4.h),
                          Text('Monitor user coupon usage and activity', style: TextStyle(fontSize: 16.sp, color: Colors.grey[600])),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddUserDialog(context);
                        },
                        icon: Icon(Icons.person_add, size: 20.sp),
                        label: Text('Add User', style: TextStyle(fontSize: 16.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  
                  // Metric Cards Section
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
                            value: _sampleUsers.length.toString(),
                            subtitle: 'Registered customers',
                            icon: Icons.people, color: Colors.blue,trend: '',
                          );
                        case 1:
                          return MetricCard(
                            title: 'Active Users',
                            value: _sampleUsers.where((u) => u.redeemedCoupons.isNotEmpty).length.toString(),
                            subtitle: 'Users with redeemed coupons',
                            icon: Icons.person_outline, color: Colors.blue, trend: '',
                          );
                        case 2:
                          return MetricCard(
                            title: 'Total Redemptions',
                            value: _sampleUsers.fold<int>(0, (sum, user) => sum + user.redeemedCoupons.length).toString(),
                            subtitle: 'Coupons redeemed',
                            icon: Icons.local_activity, color: Colors.blue, trend: '',
                          );
                        case 3:
                          return MetricCard(
                            title: 'Avg. Savings',
                            value: '\$${(_sampleUsers.fold<int>(0, (sum, user) => sum + user.redeemedCoupons.length) * 15).toStringAsFixed(0)}',
                            subtitle: 'Total customer savings',
                            icon: Icons.attach_money, color: Colors.blue, trend: '',
                          );
                        default:
                          return Container();
                      }
                    },
                  ),
                  SizedBox(height: 32.h),
                  
                  Text('User List and Activity', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.h),
                  
                  // Search and Filter Section
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search users by email or phone...',
                            prefixIcon: Icon(Icons.search, size: 20.sp, color: colorScheme.onSurface.withOpacity(0.6)),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, size: 20.sp),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                          ),
                          style: TextStyle(fontSize: 16.sp),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showFilterDialog(context);
                        },
                        icon: Icon(Icons.filter_list, size: 20.sp),
                        label: Text('Filter', style: TextStyle(fontSize: 16.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(color: colorScheme.outline, width: 1),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  
                  // User List
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: filteredUsersList.isEmpty
                        ? Padding(
                            padding: EdgeInsets.all(32.w),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.people_outline, size: 64.sp, color: Colors.grey[400]),
                                  SizedBox(height: 16.h),
                                  Text(
                                    _searchQuery.isNotEmpty ? 'No users found matching your search.' : 'No users found.',
                                    style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 20.w,
                              dataRowMinHeight: 60.h,
                              dataRowMaxHeight: 80.h,
                              headingRowColor: WidgetStateProperty.all(colorScheme.surface),
                              headingTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                              dataTextStyle: TextStyle(fontSize: 16.sp, color: colorScheme.onSurface),
                              columns: const [
                                DataColumn(label: Text('User Info')),
                                DataColumn(label: Text('Join Date')),
                                DataColumn(label: Text('Coupons Used')),
                                DataColumn(label: Text('Total Savings')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: filteredUsersList.map((user) {
                                final joinDate = DateFormat('MMM dd, yyyy').format(
                                  DateTime.now().subtract(Duration(days: filteredUsersList.indexOf(user) * 10 + 30)),
                                );
                                final totalSavings = user.redeemedCoupons.length * 15;
                                
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16.r,
                                                backgroundColor: colorScheme.primary.withOpacity(0.1),
                                                child: Text(
                                                  (user.email?.substring(0, 1).toUpperCase() ?? 'U'),
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      user.email ?? 'N/A',
                                                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                                                      Text(
                                                        user.phoneNumber!,
                                                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text(joinDate)),
                                    DataCell(
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: user.redeemedCoupons.isNotEmpty 
                                              ? Colors.blue.withOpacity(0.1)
                                              : Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Text(
                                          user.redeemedCoupons.length.toString(),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: user.redeemedCoupons.isNotEmpty 
                                                ? Colors.blue[800]
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text('\$${totalSavings.toStringAsFixed(2)}')),
                                    DataCell(
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Text(
                                          'Active',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.green[800],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert, size: 20.sp, color: Colors.grey[600]),
                                        onSelected: (value) {
                                          _handleUserAction(context, user, value);
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'view',
                                            child: Row(
                                              children: [
                                                Icon(Icons.visibility, size: 16.sp),
                                                SizedBox(width: 8.w),
                                                const Text('View Details'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, size: 16.sp),
                                                SizedBox(width: 8.w),
                                                const Text('Edit User'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'disable',
                                            child: Row(
                                              children: [
                                                Icon(Icons.block, size: 16.sp, color: Colors.red),
                                                SizedBox(width: 8.w),
                                                const Text('Disable User', style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
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

  void _showAddUserDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    UserRole selectedRole = UserRole.customer;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: SizedBox(
          width: 300.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'user@example.com',
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+1234567890',
                ),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedRole = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              emailController.dispose();
              phoneController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                setState(() {
                  _sampleUsers.add(
                    AppUser(
                      uid: 'user${_sampleUsers.length + 1}',
                      email: emailController.text,
                      phoneNumber: phoneController.text.isNotEmpty ? phoneController.text : null,
                      role: selectedRole,
                      redeemedCoupons: [],
                    ),
                  );
                });
                emailController.dispose();
                phoneController.dispose();
                Navigator.pop(context);
                Fluttertoast.showToast(msg: 'User added successfully!');
              } else {
                Fluttertoast.showToast(msg: 'Please enter an email address');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Users'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter options:'),
            SizedBox(height: 16.h),
            ListTile(
              title: const Text('All Users'),
              leading: Radio<String>(
                value: 'all',
                groupValue: 'all',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Active Users Only'),
              leading: Radio<String>(
                value: 'active',
                groupValue: 'all',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Inactive Users Only'),
              leading: Radio<String>(
                value: 'inactive',
                groupValue: 'all',
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(msg: 'Filter applied successfully!');
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(BuildContext context, AppUser user, String action) {
    switch (action) {
      case 'view':
        _showUserDetails(context, user);
        break;
      case 'edit':
        _showEditUserDialog(context, user);
        break;
      case 'disable':
        _showDisableUserDialog(context, user);
        break;
    }
  }

  void _showUserDetails(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email ?? 'N/A'}'),
            SizedBox(height: 8.h),
            Text('Phone: ${user.phoneNumber ?? 'N/A'}'),
            SizedBox(height: 8.h),
            Text('Role: ${user.role.toString().split('.').last.toUpperCase()}'),
            SizedBox(height: 8.h),
            Text('Coupons Redeemed: ${user.redeemedCoupons.length}'),
            SizedBox(height: 8.h),
            Text('Total Savings: \$${(user.redeemedCoupons.length * 15).toStringAsFixed(2)}'),
            SizedBox(height: 8.h),
            Text('User ID: ${user.uid}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, AppUser user) {
    final TextEditingController emailController = TextEditingController(text: user.email);
    final TextEditingController phoneController = TextEditingController(text: user.phoneNumber);
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SizedBox(
          width: 300.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedRole = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              emailController.dispose();
              phoneController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                setState(() {
                  final userIndex = _sampleUsers.indexWhere((u) => u.uid == user.uid);
                  if (userIndex != -1) {
                    _sampleUsers[userIndex] = AppUser(
                      uid: user.uid,
                      email: emailController.text,
                      phoneNumber: phoneController.text.isNotEmpty ? phoneController.text : null,
                      role: selectedRole,
                      redeemedCoupons: user.redeemedCoupons,
                    );
                  }
                });
                emailController.dispose();
                phoneController.dispose();
                Navigator.pop(context);
                Fluttertoast.showToast(msg: 'User updated successfully!');
              } else {
                Fluttertoast.showToast(msg: 'Please enter an email address');
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDisableUserDialog(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable User'),
        content: Text('Are you sure you want to disable ${user.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _sampleUsers.removeWhere((u) => u.uid == user.uid);
              });
              Navigator.pop(context);
              Fluttertoast.showToast(msg: 'User disabled successfully!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }
}