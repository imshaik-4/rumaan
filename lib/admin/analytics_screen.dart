import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsData {
  final int totalUsers;
  final int totalLogins;
  final int totalCoupons;
  final int usedCoupons;
  final int activeCoupons;
  final int todayLogins;
  final int thisWeekSignups;
  final double totalSavings; // Changed to double for currency

  AnalyticsData({
    this.totalUsers = 0,
    this.totalLogins = 0,
    this.totalCoupons = 0,
    this.usedCoupons = 0,
    this.activeCoupons = 0,
    this.todayLogins = 0,
    this.thisWeekSignups = 0,
    this.totalSavings = 0.0,
  });

  factory AnalyticsData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AnalyticsData(
      totalUsers: data['totalUsers'] as int? ?? 0,
      totalLogins: data['totalLogins'] as int? ?? 0,
      totalCoupons: data['totalCoupons'] as int? ?? 0,
      usedCoupons: data['usedCoupons'] as int? ?? 0,
      activeCoupons: data['activeCoupons'] as int? ?? 0,
      todayLogins: data['todayLogins'] as int? ?? 0,
      thisWeekSignups: data['thisWeekSignups'] as int? ?? 0,
      totalSavings: (data['totalSavings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AnalyticsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AnalyticsData _analyticsData = AnalyticsData();
  bool _isLoading = false;
  String? _errorMessage;

  AnalyticsData get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AnalyticsProvider() {
    _listenToAnalytics();
  }

  void _listenToAnalytics() {
    _isLoading = true;
    notifyListeners();

    _firestore.collection('analytics').doc('stats').snapshots().listen(
      (snapshot) {
        if (snapshot.exists) {
          _analyticsData = AnalyticsData.fromFirestore(snapshot);
        } else {
          _analyticsData = AnalyticsData(); // Reset if document doesn't exist
        }
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load analytics: $error';
        print('Error loading analytics: $error');
        notifyListeners();
      },
    );
  }

  // Method to update analytics (e.g., when a user signs up or a coupon is used)
  Future<void> updateAnalytics({
    int? totalUsersIncrement,
    int? totalLoginsIncrement,
    int? usedCouponsIncrement,
    double? totalSavingsIncrement,
    int? thisWeekSignupsIncrement,
    int? activeCouponsChange, required int totalCouponsIncrement, // Use this for +/- active coupons
  }) async {
    final docRef = _firestore.collection('analytics').doc('stats');
    Map<String, dynamic> updates = {
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    if (totalUsersIncrement != null) updates['totalUsers'] = FieldValue.increment(totalUsersIncrement);
    if (totalLoginsIncrement != null) updates['totalLogins'] = FieldValue.increment(totalLoginsIncrement);
    if (usedCouponsIncrement != null) updates['usedCoupons'] = FieldValue.increment(usedCouponsIncrement);
    if (totalSavingsIncrement != null) updates['totalSavings'] = FieldValue.increment(totalSavingsIncrement);
    if (thisWeekSignupsIncrement != null) updates['thisWeekSignups'] = FieldValue.increment(thisWeekSignupsIncrement);
    if (activeCouponsChange != null) updates['activeCoupons'] = FieldValue.increment(activeCouponsChange);

    try {
      await docRef.set(updates, SetOptions(merge: true));
    } catch (e) {
      print('Error updating analytics: $e');
      _errorMessage = 'Failed to update analytics: $e';
      notifyListeners();
    }
  }
}
