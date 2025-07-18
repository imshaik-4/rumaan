import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rumaan/firestore_service.dart';
import 'package:uuid/uuid.dart';

import '../models/coupon.dart';
import '../models/app_user.dart'; // Import AppUser for user role check

class CouponProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Coupon> _allCoupons = [];
  bool _isLoading = false;

  List<Coupon> get allCoupons => _allCoupons;
  bool get isLoading => _isLoading;

  CouponProvider() {
    _firestoreService.getCoupons().listen((coupons) {
      _allCoupons = coupons;
      notifyListeners();
    });
  }

  List<Coupon> getAvailableCoupons(AppUser? user) {
    if (user == null) return [];
    return _allCoupons.where((coupon) {
      // Coupon is active and not used by the current user
      return coupon.isActive && !coupon.usedBy.contains(user.uid) && coupon.validUntil.isAfter(DateTime.now());
    }).toList();
  }

  List<Coupon> getRedeemedCoupons(AppUser? user) {
    if (user == null) return [];
    return _allCoupons.where((coupon) {
      // Coupon is used by the current user
      return coupon.usedBy.contains(user.uid);
    }).toList();
  }

  Future<void> createCoupon({
    required String title,
    required String description,
    required double discount,
    required CouponCategory category,
    required DateTime validUntil,
    required bool isSingleUse, // Add this line
  }) async {
    _isLoading = true;
    notifyListeners();
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
      isSingleUse: isSingleUse, // Add this line
    );
    await _firestoreService.createCoupon(newCoupon);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateCouponStatus(Coupon coupon, bool isActive) async {
    _isLoading = true;
    notifyListeners();
    coupon.isActive = isActive;
    await _firestoreService.updateCoupon(coupon);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCoupon(String couponId) async {
    _isLoading = true;
    notifyListeners();
    await _firestoreService.deleteCoupon(couponId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> redeemCoupon(String couponId, String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final couponRef = FirebaseFirestore.instance.collection('coupons').doc(couponId);
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot couponDoc = await transaction.get(couponRef);
        DocumentSnapshot userDoc = await transaction.get(userRef);

        if (!couponDoc.exists || !userDoc.exists) {
          throw Exception("Coupon or User does not exist!");
        }

        Coupon coupon = Coupon.fromFirestore(couponDoc);
        AppUser appUser = AppUser.fromFirestore(userDoc);

        if (coupon.usedBy.contains(userId)) {
          Fluttertoast.showToast(msg: 'Coupon already redeemed by this user.');
          return;
        }

        // Add user to usedBy list
        List<String> updatedUsedBy = List.from(coupon.usedBy)..add(userId);
        transaction.update(couponRef, {'usedBy': updatedUsedBy});

        // If it's a single-use coupon and this is the first redemption, deactivate it globally
        if (coupon.isSingleUse && coupon.usedBy.isEmpty) { // Check if it's the first use
          transaction.update(couponRef, {'isActive': false});
        }

        // Add coupon to user's redeemedCoupons list
        List<String> updatedRedeemedCoupons = List.from(appUser.redeemedCoupons)..add(couponId);
        transaction.update(userRef, {'redeemedCoupons': updatedRedeemedCoupons});

        Fluttertoast.showToast(msg: 'Coupon redeemed successfully!');
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error redeeming coupon: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
