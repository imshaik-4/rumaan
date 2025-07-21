import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler
import 'dart:developer' as dev; // Import for dev.log

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController? cameraController;
  bool _isScanning = true;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _checkAndRequestCameraPermission();
  }

  Future<void> _checkAndRequestCameraPermission() async {
    final status = await Permission.camera.status;
    dev.log('DEBUG: Camera permission status on init: $status');
    setState(() {
      _permissionStatus = status;
    });

    if (status.isGranted) {
      _initCameraController();
    } else if (status.isDenied || status.isPermanentlyDenied) {
      Fluttertoast.showToast(msg: 'Camera permission is required to scan barcodes.');
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    dev.log('DEBUG: Camera permission status after request: $status');
    setState(() {
      _permissionStatus = status;
    });

    if (status.isGranted) {
      _initCameraController();
    } else if (status.isPermanentlyDenied) {
      Fluttertoast.showToast(msg: 'Camera permission permanently denied. Please enable it in app settings.');
      openAppSettings(); // Opens app settings
    } else {
      Fluttertoast.showToast(msg: 'Camera permission denied.');
    }
  }

  void _initCameraController() {
    if (cameraController == null) { // Only initialize if not already
      dev.log('DEBUG: Initializing MobileScannerController.');
      cameraController = MobileScannerController();
    }
  }

  @override
  void dispose() {
    dev.log('DEBUG: Disposing MobileScannerController.');
    cameraController?.dispose(); // Dispose if initialized
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Barcode', style: TextStyle(fontSize: 20.sp)),
        actions: [
          if (_permissionStatus.isGranted && cameraController != null) ...[
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.flash_on),
              iconSize: 32.0.sp,
              onPressed: () => cameraController!.toggleTorch(),
            ),
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.camera_rear),
              iconSize: 32.0.sp,
              onPressed: () => cameraController!.switchCamera(),
            ),
          ],
        ],
      ),
      body: _permissionStatus.isGranted && cameraController != null
          ? Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    if (_isScanning) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final String? barcodeData = barcodes.first.rawValue;
                        if (barcodeData != null) {
                          setState(() {
                            _isScanning = false; // Stop scanning after first detection
                          });
                          Fluttertoast.showToast(msg: 'Barcode Scanned: $barcodeData');
                          context.pop(barcodeData); // Return the scanned data
                        }
                      }
                    }
                  },
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 200.w,
                    height: 150.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 40.h),
                    child: Text(
                      'Position the barcode within the red frame',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp, backgroundColor: Colors.black54),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 80.sp, color: Colors.grey[600]),
                  SizedBox(height: 24.h),
                  Text(
                    _permissionStatus.isPermanentlyDenied
                        ? 'Camera access denied. Please enable it in app settings.'
                        : 'Camera permission is required to scan barcodes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18.sp, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: _requestCameraPermission,
                    icon: Icon(Icons.camera_alt, size: 24.sp),
                    label: Text('Grant Camera Permission', style: TextStyle(fontSize: 18.sp)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
