import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String productName;
  final String productDescription;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;

  const Product({
    required this.id,
    required this.productName,
    required this.productDescription,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [
    id,
    productName,
    productDescription,
    tenantId,
    createdAt,
    updatedAt,
    createdBy,
    updatedBy,
  ];

  @override
  String toString() {
    return 'Product{id: $id, productName: $productName, productDescription: $productDescription, tenantId: $tenantId, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, updatedBy: $updatedBy}';
  }

  Product copyWith({
    String? id,
    String? productName,
    String? productDescription,
    String? tenantId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Product(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
