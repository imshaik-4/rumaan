import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class AnalyticsData {
  int totalUsers;
  int totalLogins;
  int totalCoupons;
  int activeCoupons;
  int usedCoupons;
  double totalSavings;
  int thisWeekSignups;
  int todayLogins;

  AnalyticsData({
    this.totalUsers = 0,
    this.totalLogins = 0,
    this.totalCoupons = 0,
    this.activeCoupons = 0,
    this.usedCoupons = 0,
    this.totalSavings = 0.0,
    this.thisWeekSignups = 0,
    this.todayLogins = 0,
  });

  factory AnalyticsData.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AnalyticsData(
      totalUsers: data['totalUsers'] ?? 0,
      totalLogins: data['totalLogins'] ?? 0,
      totalCoupons: data['totalCoupons'] ?? 0,
      activeCoupons: data['activeCoupons'] ?? 0,
      usedCoupons: data['usedCoupons'] ?? 0,
      totalSavings: (data['totalSavings'] ?? 0.0).toDouble(),
      thisWeekSignups: data['thisWeekSignups'] ?? 0,
      todayLogins: data['todayLogins'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalUsers': totalUsers,
      'totalLogins': totalLogins,
      'totalCoupons': totalCoupons,
      'activeCoupons': activeCoupons,
      'usedCoupons': usedCoupons,
      'totalSavings': totalSavings,
      'thisWeekSignups': thisWeekSignups,
      'todayLogins': todayLogins,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}

class AnalyticsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  AnalyticsData _analyticsData = AnalyticsData();
  bool _isLoading = false;

  AnalyticsData get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;

  AnalyticsProvider() {
    _logger.d('AnalyticsProvider: Initializing and fetching analytics.');
    _fetchAnalytics();
  }

  get analytics => null;

  List<Map<String, dynamic>> get weeklyData => [] ;

  get categoryData => null;

  get recentActivity => null;

  Future<void> _fetchAnalytics() async {
    _isLoading = true;
    notifyListeners();
    try {
      _firestore.collection('analytics').doc('stats').snapshots().listen((snapshot) {
        if (snapshot.exists) {
          _analyticsData = AnalyticsData.fromFirestore(snapshot);
          _logger.d('AnalyticsProvider: Fetched analytics data.');
        } else {
          _analyticsData = AnalyticsData(); // Initialize if document doesn't exist
          _firestore.collection('analytics').doc('stats').set(_analyticsData.toFirestore());
          _logger.d('AnalyticsProvider: Analytics document did not exist, created new one.');
        }
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _logger.e('AnalyticsProvider: Error fetching analytics: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAnalytics({
    int totalUsersIncrement = 0,
    int totalLoginsIncrement = 0,
    int totalCouponsIncrement = 0,
    int activeCouponsChange = 0,
    int usedCouponsIncrement = 0,
    double totalSavingsIncrement = 0.0,
    int thisWeekSignupsIncrement = 0,
    int todayLoginsIncrement = 0,
  }) async {
    try {
      final docRef = _firestore.collection('analytics').doc('stats');
      await docRef.set(
        {
          'totalUsers': FieldValue.increment(totalUsersIncrement),
          'totalLogins': FieldValue.increment(totalLoginsIncrement),
          'totalCoupons': FieldValue.increment(totalCouponsIncrement),
          'activeCoupons': FieldValue.increment(activeCouponsChange),
          'usedCoupons': FieldValue.increment(usedCouponsIncrement),
          'totalSavings': FieldValue.increment(totalSavingsIncrement),
          'thisWeekSignups': FieldValue.increment(thisWeekSignupsIncrement),
          'todayLogins': FieldValue.increment(todayLoginsIncrement),
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      _logger.i('AnalyticsProvider: Updated analytics data.');
    } catch (e) {
      _logger.e('AnalyticsProvider: Error updating analytics: $e');
    }
  }

  void loadAnalytics() {}
}
