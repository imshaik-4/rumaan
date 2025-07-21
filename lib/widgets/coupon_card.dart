import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:barcode_widget/barcode_widget.dart';

import '../models/coupon.dart';
import 'barcode_display.dart';

class CouponCard extends StatelessWidget {
  final Coupon coupon;
  final VoidCallback? onRedeem;
  final bool isRedeemable;

  const CouponCard({
    super.key,
    required this.coupon,
    this.onRedeem,
    this.isRedeemable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              coupon.title,
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Text(
              '${coupon.discount.toStringAsFixed(0)}% OFF',
              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.green[700]),
            ),
            SizedBox(height: 8.h),
            Flexible( // Use Expanded to allow description to take available space
              child: Text(
                coupon.description,
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                maxLines: 3, // Allow up to 3 lines
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.category, size: 18.sp, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  coupon.category.toString().split('.').last.capitalize(),
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                SizedBox(width: 16.w),
                Icon(Icons.calendar_today, size: 18.sp, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  'Valid until: ${coupon.formattedValidUntil}',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 12.h), // Add some space before buttons
            if (isRedeemable)
              Center(
                child: ElevatedButton.icon(
                  onPressed: onRedeem,
                  icon: Icon(Icons.check_circle_outline, size: 20.sp),
                  label: Text('Redeem Coupon', style: TextStyle(fontSize: 16.sp)),
                ),
              )
            else
              Center(
                child: Column(
                  children: [
                    Text(
                      'Redeemed!',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.green[700]),
                    ),
                    SizedBox(height: 8.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Your Barcode', style: TextStyle(fontSize: 20.sp)),
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
                      icon: Icon(Icons.barcode_reader, size: 20.sp),
                      label: Text('Show Barcode', style: TextStyle(fontSize: 16.sp)),
                    ),
                  ],
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
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
