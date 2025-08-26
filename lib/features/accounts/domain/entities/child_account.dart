import 'package:equatable/equatable.dart';

class ChildAccount extends Equatable {
  final String name;
  final String email;
  final String currency;
  final bool isPaymentDelegatedToParent;
  final String parentAccountId;

  const ChildAccount({
    required this.name,
    required this.email,
    required this.currency,
    required this.isPaymentDelegatedToParent,
    required this.parentAccountId,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        currency,
        isPaymentDelegatedToParent,
        parentAccountId,
      ];
}
