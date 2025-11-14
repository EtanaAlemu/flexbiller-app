// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_kpi_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardKPIModel _$DashboardKPIModelFromJson(Map<String, dynamic> json) =>
    DashboardKPIModel(
      activeSubscriptions: KPIMetricModel.fromJson(
        json['activeSubscriptions'] as Map<String, dynamic>,
      ),
      pendingInvoices: KPIMetricModel.fromJson(
        json['pendingInvoices'] as Map<String, dynamic>,
      ),
      failedPayments: KPIMetricModel.fromJson(
        json['failedPayments'] as Map<String, dynamic>,
      ),
      monthlyRevenue: RevenueKPIMetricModel.fromJson(
        json['monthlyRevenue'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$DashboardKPIModelToJson(DashboardKPIModel instance) =>
    <String, dynamic>{
      'activeSubscriptions': instance.activeSubscriptions.toJson(),
      'pendingInvoices': instance.pendingInvoices.toJson(),
      'failedPayments': instance.failedPayments.toJson(),
      'monthlyRevenue': instance.monthlyRevenue.toJson(),
    };

KPIMetricModel _$KPIMetricModelFromJson(Map<String, dynamic> json) =>
    KPIMetricModel(
      value: (json['value'] as num?)?.toInt() ?? 0,
      change: json['change'] as String? ?? '0.00',
      changePercent: json['changePercent'] as String? ?? '0.00',
    );

Map<String, dynamic> _$KPIMetricModelToJson(KPIMetricModel instance) =>
    <String, dynamic>{
      'value': instance.value,
      'change': instance.change,
      'changePercent': instance.changePercent,
    };

RevenueKPIMetricModel _$RevenueKPIMetricModelFromJson(
  Map<String, dynamic> json,
) => RevenueKPIMetricModel(
  value: json['value'] as String? ?? '0.00',
  change: json['change'] as String? ?? '0.00',
  changePercent: json['changePercent'] as String? ?? '0.00',
  currency: json['currency'] as String? ?? 'USD',
);

Map<String, dynamic> _$RevenueKPIMetricModelToJson(
  RevenueKPIMetricModel instance,
) => <String, dynamic>{
  'value': instance.value,
  'change': instance.change,
  'changePercent': instance.changePercent,
  'currency': instance.currency,
};
