import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_payment_method.dart';

part 'account_payment_method_model.g.dart';

@JsonSerializable()
class AccountPaymentMethodModel {
  final String id;
  @JsonKey(name: 'accountId')
  final String accountId;
  @JsonKey(name: 'paymentMethodType')
  final String paymentMethodType;
  @JsonKey(name: 'paymentMethodName')
  final String paymentMethodName;
  @JsonKey(name: 'cardLastFourDigits')
  final String? cardLastFourDigits;
  @JsonKey(name: 'cardBrand')
  final String? cardBrand;
  @JsonKey(name: 'cardExpiryMonth')
  final String? cardExpiryMonth;
  @JsonKey(name: 'cardExpiryYear')
  final String? cardExpiryYear;
  @JsonKey(name: 'bankName')
  final String? bankName;
  @JsonKey(name: 'bankAccountLastFourDigits')
  final String? bankAccountLastFourDigits;
  @JsonKey(name: 'bankAccountType')
  final String? bankAccountType;
  @JsonKey(name: 'paypalEmail')
  final String? paypalEmail;
  @JsonKey(name: 'isDefault')
  final bool isDefault;
  @JsonKey(name: 'isActive')
  final bool isActive;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const AccountPaymentMethodModel({
    required this.id,
    required this.accountId,
    required this.paymentMethodType,
    required this.paymentMethodName,
    this.cardLastFourDigits,
    this.cardBrand,
    this.cardExpiryMonth,
    this.cardExpiryYear,
    this.bankName,
    this.bankAccountLastFourDigits,
    this.bankAccountType,
    this.paypalEmail,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory AccountPaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$AccountPaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountPaymentMethodModelToJson(this);

  factory AccountPaymentMethodModel.fromEntity(AccountPaymentMethod entity) {
    return AccountPaymentMethodModel(
      id: entity.id,
      accountId: entity.accountId,
      paymentMethodType: entity.paymentMethodType,
      paymentMethodName: entity.paymentMethodName,
      cardLastFourDigits: entity.cardLastFourDigits,
      cardBrand: entity.cardBrand,
      cardExpiryMonth: entity.cardExpiryMonth,
      cardExpiryYear: entity.cardExpiryYear,
      bankName: entity.bankName,
      bankAccountLastFourDigits: entity.bankAccountLastFourDigits,
      bankAccountType: entity.bankAccountType,
      paypalEmail: entity.paypalEmail,
      isDefault: entity.isDefault,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      metadata: entity.metadata,
    );
  }

  AccountPaymentMethod toEntity() {
    return AccountPaymentMethod(
      id: id,
      accountId: accountId,
      paymentMethodType: paymentMethodType,
      paymentMethodName: paymentMethodName,
      cardLastFourDigits: cardLastFourDigits,
      cardBrand: cardBrand,
      cardExpiryMonth: cardExpiryMonth,
      cardExpiryYear: cardExpiryYear,
      bankName: bankName,
      bankAccountLastFourDigits: bankAccountLastFourDigits,
      bankAccountType: bankAccountType,
      paypalEmail: paypalEmail,
      isDefault: isDefault,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      metadata: metadata,
    );
  }
}
