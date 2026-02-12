import 'package:samsung_admin_main_new/app/models/user_model.dart';

class ProductOrderModel {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final int pointsPaid;
  final String? shippingAddress;
  final String? shippingCity;
  final String? shippingZip;
  final String? shippingPhone;
  final String status;
  final DateTime orderedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? deletedAt;
  final UserModel? user;

  ProductOrderModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.pointsPaid,
    this.shippingAddress,
    this.shippingCity,
    this.shippingZip,
    this.shippingPhone,
    required this.status,
    required this.orderedAt,
    this.shippedAt,
    this.deliveredAt,
    this.deletedAt,
    this.user,
  });

  factory ProductOrderModel.fromJson(Map<String, dynamic> json) {
    return ProductOrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int? ?? 0,
      pointsPaid: json['points_paid'] as int? ?? 0,
      shippingAddress: json['shipping_address'] as String?,
      shippingCity: json['shipping_city'] as String?,
      shippingZip: json['shipping_zip'] as String?,
      shippingPhone: json['shipping_phone'] as String?,
      status: json['status'] as String? ?? 'pending',
      orderedAt: DateTime.parse(json['ordered_at'] as String),
      shippedAt: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      user: json['users'] != null
          ? UserModel.fromJson(json['users'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'points_paid': pointsPaid,
      'shipping_address': shippingAddress,
      'shipping_city': shippingCity,
      'shipping_zip': shippingZip,
      'shipping_phone': shippingPhone,
      'status': status,
      'ordered_at': orderedAt.toIso8601String(),
      'shipped_at': shippedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'users': user?.toJson(),
    };
  }
}
