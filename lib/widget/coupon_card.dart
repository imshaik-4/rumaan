import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rumaan/model/coupon.dart';

class CouponCard extends StatelessWidget {
  final Coupon coupon;
  final bool isRevealed;
  final VoidCallback onReveal;

  const CouponCard({
    super.key,
    required this.coupon,
    this.isRevealed = false,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: coupon.isUsed ? null : onReveal, // Only reveal if not used
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      coupon.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      coupon.discount,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                coupon.description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16.w, color: Colors.grey.shade600),
                  SizedBox(width: 4.w),
                  Text(
                    'Valid until: ${DateFormat('MMM dd, yyyy').format(coupon.validUntil)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  if (coupon.isUsed)
                    Chip(
                      label: Text('USED', style: TextStyle(fontSize: 10.sp, color: Colors.white)),
                      backgroundColor: Colors.red.shade400,
                    )
                  else if (!coupon.isActive)
                    Chip(
                      label: Text('INACTIVE', style: TextStyle(fontSize: 10.sp, color: Colors.white)),
                      backgroundColor: Colors.grey.shade400,
                    )
                  else
                    Chip(
                      label: Text('ACTIVE', style: TextStyle(fontSize: 10.sp, color: Colors.white)),
                      backgroundColor: Colors.green.shade400,
                    ),
                ],
              ),
              if (isRevealed && !coupon.isUsed) ...[
                SizedBox(height: 16.h),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: QrImageView(
                      data: coupon.qrCode,
                      version: QrVersions.auto,
                      size: 120.w,
                      gapless: false,
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: Size(20.w, 20.w),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: Text(
                    'Scan this QR code to redeem',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
