// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_status_overview_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentStatusOverviewModel _$PaymentStatusOverviewModelFromJson(
  Map<String, dynamic> json,
) => PaymentStatusOverviewModel(
  month: json['month'] as String,
  paidInvoices: (json['paidInvoices'] as num).toInt(),
  unpaidInvoices: (json['unpaidInvoices'] as num).toInt(),
);

Map<String, dynamic> _$PaymentStatusOverviewModelToJson(
  PaymentStatusOverviewModel instance,
) => <String, dynamic>{
  'month': instance.month,
  'paidInvoices': instance.paidInvoices,
  'unpaidInvoices': instance.unpaidInvoices,
};

PaymentStatusOverviewsModel _$PaymentStatusOverviewsModelFromJson(
  Map<String, dynamic> json,
) => PaymentStatusOverviewsModel(
  overviews: (json['overviews'] as List<dynamic>)
      .map(
        (e) => PaymentStatusOverviewModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  year: (json['year'] as num).toInt(),
);

Map<String, dynamic> _$PaymentStatusOverviewsModelToJson(
  PaymentStatusOverviewsModel instance,
) => <String, dynamic>{
  'overviews': instance.overviews.map((e) => e.toJson()).toList(),
  'year': instance.year,
};
