import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment_status_overview.dart';

part 'payment_status_overview_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PaymentStatusOverviewModel extends PaymentStatusOverview {
  @JsonKey(name: 'month')
  @override
  final String month;

  @JsonKey(name: 'paidInvoices')
  @override
  final int paidInvoices;

  @JsonKey(name: 'unpaidInvoices')
  @override
  final int unpaidInvoices;

  const PaymentStatusOverviewModel({
    required this.month,
    required this.paidInvoices,
    required this.unpaidInvoices,
  }) : super(
         month: month,
         paidInvoices: paidInvoices,
         unpaidInvoices: unpaidInvoices,
       );

  factory PaymentStatusOverviewModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentStatusOverviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentStatusOverviewModelToJson(this);

  // Database operations - keep for local data source compatibility
  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'paidInvoices': paidInvoices,
      'unpaidInvoices': unpaidInvoices,
    };
  }

  factory PaymentStatusOverviewModel.fromMap(Map<String, dynamic> map) {
    return PaymentStatusOverviewModel(
      month: map['month'] as String,
      paidInvoices: map['paidInvoices'] as int? ?? 0,
      unpaidInvoices: map['unpaidInvoices'] as int? ?? 0,
    );
  }

  PaymentStatusOverview toEntity() {
    return PaymentStatusOverview(
      month: month,
      paidInvoices: paidInvoices,
      unpaidInvoices: unpaidInvoices,
    );
  }

  factory PaymentStatusOverviewModel.fromEntity(PaymentStatusOverview entity) {
    return PaymentStatusOverviewModel(
      month: entity.month,
      paidInvoices: entity.paidInvoices,
      unpaidInvoices: entity.unpaidInvoices,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaymentStatusOverviewsModel extends PaymentStatusOverviews {
  @JsonKey(name: 'overviews')
  @override
  final List<PaymentStatusOverviewModel> overviews;

  @JsonKey(name: 'year')
  @override
  final int year;

  const PaymentStatusOverviewsModel({
    required this.overviews,
    required this.year,
  }) : super(overviews: overviews, year: year);

  factory PaymentStatusOverviewsModel.fromJson(
    Map<String, dynamic> json,
    int year,
  ) {
    final List<dynamic> data = json['data'] as List<dynamic>? ?? [];
    final overviews = data
        .map(
          (item) =>
              PaymentStatusOverviewModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
    return PaymentStatusOverviewsModel(overviews: overviews, year: year);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': overviews.map((overview) => overview.toJson()).toList(),
      'year': year,
    };
  }

  // Database operations
  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'overviews': overviews.map((overview) => overview.toMap()).toList(),
    };
  }

  factory PaymentStatusOverviewsModel.fromMap(Map<String, dynamic> map) {
    final overviewsList =
        (map['overviews'] as List<dynamic>?)
            ?.map(
              (item) => PaymentStatusOverviewModel.fromMap(
                item as Map<String, dynamic>,
              ),
            )
            .toList() ??
        [];
    return PaymentStatusOverviewsModel(
      overviews: overviewsList,
      year: map['year'] as int? ?? DateTime.now().year,
    );
  }

  PaymentStatusOverviews toEntity() {
    return PaymentStatusOverviews(
      overviews: overviews.map((o) => o.toEntity()).toList(),
      year: year,
    );
  }

  factory PaymentStatusOverviewsModel.fromEntity(
    PaymentStatusOverviews entity,
  ) {
    return PaymentStatusOverviewsModel(
      overviews: entity.overviews
          .map((o) => PaymentStatusOverviewModel.fromEntity(o))
          .toList(),
      year: entity.year,
    );
  }
}
