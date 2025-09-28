import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final String id;
  @JsonKey(name: 'productName')
  final String productName;
  @JsonKey(name: 'productDescription')
  final String productDescription;
  @JsonKey(name: 'tenantId')
  final String tenantId;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;
  @JsonKey(name: 'createdBy')
  final String createdBy;
  @JsonKey(name: 'updatedBy')
  final String updatedBy;
  @JsonKey(name: 'userId')
  final String? userId;

  ProductModel({
    required this.id,
    required this.productName,
    required this.productDescription,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    this.userId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  /// Custom toJson method that excludes userId field for API requests
  /// The server doesn't accept userId field in product requests
  Map<String, dynamic> toJsonForApi() {
    final json = _$ProductModelToJson(this);
    json.remove('userId'); // Remove userId field as server doesn't accept it
    return json;
  }

  Product toEntity() {
    return Product(
      id: id,
      productName: productName,
      productDescription: productDescription,
      tenantId: tenantId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      productName: product.productName,
      productDescription: product.productDescription,
      tenantId: product.tenantId,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      createdBy: product.createdBy,
      updatedBy: product.updatedBy,
    );
  }
}
