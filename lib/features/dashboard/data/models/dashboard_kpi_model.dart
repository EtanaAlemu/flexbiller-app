import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/dashboard_kpi.dart';

part 'dashboard_kpi_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DashboardKPIModel extends DashboardKPI {
  @JsonKey(name: 'activeSubscriptions')
  @override
  final KPIMetricModel activeSubscriptions;

  @JsonKey(name: 'pendingInvoices')
  @override
  final KPIMetricModel pendingInvoices;

  @JsonKey(name: 'failedPayments')
  @override
  final KPIMetricModel failedPayments;

  @JsonKey(name: 'monthlyRevenue')
  @override
  final RevenueKPIMetricModel monthlyRevenue;

  const DashboardKPIModel({
    required this.activeSubscriptions,
    required this.pendingInvoices,
    required this.failedPayments,
    required this.monthlyRevenue,
  }) : super(
         activeSubscriptions: activeSubscriptions,
         pendingInvoices: pendingInvoices,
         failedPayments: failedPayments,
         monthlyRevenue: monthlyRevenue,
       );

  factory DashboardKPIModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardKPIModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardKPIModelToJson(this);

  // Database operations - keep for local data source compatibility
  Map<String, dynamic> toMap() {
    return {
      'activeSubscriptions': activeSubscriptions.toMap(),
      'pendingInvoices': pendingInvoices.toMap(),
      'failedPayments': failedPayments.toMap(),
      'monthlyRevenue': monthlyRevenue.toMap(),
    };
  }

  factory DashboardKPIModel.fromMap(Map<String, dynamic> map) {
    return DashboardKPIModel(
      activeSubscriptions: KPIMetricModel.fromMap(
        map['activeSubscriptions'] as Map<String, dynamic>,
      ),
      pendingInvoices: KPIMetricModel.fromMap(
        map['pendingInvoices'] as Map<String, dynamic>,
      ),
      failedPayments: KPIMetricModel.fromMap(
        map['failedPayments'] as Map<String, dynamic>,
      ),
      monthlyRevenue: RevenueKPIMetricModel.fromMap(
        map['monthlyRevenue'] as Map<String, dynamic>,
      ),
    );
  }

  DashboardKPI toEntity() {
    return DashboardKPI(
      activeSubscriptions: activeSubscriptions,
      pendingInvoices: pendingInvoices,
      failedPayments: failedPayments,
      monthlyRevenue: monthlyRevenue,
    );
  }

  factory DashboardKPIModel.fromEntity(DashboardKPI entity) {
    return DashboardKPIModel(
      activeSubscriptions: KPIMetricModel.fromEntity(
        entity.activeSubscriptions,
      ),
      pendingInvoices: KPIMetricModel.fromEntity(entity.pendingInvoices),
      failedPayments: KPIMetricModel.fromEntity(entity.failedPayments),
      monthlyRevenue: RevenueKPIMetricModel.fromEntity(entity.monthlyRevenue),
    );
  }
}

@JsonSerializable()
class KPIMetricModel extends KPIMetric {
  @JsonKey(defaultValue: 0)
  @override
  final int value;

  @JsonKey(defaultValue: '0.00')
  @override
  final String change;

  @JsonKey(defaultValue: '0.00')
  @override
  final String changePercent;

  const KPIMetricModel({
    this.value = 0,
    this.change = '0.00',
    this.changePercent = '0.00',
  }) : super(value: value, change: change, changePercent: changePercent);

  factory KPIMetricModel.fromJson(Map<String, dynamic> json) =>
      _$KPIMetricModelFromJson(json);

  Map<String, dynamic> toJson() => _$KPIMetricModelToJson(this);

  // Database operations - keep for local data source compatibility
  factory KPIMetricModel.fromMap(Map<String, dynamic> map) {
    return KPIMetricModel(
      value: map['value'] as int? ?? 0,
      change: map['change'] as String? ?? '0.00',
      changePercent: map['changePercent'] as String? ?? '0.00',
    );
  }

  Map<String, dynamic> toMap() {
    return {'value': value, 'change': change, 'changePercent': changePercent};
  }

  KPIMetric toEntity() {
    return KPIMetric(
      value: value,
      change: change,
      changePercent: changePercent,
    );
  }

  factory KPIMetricModel.fromEntity(KPIMetric entity) {
    return KPIMetricModel(
      value: entity.value,
      change: entity.change,
      changePercent: entity.changePercent,
    );
  }
}

@JsonSerializable()
class RevenueKPIMetricModel extends RevenueKPIMetric {
  @JsonKey(defaultValue: '0.00')
  @override
  final String value;

  @JsonKey(defaultValue: '0.00')
  @override
  final String change;

  @JsonKey(defaultValue: '0.00')
  @override
  final String changePercent;

  @JsonKey(defaultValue: 'USD')
  @override
  final String currency;

  const RevenueKPIMetricModel({
    this.value = '0.00',
    this.change = '0.00',
    this.changePercent = '0.00',
    this.currency = 'USD',
  }) : super(
         value: value,
         change: change,
         changePercent: changePercent,
         currency: currency,
       );

  factory RevenueKPIMetricModel.fromJson(Map<String, dynamic> json) =>
      _$RevenueKPIMetricModelFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueKPIMetricModelToJson(this);

  // Database operations - keep for local data source compatibility
  factory RevenueKPIMetricModel.fromMap(Map<String, dynamic> map) {
    return RevenueKPIMetricModel(
      value: map['value'] as String? ?? '0.00',
      change: map['change'] as String? ?? '0.00',
      changePercent: map['changePercent'] as String? ?? '0.00',
      currency: map['currency'] as String? ?? 'USD',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'change': change,
      'changePercent': changePercent,
      'currency': currency,
    };
  }

  RevenueKPIMetric toEntity() {
    return RevenueKPIMetric(
      value: value,
      change: change,
      changePercent: changePercent,
      currency: currency,
    );
  }

  factory RevenueKPIMetricModel.fromEntity(RevenueKPIMetric entity) {
    return RevenueKPIMetricModel(
      value: entity.value,
      change: entity.change,
      changePercent: entity.changePercent,
      currency: entity.currency,
    );
  }
}
