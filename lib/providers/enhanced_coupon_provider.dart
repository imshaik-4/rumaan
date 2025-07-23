import 'package:flutter/material.dart'; // Import for Color and @required
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:developer' as dev;

import 'package:intl/intl.dart';

// --- Assuming these are your model definitions ---
// Typically these would be in their own files, e.g., models/coupon.dart and models/app_user.dart

enum CouponCategory { food, spa, room, other }

class Coupon {
  final String id;
  final String title;
  final String description;
  final double discount;
  final CouponCategory category;
  final DateTime validUntil;
  final bool isActive;
  final bool isSingleUse;
  final List<String> usedBy;
  final DateTime createdAt;
  final String? createdByUid;
  final String barcodeData;

  Coupon({
    required this.id,
    required this.title,
    required this.description,
    required this.discount,
    required this.category,
    required this.validUntil,
    required this.isActive,
    required this.isSingleUse,
    required this.usedBy,
    required this.createdAt,
    this.createdByUid,
    required this.barcodeData,
  });

  factory Coupon.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Coupon(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      discount: (data['discount'] as num).toDouble(),
      category: CouponCategory.values.firstWhere(
          (e) => e.toString() == 'CouponCategory.${data['category']}',
          orElse: () => CouponCategory.other),
      validUntil: (data['validUntil'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool,
      isSingleUse: data['isSingleUse'] as bool,
      usedBy: List<String>.from(data['usedBy'] as List<dynamic>),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdByUid: data['createdByUid'] as String?,
      barcodeData: data['barcodeData'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'discount': discount,
      'category': category.toString().split('.').last,
      'validUntil': Timestamp.fromDate(validUntil),
      'isActive': isActive,
      'isSingleUse': isSingleUse,
      'usedBy': usedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdByUid': createdByUid,
      'barcodeData': barcodeData,
    };
  }

  String get formattedValidUntil {
    return DateFormat('MMM dd, yyyy').format(validUntil);
  }
}

// Placeholder for AppUser model, assuming it has a 'uid' property
class AppUser {
  final String uid;
  final String email;
  final String role; // Assuming role exists

  AppUser({required this.uid, required this.email, required this.role});

  // Example factory for AppUser from Firestore, adjust as per your actual model
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      email: data['email'] as String,
      role: data['role'] as String,
    );
  }
}
// --- End of model definitions ---

class CouponProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Coupon> _allCoupons = [];
  bool _isLoading = false;
  String? _error;

  List<Coupon> get allCoupons => _allCoupons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CouponProvider() {
    _initializeListener();
  }

  void _initializeListener() {
    // Listen to real-time updates from Firestore
    _firestore.collection('coupons').snapshots().listen(
      (snapshot) {
        _allCoupons = snapshot.docs.map((doc) {
          try {
            return Coupon.fromFirestore(doc);
          } catch (e) {
            dev.log('Error parsing coupon ${doc.id}: $e');
            return null;
          }
        }).where((coupon) => coupon != null).cast<Coupon>().toList();

        // Sort coupons by creation date (newest first)
        _allCoupons.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        notifyListeners();
      },
      onError: (error) {
        dev.log('Error listening to coupons: $error');
        _error = 'Failed to load coupons';
        notifyListeners();
      },
    );
  }

  Future<void> refreshCoupons() async {
    _setLoading(true);
    try {
      final snapshot = await _firestore.collection('coupons').get();
      _allCoupons = snapshot.docs.map((doc) {
        try {
          return Coupon.fromFirestore(doc);
        } catch (e) {
          dev.log('Error parsing coupon ${doc.id}: $e');
          return null;
        }
      }).where((coupon) => coupon != null).cast<Coupon>().toList();

      // Sort coupons by creation date (newest first)
      _allCoupons.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _error = null;
    } catch (e) {
      dev.log('Error refreshing coupons: $e');
      _error = 'Failed to refresh coupons';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createCoupon({
    required String title,
    required String description,
    required double discount,
    required CouponCategory category,
    required DateTime validUntil,
    required bool isSingleUse,
    String? createdByUid,
  }) async {
    _setLoading(true);
    try {
      final coupon = Coupon(
        id: '', // Firestore will generate this
        title: title,
        description: description,
        discount: discount,
        category: category,
        validUntil: validUntil,
        isActive: true,
        isSingleUse: isSingleUse,
        usedBy: [],
        createdAt: DateTime.now(),
        createdByUid: createdByUid,
        barcodeData: _generateBarcodeData(),
      );

      await _firestore.collection('coupons').add(coupon.toFirestore());

      Fluttertoast.showToast(
        msg: 'Coupon created successfully!',
        backgroundColor: Colors.green,
      );

      dev.log('Coupon created successfully: $title');
    } catch (e) {
      dev.log('Error creating coupon: $e');
      _error = 'Failed to create coupon';
      Fluttertoast.showToast(
        msg: 'Failed to create coupon',
        backgroundColor: Colors.red,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCouponStatus(Coupon coupon, bool isActive) async {
    try {
      await _firestore.collection('coupons').doc(coupon.id).update({
        'isActive': isActive,
      });

      Fluttertoast.showToast(
        msg: 'Coupon ${isActive ? 'activated' : 'deactivated'}',
        backgroundColor: isActive ? Colors.green : Colors.orange,
      );
    } catch (e) {
      dev.log('Error updating coupon status: $e');
      Fluttertoast.showToast(
        msg: 'Failed to update coupon status',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> deleteCoupon(String couponId) async {
    try {
      await _firestore.collection('coupons').doc(couponId).delete();

      Fluttertoast.showToast(
        msg: 'Coupon deleted successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      dev.log('Error deleting coupon: $e');
      Fluttertoast.showToast(
        msg: 'Failed to delete coupon',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> redeemCoupon(String couponId, String userId) async {
    _setLoading(true);
    try {
      final couponRef = _firestore.collection('coupons').doc(couponId);

      await _firestore.runTransaction((transaction) async {
        final couponDoc = await transaction.get(couponRef);

        if (!couponDoc.exists) {
          throw Exception('Coupon not found');
        }

        final coupon = Coupon.fromFirestore(couponDoc);

        // Check if coupon is still valid
        if (!coupon.isActive) {
          throw Exception('Coupon is not active');
        }

        if (coupon.validUntil.isBefore(DateTime.now())) {
          throw Exception('Coupon has expired');
        }

        // Check if user has already redeemed this coupon
        if (coupon.usedBy.contains(userId)) {
          throw Exception('You have already redeemed this coupon');
        }

        // Add user to usedBy list
        final updatedUsedBy = [...coupon.usedBy, userId];

        // If it's a single-use coupon and someone has used it, deactivate it
        final shouldDeactivate = coupon.isSingleUse && updatedUsedBy.isNotEmpty;

        transaction.update(couponRef, {
          'usedBy': updatedUsedBy,
          if (shouldDeactivate) 'isActive': false,
        });
      });

      Fluttertoast.showToast(
        msg: 'Coupon redeemed successfully!',
        backgroundColor: Colors.green,
      );

      dev.log('Coupon redeemed successfully: $couponId by $userId');
    } catch (e) {
      dev.log('Error redeeming coupon: $e');
      String errorMessage = 'Failed to redeem coupon';

      if (e.toString().contains('already redeemed')) {
        errorMessage = 'You have already redeemed this coupon';
      } else if (e.toString().contains('not active')) {
        errorMessage = 'This coupon is no longer active';
      } else if (e.toString().contains('expired')) {
        errorMessage = 'This coupon has expired';
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        backgroundColor: Colors.red,
      );
    } finally {
      _setLoading(false);
    }
  }

  // Get coupons available for a specific user (not redeemed by them)
  List<Coupon> getAvailableCoupons(AppUser? user) {
    if (user == null) return [];

    return _allCoupons.where((coupon) {
      // Check if coupon is active
      if (!coupon.isActive) return false;

      // Check if coupon is still valid
      if (coupon.validUntil.isBefore(DateTime.now())) return false;

      // Check if user has already redeemed this coupon
      if (coupon.usedBy.contains(user.uid)) return false;

      return true;
    }).toList();
  }

  // Get coupons redeemed by a specific user
  List<Coupon> getRedeemedCoupons(AppUser? user) {
    if (user == null) return [];

    return _allCoupons.where((coupon) {
      return coupon.usedBy.contains(user.uid);
    }).toList();
  }

  // Get coupon by barcode data (for scanning)
  Coupon? getCouponByBarcodeData(String barcodeData) {
    try {
      return _allCoupons.firstWhere(
        (coupon) => coupon.barcodeData == barcodeData,
      );
    } catch (e) {
      return null;
    }
  }

  String _generateBarcodeData() {
    // Generate a unique barcode data
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'RC$timestamp$random'; // RC = Rumaan Coupon
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

// Extension for string capitalization (moved from previous file for completeness)
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}