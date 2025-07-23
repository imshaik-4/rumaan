import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import '../models/coupon.dart';
import '../models/app_user.dart';

class CouponProvider with ChangeNotifier {
  // Local storage for coupons (in a real app, you might use SharedPreferences or local database)
  List<Coupon> _allCoupons = [];
  bool _isLoading = false;

  List<Coupon> get allCoupons => _allCoupons;
  bool get isLoading => _isLoading;

  CouponProvider() {
    _initializeWithSampleData();
  }

  // Initialize with some sample coupons for testing
  void _initializeWithSampleData() {
    _allCoupons = [
      Coupon(
        id: const Uuid().v4(),
        title: '20% Off Spa Treatment',
        description: 'Enjoy a relaxing spa session with 20% discount on all treatments.',
        discount: 20.0,
        category: CouponCategory.spa,
        validUntil: DateTime.now().add(const Duration(days: 30)),
        barcodeData: 'SPA20OFF',
        isActive: true,
        usedBy: [],
        isSingleUse: false,
        createdByUid: 'admin',
        createdAt: DateTime.now(),
      ),
      Coupon(
        id: const Uuid().v4(),
        title: '15% Off Restaurant',
        description: 'Get 15% discount on all food items at our restaurant.',
        discount: 15.0,
        category: CouponCategory.food,
        validUntil: DateTime.now().add(const Duration(days: 45)),
        barcodeData: 'FOOD15OFF',
        isActive: true,
        usedBy: [],
        isSingleUse: false,
        createdByUid: 'admin',
        createdAt: DateTime.now(),
      ),
      Coupon(
        id: const Uuid().v4(),
        title: '30% Off Room Upgrade',
        description: 'Upgrade your room with 30% discount on premium rooms.',
        discount: 30.0,
        category: CouponCategory.room,
        validUntil: DateTime.now().add(const Duration(days: 60)),
        barcodeData: 'ROOM30OFF',
        isActive: true,
        usedBy: [],
        isSingleUse: true,
        createdByUid: 'admin',
        createdAt: DateTime.now(),
      ),
    ];
    notifyListeners();
  }

  List<Coupon> getAvailableCoupons(AppUser? user) {
    if (user == null) return [];
    
    return _allCoupons.where((coupon) {
      return coupon.isActive &&
             !coupon.usedBy.contains(user.uid) &&
             coupon.validUntil.isAfter(DateTime.now());
    }).toList();
  }

  List<Coupon> getRedeemedCoupons(AppUser? user) {
    if (user == null) return [];
    
    return _allCoupons.where((coupon) {
      return coupon.usedBy.contains(user.uid);
    }).toList();
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
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final String id = const Uuid().v4();
      final Coupon newCoupon = Coupon(
        id: id,
        title: title,
        description: description,
        discount: discount,
        category: category,
        validUntil: validUntil,
        barcodeData: id,
        isActive: true,
        usedBy: [],
        isSingleUse: isSingleUse,
        createdByUid: createdByUid,
        createdAt: DateTime.now(),
      );

      _allCoupons.add(newCoupon);
      print('Coupon created successfully: ${newCoupon.title}');
      Fluttertoast.showToast(msg: 'Coupon "${newCoupon.title}" created successfully!');
      
    } catch (e) {
      print('Error creating coupon: $e');
      Fluttertoast.showToast(msg: 'Error creating coupon: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCouponStatus(Coupon coupon, bool isActive) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final index = _allCoupons.indexWhere((c) => c.id == coupon.id);
      if (index != -1) {
        _allCoupons[index] = _allCoupons[index].copyWith(isActive: isActive);
        Fluttertoast.showToast(msg: 'Coupon status updated successfully!');
      }
    } catch (e) {
      print('Error updating coupon: $e');
      Fluttertoast.showToast(msg: 'Error updating coupon: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCoupon(String couponId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      _allCoupons.removeWhere((coupon) => coupon.id == couponId);
      Fluttertoast.showToast(msg: 'Coupon deleted successfully!');
    } catch (e) {
      print('Error deleting coupon: $e');
      Fluttertoast.showToast(msg: 'Error deleting coupon: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> redeemCoupon(String couponId, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final couponIndex = _allCoupons.indexWhere((c) => c.id == couponId);
      if (couponIndex == -1) {
        throw Exception("Coupon does not exist!");
      }

      final coupon = _allCoupons[couponIndex];

      if (coupon.usedBy.contains(userId)) {
        throw Exception('Coupon already redeemed by this user.');
      }

      if (!coupon.isActive) {
        throw Exception('This coupon is inactive.');
      }

      if (coupon.validUntil.isBefore(DateTime.now())) {
        throw Exception('This coupon has expired.');
      }

      // Update the coupon
      final updatedUsedBy = List<String>.from(coupon.usedBy)..add(userId);
      _allCoupons[couponIndex] = coupon.copyWith(
        usedBy: updatedUsedBy,
        isActive: coupon.isSingleUse ? false : coupon.isActive,
      );

      Fluttertoast.showToast(msg: 'Coupon redeemed successfully!');
    } catch (e) {
      print('Error redeeming coupon: $e');
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Coupon? getCouponByBarcodeData(String barcodeData) {
    try {
      return _allCoupons.firstWhere((coupon) => coupon.barcodeData == barcodeData);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshCoupons() async {
    // In a local system, just notify listeners
    notifyListeners();
    Fluttertoast.showToast(msg: 'Coupons refreshed!');
  }

  // Get analytics data
  int get totalActiveCoupons => _allCoupons.where((c) => c.isActive).length;
  int get totalUsedCoupons => _allCoupons.where((c) => c.usedBy.isNotEmpty).length;
  int get totalExpiredCoupons => _allCoupons.where((c) => c.validUntil.isBefore(DateTime.now())).length;
}