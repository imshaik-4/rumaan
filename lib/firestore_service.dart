import 'package:fluttertoast/fluttertoast.dart';
import '../models/app_user.dart';
import '../models/coupon.dart';

class FirestoreService {
  // Local storage for users and coupons
  static List<AppUser> _users = [];
  static List<Coupon> _coupons = [];
  static bool _initialized = false;

  FirestoreService() {
    if (!_initialized) {
      _initializeSampleData();
      _initialized = true;
    }
  }

  // Initialize with sample data
  void _initializeSampleData() {
    _users = [
      AppUser(
        uid: 'user1',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        role: UserRole.customer,
        redeemedCoupons: ['coupon1', 'coupon2'],
      ),
      AppUser(
        uid: 'user2',
        email: 'jane.smith@example.com',
        phoneNumber: '+1234567891',
        role: UserRole.customer,
        redeemedCoupons: ['coupon1'],
      ),
      AppUser(
        uid: 'user3',
        email: 'bob.wilson@example.com',
        phoneNumber: '+1234567892',
        role: UserRole.customer,
        redeemedCoupons: ['coupon1', 'coupon2', 'coupon3'],
      ),
      AppUser(
        uid: 'user4',
        email: 'alice.brown@example.com',
        phoneNumber: '+1234567893',
        role: UserRole.customer,
        redeemedCoupons: [],
      ),
      AppUser(
        uid: 'user5',
        email: 'charlie.davis@example.com',
        phoneNumber: '+1234567894',
        role: UserRole.customer,
        redeemedCoupons: ['coupon2', 'coupon3'],
      ),
      AppUser(
        uid: 'admin1',
        email: 'admin@rumaan.com',
        phoneNumber: '+1234567895',
        role: UserRole.admin,
        redeemedCoupons: [],
      ),
      AppUser(
        uid: 'receptionist1',
        email: 'reception@rumaan.com',
        phoneNumber: '+1234567896',
        role: UserRole.receptionist,
        redeemedCoupons: [],
      ),
    ];

    // Initialize with some sample coupons
    _coupons = [
      Coupon(
        id: 'coupon1',
        title: '20% Off Spa Treatment',
        description: 'Enjoy a relaxing spa session with 20% discount on all treatments.',
        discount: 20.0,
        category: CouponCategory.spa,
        validUntil: DateTime.now().add(const Duration(days: 30)),
        barcodeData: 'SPA20OFF',
        isActive: true,
        usedBy: ['user1', 'user2', 'user3'],
        isSingleUse: false,
        createdByUid: 'admin1',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Coupon(
        id: 'coupon2',
        title: '15% Off Restaurant',
        description: 'Get 15% discount on all food items at our restaurant.',
        discount: 15.0,
        category: CouponCategory.food,
        validUntil: DateTime.now().add(const Duration(days: 45)),
        barcodeData: 'FOOD15OFF',
        isActive: true,
        usedBy: ['user1', 'user5'],
        isSingleUse: false,
        createdByUid: 'admin1',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Coupon(
        id: 'coupon3',
        title: '30% Off Room Upgrade',
        description: 'Upgrade your room with 30% discount on premium rooms.',
        discount: 30.0,
        category: CouponCategory.room,
        validUntil: DateTime.now().add(const Duration(days: 60)),
        barcodeData: 'ROOM30OFF',
        isActive: true,
        usedBy: ['user3', 'user5'],
        isSingleUse: false,
        createdByUid: 'admin1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // User operations
  Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      final existingUserIndex = _users.indexWhere((user) => user.uid == uid);
      
      final newUser = AppUser(
        uid: uid,
        email: userData['email'],
        phoneNumber: userData['phoneNumber'],
        role: _parseUserRole(userData['role']),
        redeemedCoupons: List<String>.from(userData['redeemedCoupons'] ?? []),
      );

      if (existingUserIndex != -1) {
        _users[existingUserIndex] = newUser;
      } else {
        _users.add(newUser);
      }
      
      Fluttertoast.showToast(msg: 'User created successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error creating user: $e');
    }
  }

  Future<AppUser?> getUser(String uid) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));
      
      final user = _users.firstWhere(
        (user) => user.uid == uid,
        orElse: () => throw Exception('User not found'),
      );
      return user;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      final userIndex = _users.indexWhere((user) => user.uid == uid);
      if (userIndex != -1) {
        final existingUser = _users[userIndex];
        _users[userIndex] = AppUser(
          uid: uid,
          email: data['email'] ?? existingUser.email,
          phoneNumber: data['phoneNumber'] ?? existingUser.phoneNumber,
          role: data['role'] != null ? _parseUserRole(data['role']) : existingUser.role,
          redeemedCoupons: data['redeemedCoupons'] != null 
              ? List<String>.from(data['redeemedCoupons']) 
              : existingUser.redeemedCoupons,
        );
        Fluttertoast.showToast(msg: 'User updated successfully!');
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error updating user: $e');
    }
  }

  // Get all users as a stream
  Stream<List<AppUser>> getAllUsers() {
    return Stream.periodic(const Duration(seconds: 1), (count) => List<AppUser>.from(_users));
  }

  // Get all users as a future (for one-time fetch)
  Future<List<AppUser>> getAllUsersOnce() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<AppUser>.from(_users);
  }

  // Coupon operations
  Future<void> createCoupon(Coupon coupon) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      _coupons.add(coupon);
      Fluttertoast.showToast(msg: 'Coupon created successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error creating coupon: $e');
    }
  }

  Stream<List<Coupon>> getCoupons() {
    return Stream.periodic(const Duration(seconds: 1), (count) => List<Coupon>.from(_coupons));
  }

  Future<List<Coupon>> getCouponsOnce() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<Coupon>.from(_coupons);
  }

  Future<void> updateCoupon(Coupon coupon) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      final couponIndex = _coupons.indexWhere((c) => c.id == coupon.id);
      if (couponIndex != -1) {
        _coupons[couponIndex] = coupon;
        Fluttertoast.showToast(msg: 'Coupon updated successfully!');
      } else {
        throw Exception('Coupon not found');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error updating coupon: $e');
    }
  }

  Future<void> deleteCoupon(String couponId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
     // final removed = _coupons.removeWhere((coupon) => coupon.id == couponId);
    //  if (removed 0) {
        Fluttertoast.showToast(msg: 'Coupon deleted successfully!');
    //  } else {
    //    throw Exception('Coupon not found');
   //   }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error deleting coupon: $e');
    }
  }

  // Analytics operations
  Stream<int> getTotalUsers() {
    return Stream.periodic(const Duration(seconds: 1), (count) => _users.length);
  }

  Future<int> getTotalUsersOnce() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _users.length;
  }

  Stream<int> getActiveCouponsCount() {
    return Stream.periodic(const Duration(seconds: 1), (count) {
      return _coupons.where((coupon) => coupon.isActive).length;
    });
  }

  Future<int> getActiveCouponsCountOnce() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _coupons.where((coupon) => coupon.isActive).length;
  }

  // Additional analytics methods
  Future<int> getTotalRedeemedCoupons() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _coupons.fold<int>(0, (sum, coupon) => sum + coupon.usedBy.length);
  }

  Future<int> getActiveUsersCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _users.where((user) => user.redeemedCoupons.isNotEmpty).length;
  }

  Future<double> getTotalSavings() async {
    await Future.delayed(const Duration(milliseconds: 100));
    double totalSavings = 0;
    for (var coupon in _coupons) {
      totalSavings += coupon.usedBy.length * (coupon.discount * 10); // Assuming $10 base value per discount %
    }
    return totalSavings;
  }

  // Search and filter methods
  Future<List<AppUser>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (query.isEmpty) return _users;
    
    return _users.where((user) {
      return user.email?.toLowerCase().contains(query.toLowerCase()) == true ||
             user.phoneNumber?.contains(query) == true;
    }).toList();
  }

  Future<List<Coupon>> searchCoupons(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (query.isEmpty) return _coupons;
    
    return _coupons.where((coupon) {
      return coupon.title.toLowerCase().contains(query.toLowerCase()) ||
             coupon.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<List<AppUser>> getUsersByRole(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _users.where((user) => user.role == role).toList();
  }

  Future<List<Coupon>> getCouponsByCategory(CouponCategory category) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _coupons.where((coupon) => coupon.category == category).toList();
  }

  Future<List<Coupon>> getActiveCoupons() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _coupons.where((coupon) => 
      coupon.isActive && coupon.validUntil.isAfter(DateTime.now())
    ).toList();
  }

  Future<List<Coupon>> getExpiredCoupons() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _coupons.where((coupon) => 
      coupon.validUntil.isBefore(DateTime.now())
    ).toList();
  }

  // Utility methods
  UserRole _parseUserRole(String? roleString) {
    if (roleString == null) return UserRole.customer;
    
    try {
      return UserRole.values.firstWhere(
        (role) => role.toString() == roleString,
        orElse: () => UserRole.customer,
      );
    } catch (e) {
      return UserRole.customer;
    }
  }

  // Method to add sample data for testing
  void addSampleUser(AppUser user) {
    _users.add(user);
  }

  void addSampleCoupon(Coupon coupon) {
    _coupons.add(coupon);
  }

  // Method to clear all data (useful for testing)
  void clearAllData() {
    _users.clear();
    _coupons.clear();
  }

  // Method to reset to initial sample data
  void resetToSampleData() {
    _users.clear();
    _coupons.clear();
    _initializeSampleData();
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final totalUsers = _users.length;
    final activeUsers = _users.where((user) => user.redeemedCoupons.isNotEmpty).length;
    final customerUsers = _users.where((user) => user.role == UserRole.customer).length;
    final adminUsers = _users.where((user) => user.role == UserRole.admin).length;
    final receptionistUsers = _users.where((user) => user.role == UserRole.receptionist).length;
    
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'customerUsers': customerUsers,
      'adminUsers': adminUsers,
      'receptionistUsers': receptionistUsers,
      'inactiveUsers': totalUsers - activeUsers,
    };
  }

  // Get coupon statistics
  Future<Map<String, dynamic>> getCouponStatistics() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final totalCoupons = _coupons.length;
    final activeCoupons = _coupons.where((c) => c.isActive).length;
    final expiredCoupons = _coupons.where((c) => c.validUntil.isBefore(DateTime.now())).length;
    final totalRedemptions = _coupons.fold<int>(0, (sum, coupon) => sum + coupon.usedBy.length);
    
    final categoryStats = <String, int>{};
    for (var category in CouponCategory.values) {
      categoryStats[category.toString().split('.').last] = 
          _coupons.where((c) => c.category == category).length;
    }
    
    return {
      'totalCoupons': totalCoupons,
      'activeCoupons': activeCoupons,
      'inactiveCoupons': totalCoupons - activeCoupons,
      'expiredCoupons': expiredCoupons,
      'totalRedemptions': totalRedemptions,
      'categoryStats': categoryStats,
    };
  }
}