import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/provider/coupon_provider.dart';
import 'package:rumaan/provider/analytics_provider.dart';
import 'package:rumaan/model/coupon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer' as dev;

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  String? _scanResult;
  String? _statusMessage;
  Color _statusColor = Colors.black;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodes) async {
    if (!_isScanning) return;

    final barcode = barcodes.barcodes.first;
    final qrCode = barcode.rawValue;

    if (qrCode == null || qrCode == _scanResult) return; // Avoid re-processing same code

    setState(() {
      _isScanning = false; // Pause scanning
      _scanResult = qrCode;
      _statusMessage = 'Scanning...';
      _statusColor = Colors.blue;
    });

    dev.log('QR Code detected: $qrCode');

    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);

    try {
      final coupon = await couponProvider.getCouponByQrCode(qrCode);

      if (coupon == null) {
        setState(() {
          _statusMessage = 'Coupon not found!';
          _statusColor = Colors.red;
        });
        _resumeScanningAfterDelay();
        return;
      }

      if (coupon.isUsed) {
        setState(() {
          _statusMessage = 'Coupon "${coupon.title}" already used!';
          _statusColor = Colors.orange;
        });
        _resumeScanningAfterDelay();
        return;
      }

      if (!coupon.isActive) {
        setState(() {
          _statusMessage = 'Coupon "${coupon.title}" is inactive!';
          _statusColor = Colors.orange;
        });
        _resumeScanningAfterDelay();
        return;
      }

      if (coupon.validUntil.isBefore(DateTime.now())) {
        setState(() {
          _statusMessage = 'Coupon "${coupon.title}" has expired!';
          _statusColor = Colors.orange;
        });
        _resumeScanningAfterDelay();
        return;
      }

      // Mark coupon as used and update usage count
      coupon.isUsed = true;
      coupon.usageCount = (coupon.usageCount ?? 0) + 1;
      await couponProvider.updateCoupon(coupon);

      // Update analytics
      await analyticsProvider.updateAnalytics(
        usedCouponsIncrement: 1,
        activeCouponsChange: -1, // Assuming it was active before use
        totalSavingsIncrement: _parseDiscountValue(coupon.discount), totalCouponsIncrement: 0, // Implement this
      );

      setState(() {
        _statusMessage = 'Coupon "${coupon.title}" successfully redeemed!';
        _statusColor = Colors.green;
      });
      _resumeScanningAfterDelay();
    } catch (e) {
      dev.log('Error processing QR code: $e');
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
        _statusColor = Colors.red;
      });
      _resumeScanningAfterDelay();
    }
  }

  double _parseDiscountValue(String discount) {
    // Simple parsing for demo. In a real app, handle various formats (%, fixed amount)
    if (discount.endsWith('%')) {
      final value = double.tryParse(discount.replaceAll('%', '')) ?? 0.0;
      return value / 100.0 * 50.0; // Assume average saving of $50 for percentage
    } else if (discount.startsWith('\$')) {
      return double.tryParse(discount.replaceAll('\$', '')) ?? 0.0;
    }
    return 10.0; // Default saving if format is unknown
  }

  void _resumeScanningAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = true;
          _scanResult = null; // Clear previous result
          _statusMessage = null;
        });
        cameraController.start(); // Restart camera
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Coupon'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: _onDetect,
                  scanWindow: Rect.fromCenter(
                    center: MediaQuery.of(context).size.center(Offset.zero),
                    width: 200.w,
                    height: 200.w,
                  ),
                ),
                Center(
                  child: Container(
                    width: 200.w,
                    height: 200.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        _statusMessage ?? 'Align QR/Barcode within the frame',
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Scan Result:',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _scanResult ?? 'No code scanned yet',
                    style: TextStyle(fontSize: 16.sp, color: _statusColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isScanning = true;
                        _scanResult = null;
                        _statusMessage = null;
                      });
                      cameraController.start();
                    },
                    child: const Text('Rescan'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
