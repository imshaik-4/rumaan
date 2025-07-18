import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { customer, admin, receptionist, unknown }

class AppUser {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final UserRole role;
  final List<String> redeemedCoupons; // List of coupon IDs redeemed by this user

  AppUser({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.role = UserRole.unknown,
    this.redeemedCoupons = const [],
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      role: _stringToUserRole(data['role']),
      redeemedCoupons: List<String>.from(data['redeemedCoupons'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
      'redeemedCoupons': redeemedCoupons,
    };
  }

  static UserRole _stringToUserRole(String? roleString) {
    switch (roleString) {
      case 'customer':
        return UserRole.customer;
      case 'admin':
        return UserRole.admin;
      case 'receptionist':
        return UserRole.receptionist;
      default:
        return UserRole.unknown;
    }
  }
}
