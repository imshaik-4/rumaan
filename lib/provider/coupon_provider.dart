import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumaan/model/coupon.dart';
import 'package:logger/logger.dart';

class CouponProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  List<Coupon> _coupons = [];
  bool _isLoading = false;

  List<Coupon> get coupons => _coupons;
  bool get isLoading => _isLoading;

  CouponProvider() {
    _logger.d('CouponProvider: Initializing and fetching coupons.');
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    _isLoading = true;
    notifyListeners();
    try {
      _firestore.collection('coupons').snapshots().listen((snapshot) {
        _coupons = snapshot.docs
            .map((doc) => Coupon.fromFirestore(doc))
            .toList();
        _isLoading = false;
        notifyListeners();
        _logger.d('CouponProvider: Fetched ${_coupons.length} coupons.');
      });
    } catch (e) {
      _logger.e('CouponProvider: Error fetching coupons: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCoupon(Coupon coupon) async {
    try {
      await _firestore.collection('coupons').doc(coupon.id).set(coupon.toFirestore());
      _logger.i('CouponProvider: Added coupon: ${coupon.title}');
    } catch (e) {
      _logger.e('CouponProvider: Error adding coupon: $e');
    }
  }

  Future<void> updateCoupon(Coupon coupon) async {
    try {
      await _firestore.collection('coupons').doc(coupon.id).update(coupon.toFirestore());
      _logger.i('CouponProvider: Updated coupon: ${coupon.title}');
    } catch (e) {
      _logger.e('CouponProvider: Error updating coupon: $e');
    }
  }

  Future<void> deleteCoupon(String couponId) async {
    try {
      await _firestore.collection('coupons').doc(couponId).delete();
      _logger.i('CouponProvider: Deleted coupon with ID: $couponId');
    } catch (e) {
      _logger.e('CouponProvider: Error deleting coupon: $e');
    }
  }

  Future<Coupon?> getCouponByQrCode(String qrCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('coupons')
          .where('qrCode', isEqualTo: qrCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _logger.d('CouponProvider: Found coupon by QR code: $qrCode');
        return Coupon.fromFirestore(querySnapshot.docs.first);
      }
      _logger.d('CouponProvider: No coupon found for QR code: $qrCode');
      return null;
    } catch (e) {
      _logger.e('CouponProvider: Error getting coupon by QR code: $e');
      return null;
    }
  }

  void loadCoupons() {}

  void toggleCouponStatus(String id) {}

  createCoupon(Coupon coupon) {}
}
