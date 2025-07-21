import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import '../models/app_user.dart';
import '../providers/coupon_provider.dart'; // To get coupon titles
import '../firestore_service.dart'; // Assuming you have this
import '../widgets/metric_card.dart'; // Import the new MetricCard

class ManageUsersTab extends StatelessWidget {
  const ManageUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final couponProvider = Provider.of<CouponProvider>(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
                          Text('Monitor their coupon usage and activity', style: TextStyle(fontSize: 16.sp, color: Colors.grey[600])),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement Add User functionality
                          Fluttertoast.showToast(msg: 'Add User functionality not yet implemented.');
                        },
                        icon: Icon(Icons.person_add, size: 20.sp),
                        label: Text('Add User', style: TextStyle(fontSize: 16.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary, // Use primary color
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
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return MetricCard(
                            title: 'Active Users',
                            value: '642',
                            subtitle: '75% of total users',
                          );
                        case 1:
                          return MetricCard(
                            title: 'Premium Users',
                            value: '124',
                            subtitle: '14% of total users',
                          );
                        case 2:
                          return MetricCard(
                            title: 'Avg. Savings',
                            value: '\$186',
                            subtitle: 'Per user this month',
                          );
                        default:
                          return Container();
                      }
                    },
                  ),
                  SizedBox(height: 32.h),
                  Text('User List and their activity', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.h),
                  // Search and Filter Section
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search users...',
                            prefixIcon: Icon(Icons.search, size: 20.sp, color: colorScheme.onSurface.withOpacity(0.6)),
                          ),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement filter functionality
                          Fluttertoast.showToast(msg: 'Filter functionality not yet implemented.');
                        },
                        icon: Icon(Icons.filter_list, size: 20.sp),
                        label: Text('Filter', style: TextStyle(fontSize: 16.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surface, // White background
                          foregroundColor: colorScheme.onSurface, // Black text
                          side: BorderSide(color: colorScheme.outline, width: 1), // Light grey border
                          elevation: 0, // No shadow
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  // User List (DataTable)
                  StreamBuilder<List<AppUser>>(
                    stream: firestoreService.getAllUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 16.sp, color: colorScheme.error)));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No users found.', style: TextStyle(fontSize: 18.sp, color: Colors.grey[600])));
                      }
                      final users = snapshot.data!;

                      return Card(
                        // Card theme is applied globally
                        clipBehavior: Clip.antiAlias, // Ensures borderRadius applies to children
                        child: SingleChildScrollView( // Allows horizontal scrolling for the table if needed
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 20.w,
                            dataRowMinHeight: 50.h,
                            dataRowMaxHeight: 60.h,
                            headingRowColor: MaterialStateProperty.all(colorScheme.background), // Lighter background for header
                            headingTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: colorScheme.onSurface.withOpacity(0.7)),
                            dataTextStyle: TextStyle(fontSize: 16.sp, color: colorScheme.onSurface),
                            decoration: BoxDecoration(
                              border: Border.all(color: colorScheme.outline, width: 1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            columns: [
                              DataColumn(label: Text('Contact')),
                              DataColumn(label: Text('Join Date')),
                              DataColumn(label: Text('Coupons Used')),
                              DataColumn(label: Text('Total Savings')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: users.map((user) {
                              final joinDate = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: users.indexOf(user) * 10))); // Example date
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.email, size: 16.sp, color: Colors.grey[600]),
                                            SizedBox(width: 4.w),
                                            Expanded(
                                              child: Text(
                                                user.email ?? 'N/A',
                                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(left: 20.w),
                                            child: Row(
                                              children: [
                                                Icon(Icons.phone, size: 16.sp, color: Colors.grey[600]),
                                                SizedBox(width: 4.w),
                                                Expanded(
                                                  child: Text(
                                                    user.phoneNumber!,
                                                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(joinDate)),
                                  DataCell(Text(user.redeemedCoupons.length.toString())),
                                  DataCell(Text('\$${(user.redeemedCoupons.length * 15).toStringAsFixed(2)}')), // Placeholder
                                  DataCell(
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                        child: Text(
                                          'active',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.green[800],
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.more_horiz, size: 20.sp, color: Colors.grey[600]),
                                      onPressed: () {
                                        // TODO: Implement user actions menu
                                        Fluttertoast.showToast(msg: 'User actions not yet implemented.');
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
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

// Assuming this extension is defined somewhere accessible, e.g., in a utils file or directly in the main file.
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}