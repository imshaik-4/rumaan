import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/model/coupon.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _qrCodeController = TextEditingController();
  Coupon? _scannedCoupon;
  bool _isScanning = false;
  bool _couponUsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'QR Code Scanner',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            SizedBox(height: 8.h),
            
            Text(
              'Scan or enter QR codes to validate and use coupons',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Scanner Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    // QR Scanner Icon
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(60.w),
                        border: Border.all(color: Colors.blue.shade200, width: 2),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: 60.w,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // QR Code Input
                    TextFormField(
                      controller: _qrCodeController,
                      decoration: InputDecoration(
                        labelText: 'QR Code',
                        hintText: 'Enter or scan QR code',
                        prefixIcon: const Icon(Icons.qr_code),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _openCamera,
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length >= 10) {
                          _scanCoupon();
                        }
                      },
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Scan Button
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton.icon(
                        onPressed: _isScanning ? null : _scanCoupon,
                        icon: _isScanning
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(
                          _isScanning ? 'Scanning...' : 'Scan Coupon',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Demo QR Codes
            Card(
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
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                          size: 20.w,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Demo QR Codes',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildDemoQRItem('RH-WELCOME-001', 'Welcome Discount - 20% OFF'),
                    _buildDemoQRItem('RH-SPA-002', 'Spa Relaxation - 30% OFF'),
                    _buildDemoQRItem('RH-ROOM-003', 'Room Upgrade - FREE UPGRADE'),
                    _buildDemoQRItem('RH-BAR-004', 'Happy Hour Special - BOGO (Used)'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Scanned Coupon Result
            if (_scannedCoupon != null) _buildCouponResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoQRItem(String qrCode, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  qrCode,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Colors.blue.shade800,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            onPressed: () {
              _qrCodeController.text = qrCode;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Copied $qrCode')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCouponResult() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scanned Coupon',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            if (_scannedCoupon!.qrCode == 'INVALID') ...[
              // Invalid Coupon
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48.w,
                      color: Colors.red.shade600,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Invalid Coupon',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Coupon not found or QR code is invalid',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.red.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Valid Coupon
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coupon Header
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: Colors.amber.shade600,
                          size: 24.w,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            _scannedCoupon!.title,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(_scannedCoupon!.category as String).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            _scannedCoupon!.category as String,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: _getCategoryColor(_scannedCoupon!.category as String),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    Text(
                      _scannedCoupon!.description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Discount
                    Text(
                      _scannedCoupon!.discount,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Status and Valid Until
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: _scannedCoupon!.isUsed 
                                ? Colors.red.shade50 
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: _scannedCoupon!.isUsed 
                                  ? Colors.red.shade200 
                                  : Colors.green.shade200,
                            ),
                          ),
                          child: Text(
                            _scannedCoupon!.isUsed ? 'Already Used' : 'Valid',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: _scannedCoupon!.isUsed 
                                  ? Colors.red.shade700 
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Valid until: ${_scannedCoupon!.validUntil}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Use Coupon Button
                    if (!_scannedCoupon!.isUsed && !_couponUsed) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton.icon(
                          onPressed: _useCoupon,
                          icon: const Icon(Icons.check_circle),
                          label: Text(
                            'Use Coupon',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ] else if (_couponUsed) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 32.w,
                              color: Colors.green.shade600,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Coupon Used Successfully!',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            Text(
                              'The coupon has been redeemed and is now expired.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.green.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade600,
                              size: 24.w,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'This coupon has already been used',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 16.h),
            
            // Reset Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resetScanner,
                icon: const Icon(Icons.refresh),
                label: const Text('Scan Another Coupon'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Dining':
        return Colors.blue;
      case 'Spa':
        return Colors.green;
      case 'Accommodation':
        return Colors.purple;
      case 'Bar':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _openCamera() {
    // In a real app, you would open the camera scanner here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera scanner would open here. For demo, use the text input.'),
      ),
    );
  }

  void _scanCoupon() async {
    if (_qrCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a QR code')),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _couponUsed = false;
    });

    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 1));

    final qrCode = _qrCodeController.text.trim().toUpperCase();
    
    // Demo coupon data
    final demoCoupons = {
      'RH-WELCOME-001': Coupon(
        id: '1',
        title: 'Welcome Discount',
        description: 'Get 20% off on your first dining experience at our premium restaurant',
        discount: '20% OFF',
        validUntil: DateTime(2024, 12, 31),
        isUsed: false,
        isActive: true,
        qrCode: 'RH-WELCOME-001',
        category: CouponCategory.dining,
        createdAt: DateTime(2024, 1, 1),
      ),
      'RH-SPA-002': Coupon(
        id: '2',
        title: 'Spa Relaxation',
        description: 'Enjoy a rejuvenating spa session with 30% discount on all treatments',
        discount: '30% OFF',
        validUntil: DateTime(2024, 11, 30),
        isUsed: false,
        isActive: true,
        qrCode: 'RH-SPA-002',
        category: CouponCategory.spa,
        createdAt: DateTime(2024, 2, 1),
      ),
      'RH-ROOM-003': Coupon(
        id: '3',
        title: 'Room Upgrade',
        description: 'Free upgrade to deluxe room for your next stay (subject to availability)',
        discount: 'FREE UPGRADE',
        validUntil: DateTime(2024, 10, 31),
        isUsed: false,
        isActive: true,
        qrCode: 'RH-ROOM-003',
        category: CouponCategory.accommodation,
        createdAt: DateTime(2024, 3, 1),
      )
    };

    setState(() {
      _scannedCoupon = demoCoupons[qrCode] ??
          Coupon(
            id: 'invalid',
            title: 'Invalid',
            description: 'Invalid coupon',
            discount: '',
            validUntil: DateTime(2000, 1, 1),
            isUsed: false,
            isActive: false,
            qrCode: 'INVALID',
            category: CouponCategory.dining,
            createdAt: DateTime(2000, 1, 1),
          );
      _isScanning = false;
    });
  }

  void _useCoupon() async {
    if (_scannedCoupon == null || _scannedCoupon!.isUsed) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Use Coupon'),
        content: Text(
          'Are you sure you want to use "${_scannedCoupon!.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Use Coupon'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _couponUsed = true;
        _scannedCoupon = _scannedCoupon!.copyWith(isUsed: true);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon "${_scannedCoupon!.title}" used successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _resetScanner() {
    setState(() {
      _qrCodeController.clear();
      _scannedCoupon = null;
      _couponUsed = false;
    });
  }

  @override
  void dispose() {
    _qrCodeController.dispose();
    super.dispose();
  }
}