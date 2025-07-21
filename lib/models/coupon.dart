import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum CouponCategory { food, spa, room, activity, other }

class Coupon {
  final String id;
  final String title;
  final String description;
  final double discount;
  final CouponCategory category;
  final DateTime validUntil;
  final String barcodeData; // Unique string for barcode generation
  bool isActive;
  final List<String> usedBy; // List of user UIDs who have used this coupon
  final bool isSingleUse;

  Coupon({
    required this.id,
    required this.title,
    required this.description,
    required this.discount,
    required this.category,
    required this.validUntil,
    required this.barcodeData,
    this.isActive = true,
    this.usedBy = const [],
    required this.isSingleUse, String? createdByUid,
  });

  factory Coupon.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Coupon(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      category: _stringToCouponCategory(data['category']),
      validUntil: (data['validUntil'] as Timestamp).toDate(),
      barcodeData: data['barcodeData'] ?? '',
      isActive: data['isActive'] ?? true,
      usedBy: List<String>.from(data['usedBy'] ?? []),
      isSingleUse: data['isSingleUse'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'discount': discount,
      'category': category.toString().split('.').last,
      'validUntil': Timestamp.fromDate(validUntil),
      'barcodeData': barcodeData,
      'isActive': isActive,
      'usedBy': usedBy,
      'isSingleUse': isSingleUse,
    };
  }

  String get formattedValidUntil {
    return DateFormat('MMM dd, yyyy').format(validUntil);
  }

  static CouponCategory _stringToCouponCategory(String? categoryString) {
    switch (categoryString) {
      case 'food':
        return CouponCategory.food;
      case 'spa':
        return CouponCategory.spa;
      case 'room':
        return CouponCategory.room;
      case 'activity':
        return CouponCategory.activity;
      default:
        return CouponCategory.other;
    }
  }
}
