import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/provider/analytics_provider.dart';


class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsProvider>(context, listen: false).loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, analyticsProvider, child) {
          if (analyticsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Analytics Dashboard',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                Text(
                  'Real-time insights and statistics',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Main Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 1.3,
                  children: [
                    _buildStatCard(
                      'Total Users',
                      analyticsProvider.analytics.totalUsers.toString(),
                      '+${analyticsProvider.analytics.newUsersToday}',
                      'today',
                      Icons.people,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Total Logins',
                      analyticsProvider.analytics.totalLogins.toString(),
                      '+${analyticsProvider.analytics.loginsToday}',
                      'today',
                      Icons.login,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Active Coupons',
                      analyticsProvider.analytics.activeCoupons.toString(),
                      '${analyticsProvider.analytics.totalCoupons}',
                      'total',
                      Icons.local_offer,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Used Coupons',
                      analyticsProvider.analytics.usedCoupons.toString(),
                      '\$${analyticsProvider.analytics.totalSavings}',
                      'saved',
                      Icons.check_circle,
                      Colors.purple,
                    ),
                  ],
                ),
                
                SizedBox(height: 24.h),
                
                // Weekly Activity Chart
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Activity',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 200.h,
                          child: _buildWeeklyChart(analyticsProvider.weeklyData),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Coupon Categories
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coupon Categories Usage',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ...analyticsProvider.categoryData.map((category) =>
                          _buildCategoryItem(
                            category['name'] as String,
                            category['usage'] as int,
                            category['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Recent Activity
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: analyticsProvider.recentActivity.length,
                          separatorBuilder: (context, index) => Divider(height: 1.h),
                          itemBuilder: (context, index) {
                            final activity = analyticsProvider.recentActivity[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: activity['color'].withOpacity(0.1),
                                child: Icon(
                                  activity['icon'],
                                  color: activity['color'],
                                  size: 20.w,
                                ),
                              ),
                              title: Text(
                                activity['title'],
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              subtitle: Text(
                                activity['subtitle'],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: Text(
                                activity['time'],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[500],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    String subtitleLabel,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
            Text(
              subtitleLabel,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(List<Map<String, dynamic>> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((day) {
        final maxValue = data.map((d) => d['logins'] as int).reduce((a, b) => a > b ? a : b);
        final height = ((day['logins'] as int) / maxValue * 150).toDouble();
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              day['logins'].toString(),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: 24.w,
              height: height.h,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              day['day'],
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCategoryItem(String name, int usage, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6.w),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Text(
            '$usage%',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}