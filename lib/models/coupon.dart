
import 'package:cloud_firestore/cloud_firestore.dart';

enum CouponCategory {
  food,
  spa,
  room,
  entertainment,
  general, other,
}

class Coupon {
  final String id;
  final String title;
  final String description;
  final double discount;
  final CouponCategory category;
  final DateTime validUntil;
  final String barcodeData;
  final bool isActive;
  final List<String> usedBy;
  final bool isSingleUse;
  final String? createdByUid;
  final DateTime? createdAt;

  Coupon({
    required this.id,
    required this.title,
    required this.description,
    required this.discount,
    required this.category,
    required this.validUntil,
    required this.barcodeData,
    required this.isActive,
    required this.usedBy,
    required this.isSingleUse,
    this.createdByUid,
    this.createdAt,
  });

  String get formattedValidUntil {
    return "${validUntil.day}/${validUntil.month}/${validUntil.year}";
  }

  Coupon copyWith({
    String? id,
    String? title,
    String? description,
    double? discount,
    CouponCategory? category,
    DateTime? validUntil,
    String? barcodeData,
    bool? isActive,
    List<String>? usedBy,
    bool? isSingleUse,
    String? createdByUid,
    DateTime? createdAt,
  }) {
    return Coupon(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      discount: discount ?? this.discount,
      category: category ?? this.category,
      validUntil: validUntil ?? this.validUntil,
      barcodeData: barcodeData ?? this.barcodeData,
      isActive: isActive ?? this.isActive,
      usedBy: usedBy ?? this.usedBy,
      isSingleUse: isSingleUse ?? this.isSingleUse,
      createdByUid: createdByUid ?? this.createdByUid,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static void fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {}
}