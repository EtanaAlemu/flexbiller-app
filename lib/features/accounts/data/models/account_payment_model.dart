import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_payment.dart';

part 'account_payment_model.g.dart';

@JsonSerializable()
class AccountPaymentModel {
  final String id;
  @JsonKey(name: 'accountId')
  final String accountId;
  @JsonKey(name: 'paymentType')
  final String paymentType;
  @JsonKey(name: 'paymentStatus')
  final String paymentStatus;
  final double amount;
  final String currency;
  @JsonKey(name: 'paymentMethodId')
  final String paymentMethodId;
  @JsonKey(name: 'paymentMethodName')
  final String? paymentMethodName;
  @JsonKey(name: 'paymentMethodType')
  final String? paymentMethodType;
  @JsonKey(name: 'transactionId')
  final String? transactionId;
  @JsonKey(name: 'referenceNumber')
  final String? referenceNumber;
  final String? description;
  final String? notes;
  @JsonKey(name: 'paymentDate')
  final DateTime paymentDate;
  @JsonKey(name: 'processedDate')
  final DateTime? processedDate;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'failureReason')
  final String? failureReason;
  @JsonKey(name: 'gatewayResponse')
  final String? gatewayResponse;
  @JsonKey(name: 'isRefunded')
  final bool isRefunded;
  @JsonKey(name: 'refundedAmount')
  final double? refundedAmount;
  @JsonKey(name: 'refundedDate')
  final DateTime? refundedDate;
  @JsonKey(name: 'refundReason')
  final String? refundReason;

  const AccountPaymentModel({
    required this.id,
    required this.accountId,
    required this.paymentType,
    required this.paymentStatus,
    required this.amount,
    required this.currency,
    required this.paymentMethodId,
    this.paymentMethodName,
    this.paymentMethodType,
    this.transactionId,
    this.referenceNumber,
    this.description,
    this.notes,
    required this.paymentDate,
    this.processedDate,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
    this.failureReason,
    this.gatewayResponse,
    required this.isRefunded,
    this.refundedAmount,
    this.refundedDate,
    this.refundReason,
  });

  factory AccountPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$AccountPaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountPaymentModelToJson(this);

  factory AccountPaymentModel.fromEntity(AccountPayment entity) {
    return AccountPaymentModel(
      id: entity.id,
      accountId: entity.accountId,
      paymentType: entity.paymentType,
      paymentStatus: entity.paymentStatus,
      amount: entity.amount,
      currency: entity.currency,
      paymentMethodId: entity.paymentMethodId,
      paymentMethodName: entity.paymentMethodName,
      paymentMethodType: entity.paymentMethodType,
      transactionId: entity.transactionId,
      referenceNumber: entity.referenceNumber,
      description: entity.description,
      notes: entity.notes,
      paymentDate: entity.paymentDate,
      processedDate: entity.processedDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      metadata: entity.metadata,
      failureReason: entity.failureReason,
      gatewayResponse: entity.gatewayResponse,
      isRefunded: entity.isRefunded,
      refundedAmount: entity.refundedAmount,
      refundedDate: entity.refundedDate,
      refundReason: entity.refundReason,
    );
  }

  AccountPayment toEntity() {
    return AccountPayment(
      id: id,
      accountId: accountId,
      paymentType: paymentType,
      paymentStatus: paymentStatus,
      amount: amount,
      currency: currency,
      paymentMethodId: paymentMethodId,
      paymentMethodName: paymentMethodName,
      paymentMethodType: paymentMethodType,
      transactionId: transactionId,
      referenceNumber: referenceNumber,
      description: description,
      notes: notes,
      paymentDate: paymentDate,
      processedDate: processedDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      metadata: metadata,
      failureReason: failureReason,
      gatewayResponse: gatewayResponse,
      isRefunded: isRefunded,
      refundedAmount: refundedAmount,
      refundedDate: refundedDate,
      refundReason: refundReason,
    );
  }
}
