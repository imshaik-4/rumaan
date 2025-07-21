// Assuming your existing coupon_card.dart looks something like this.
// I've updated it to use the new theme colors and a slightly more modern look.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/coupon.dart'; // Assuming you have this model

class CouponCard extends StatelessWidget {
  final Coupon coupon;
  final VoidCallback? onRedeem;
  final bool isRedeemable;

  const CouponCard({
    super.key,
    required this.coupon,
    this.onRedeem,
    this.isRedeemable = false,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      // Card theme is already set in appTheme, so no need to repeat elevation/shape
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              coupon.title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Text(
              coupon.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.discount, size: 18.sp, color: colorScheme.primary),
                SizedBox(width: 4.w),
                Text(
                  '${coupon.discount.toStringAsFixed(0)}% Off',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(Icons.category, size: 18.sp, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  coupon.category.toString().split('.').last.capitalize(),
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  'Valid until: ${coupon.formattedValidUntil}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.repeat, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  'Single Use: ${coupon.isSingleUse ? 'Yes' : 'No'}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.people, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  'Used by: ${coupon.usedBy.length} users',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            const Spacer(), // Pushes content to top, button to bottom
            if (isRedeemable) ...[
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRedeem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700], // Green for redeem
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  child: Text('Redeem Coupon'),
                ),
              ),
            ],
          ],
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