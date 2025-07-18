import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BarcodeDisplay extends StatelessWidget {
  final String barcodeData;

  const BarcodeDisplay({super.key, required this.barcodeData});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BarcodeWidget(
          barcode: Barcode.code128(), // Use Code 128 for general purpose barcodes
          data: barcodeData,
          width: 300.w,
          height: 100.h,
          drawText: true,
          style: TextStyle(fontSize: 16.sp),
        ),
        SizedBox(height: 16.h),
        Text(
          'Scan this barcode to redeem',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
