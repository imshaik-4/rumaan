import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/app_user.dart';
import '../models/coupon.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(uid).set(userData, SetOptions(merge: true));
      Fluttertoast.showToast(msg: 'User created successfully!'); // Added toast for consistency
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error creating user: $e');
    }
  }

  Future<AppUser?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error getting user: $e');
    }
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      Fluttertoast.showToast(msg: 'User updated successfully!'); // Added toast for consistency
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error updating user: $e');
    }
  }

  // NEW: Get all users
  Stream<List<AppUser>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
    });
  }

  // Coupon operations
  Future<void> createCoupon(Coupon coupon) async {
    try {
      await _firestore.collection('coupons').doc(coupon.id).set(coupon.toFirestore());
      Fluttertoast.showToast(msg: 'Coupon created successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error creating coupon: $e');
    }
  }

  Stream<List<Coupon>> getCoupons() {
    return _firestore.collection('coupons').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Coupon.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateCoupon(Coupon coupon) async {
    try {
      await _firestore.collection('coupons').doc(coupon.id).update(coupon.toFirestore());
      Fluttertoast.showToast(msg: 'Coupon updated successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error updating coupon: $e');
    }
  }

  Future<void> deleteCoupon(String couponId) async {
    try {
      await _firestore.collection('coupons').doc(couponId).delete();
      Fluttertoast.showToast(msg: 'Coupon deleted successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error deleting coupon: $e');
    }
  }

  // Analytics operations (simplified for this example)
  Stream<int> getTotalUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getActiveCouponsCount() {
    return _firestore.collection('coupons').where('isActive', isEqualTo: true).snapshots().map((snapshot) => snapshot.docs.length);
  }
}
