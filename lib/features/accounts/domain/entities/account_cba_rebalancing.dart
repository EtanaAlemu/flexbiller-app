import 'package:equatable/equatable.dart';

class AccountCbaRebalancing extends Equatable {
  final String message;
  final String accountId;
  final String result;

  const AccountCbaRebalancing({
    required this.message,
    required this.accountId,
    required this.result,
  });

  @override
  List<Object?> get props => [
        message,
        accountId,
        result,
      ];
}
