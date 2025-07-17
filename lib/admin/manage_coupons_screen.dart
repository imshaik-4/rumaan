// lib/screens/admin/manage_coupons_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/model/coupon.dart';
import 'package:rumaan/provider/coupon_provider.dart';


class ManageCouponsScreen extends StatefulWidget {
  const ManageCouponsScreen({super.key});

  @override
  State<ManageCouponsScreen> createState() => _ManageCouponsScreenState();
}

class _ManageCouponsScreenState extends State<ManageCouponsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CouponProvider>(context, listen: false).loadCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CouponProvider>(
        builder: (context, couponProvider, child) {
          final filteredCoupons = _getFilteredCoupons(couponProvider.coupons);

          return Column(
            children: [
              // Header and Filters
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Coupons',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    
                    // Search Bar
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search coupons...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Active', 'Inactive', 'Used', 'Dining', 'Spa', 'Accommodation', 'Bar']
                            .map((filter) => Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: FilterChip(
                                    label: Text(filter),
                                    selected: _selectedFilter == filter,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedFilter = selected ? filter : 'All';
                                      });
                                    },
                                    selectedColor: Colors.red.shade100,
                                    checkmarkColor: Colors.red.shade600,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Coupons List
              Expanded(
                child: couponProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredCoupons.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: filteredCoupons.length,
                            itemBuilder: (context, index) {
                              final coupon = filteredCoupons[index];
                              return _buildCouponCard(coupon, couponProvider);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Coupon> _getFilteredCoupons(List<Coupon> coupons) {
    List<Coupon> filtered = coupons;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((coupon) =>
              coupon.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              coupon.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply category/status filter
    switch (_selectedFilter) {
      case 'Active':
        filtered = filtered.where((coupon) => coupon.isActive && !coupon.isUsed).toList();
        break;
      case 'Inactive':
        filtered = filtered.where((coupon) => !coupon.isActive).toList();
        break;
      case 'Used':
        filtered = filtered.where((coupon) => coupon.isUsed).toList();
        break;
      case 'Dining':
      case 'Spa':
      case 'Accommodation':
      case 'Bar':
        filtered = filtered.where((coupon) => coupon.category == _selectedFilter).toList();
        break;
    }

    return filtered;
  }

  Widget _buildCouponCard(Coupon coupon, CouponProvider provider) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        coupon.description,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _buildStatusChip(coupon),
                    SizedBox(height: 8.h),
                    _buildCategoryChip(coupon.category as String),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Details Row
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem('Discount', coupon.discount, Icons.local_offer),
                ),
                Expanded(
                  child: _buildDetailItem('Valid Until', coupon.validUntil as String, Icons.calendar_today),
                ),
                Expanded(
                  child: _buildDetailItem('QR Code', coupon.qrCode, Icons.qr_code),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCouponDetails(coupon),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editCoupon(coupon),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleCouponStatus(coupon, provider),
                    icon: Icon(coupon.isActive ? Icons.pause : Icons.play_arrow),
                    label: Text(coupon.isActive ? 'Deactivate' : 'Activate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: coupon.isActive ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
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

  Widget _buildStatusChip(Coupon coupon) {
    Color color;
    String label;
    
    if (coupon.isUsed) {
      color = Colors.grey;
      label = 'Used';
    } else if (coupon.isActive) {
      color = Colors.green;
      label = 'Active';
    } else {
      color = Colors.red;
      label = 'Inactive';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final colors = {
      'Dining': Colors.blue,
      'Spa': Colors.green,
      'Accommodation': Colors.purple,
      'Bar': Colors.orange,
    };

    final color = colors[category] ?? Colors.grey;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16.w, color: Colors.grey[600]),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'No coupons found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showCouponDetails(Coupon coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(coupon.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${coupon.description}'),
            SizedBox(height: 8.h),
            Text('Discount: ${coupon.discount}'),
            SizedBox(height: 8.h),
            Text('Category: ${coupon.category}'),
            SizedBox(height: 8.h),
            Text('Valid Until: ${coupon.validUntil}'),
            SizedBox(height: 8.h),
            Text('QR Code: ${coupon.qrCode}'),
            SizedBox(height: 8.h),
            Text('Status: ${coupon.isActive ? "Active" : "Inactive"}'),
            SizedBox(height: 8.h),
            Text('Used: ${coupon.isUsed ? "Yes" : "No"}'),
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

  void _editCoupon(Coupon coupon) {
    // Navigate to edit coupon screen or show edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${coupon.title} - Feature coming soon')),
    );
  }

  void _toggleCouponStatus(Coupon coupon, CouponProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${coupon.isActive ? "Deactivate" : "Activate"} Coupon'),
        content: Text(
          'Are you sure you want to ${coupon.isActive ? "deactivate" : "activate"} "${coupon.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.toggleCouponStatus(coupon.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Coupon ${coupon.isActive ? "deactivated" : "activated"} successfully',
                  ),
                ),
              );
            },
            child: Text(coupon.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }
}