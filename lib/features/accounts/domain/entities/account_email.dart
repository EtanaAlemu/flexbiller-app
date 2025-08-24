import 'package:equatable/equatable.dart';

class AccountEmail extends Equatable {
  final String accountId;
  final String email;

  const AccountEmail({
    required this.accountId,
    required this.email,
  });

  @override
  List<Object?> get props => [accountId, email];

  AccountEmail copyWith({
    String? accountId,
    String? email,
  }) {
    return AccountEmail(
      accountId: accountId ?? this.accountId,
      email: email ?? this.email,
    );
  }
}
