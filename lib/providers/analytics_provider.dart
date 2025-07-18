import 'package:flutter/material.dart';
import 'package:rumaan/firestore_service.dart';


class AnalyticsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  int _totalUsers = 0;
  int _activeCoupons = 0;
  // int _totalLogins = 0; // Requires more complex tracking
  // double _totalSavings = 0.0; // Requires more complex tracking

  int get totalUsers => _totalUsers;
  int get activeCoupons => _activeCoupons;
  // int get totalLogins => _totalLogins;
  // double get totalSavings => _totalSavings;

  AnalyticsProvider() {
    _firestoreService.getTotalUsers().listen((count) {
      _totalUsers = count;
      notifyListeners();
    });

    _firestoreService.getActiveCouponsCount().listen((count) {
      _activeCoupons = count;
      notifyListeners();
    });
  }
}
