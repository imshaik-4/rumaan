import 'package:cloud_firestore/cloud_firestore.dart';

enum CouponCategory {
  dining,
  spa,
  accommodation,
  activity,
  other,
}

class Coupon {
  String id;
  String title;
  String description;
  String discount;
  DateTime validUntil;
  bool isUsed;
  bool isActive;
  String qrCode;
  CouponCategory category;
  DateTime createdAt;
  int usageCount;

  Coupon({
    required this.id,
    required this.title,
    required this.description,
    required this.discount,
    required this.validUntil,
    this.isUsed = false,
    this.isActive = true,
    required this.qrCode,
    required this.category,
    required this.createdAt,
    this.usageCount = 0,
  });

  // Factory constructor to create a Coupon from a Firestore document
  factory Coupon.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Coupon(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      discount: data['discount'] ?? '',
      validUntil: (data['validUntil'] as Timestamp).toDate(),
      isUsed: data['isUsed'] ?? false,
      isActive: data['isActive'] ?? true,
      qrCode: data['qrCode'] ?? '',
      category: CouponCategory.values.firstWhere(
        (e) => e.toString().split('.').last == (data['category'] ?? 'other'),
        orElse: () => CouponCategory.other,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      usageCount: data['usageCount'] ?? 0,
    );
  }

  // Method to convert a Coupon object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'discount': discount,
      'validUntil': Timestamp.fromDate(validUntil),
      'isUsed': isUsed,
      'isActive': isActive,
      'qrCode': qrCode,
      'category': category.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'usageCount': usageCount,
    };
  }

  Coupon? copyWith({required bool isUsed}) {}
}
