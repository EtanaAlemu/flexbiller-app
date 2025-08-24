import 'package:equatable/equatable.dart';

class AccountPaymentMethod extends Equatable {
  final String id;
  final String accountId;
  final String paymentMethodType;
  final String paymentMethodName;
  final String? cardLastFourDigits;
  final String? cardBrand;
  final String? cardExpiryMonth;
  final String? cardExpiryYear;
  final String? bankName;
  final String? bankAccountLastFourDigits;
  final String? bankAccountType;
  final String? paypalEmail;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const AccountPaymentMethod({
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

  @override
  List<Object?> get props => [
        id,
        accountId,
        paymentMethodType,
        paymentMethodName,
        cardLastFourDigits,
        cardBrand,
        cardExpiryMonth,
        cardExpiryYear,
        bankName,
        bankAccountLastFourDigits,
        bankAccountType,
        paypalEmail,
        isDefault,
        isActive,
        createdAt,
        updatedAt,
        metadata,
      ];

  AccountPaymentMethod copyWith({
    String? id,
    String? accountId,
    String? paymentMethodType,
    String? paymentMethodName,
    String? cardLastFourDigits,
    String? cardBrand,
    String? cardExpiryMonth,
    String? cardExpiryYear,
    String? bankName,
    String? bankAccountLastFourDigits,
    String? bankAccountType,
    String? paypalEmail,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return AccountPaymentMethod(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      paymentMethodType: paymentMethodType ?? this.paymentMethodType,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      cardLastFourDigits: cardLastFourDigits ?? this.cardLastFourDigits,
      cardBrand: cardBrand ?? this.cardBrand,
      cardExpiryMonth: cardExpiryMonth ?? this.cardExpiryMonth,
      cardExpiryYear: cardExpiryYear ?? this.cardExpiryYear,
      bankName: bankName ?? this.bankName,
      bankAccountLastFourDigits: bankAccountLastFourDigits ?? this.bankAccountLastFourDigits,
      bankAccountType: bankAccountType ?? this.bankAccountType,
      paypalEmail: paypalEmail ?? this.paypalEmail,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
