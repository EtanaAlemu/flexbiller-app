import 'package:injectable/injectable.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

@injectable
class SearchPayments {
  final PaymentsRepository _paymentsRepository;

  SearchPayments(this._paymentsRepository);

  Future<List<Payment>> call(String searchKey) async {
    final result = await _paymentsRepository.searchPayments(searchKey);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (payments) => payments,
    );
  }
}
