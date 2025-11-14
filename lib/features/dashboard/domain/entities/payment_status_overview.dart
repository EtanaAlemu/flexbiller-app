import 'package:equatable/equatable.dart';

class PaymentStatusOverview extends Equatable {
  final String month;
  final int paidInvoices;
  final int unpaidInvoices;

  const PaymentStatusOverview({
    required this.month,
    required this.paidInvoices,
    required this.unpaidInvoices,
  });

  @override
  List<Object?> get props => [month, paidInvoices, unpaidInvoices];
}

class PaymentStatusOverviews extends Equatable {
  final List<PaymentStatusOverview> overviews;
  final int year;

  const PaymentStatusOverviews({required this.overviews, required this.year});

  @override
  List<Object?> get props => [overviews, year];
}
