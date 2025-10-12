import 'package:injectable/injectable.dart';
import '../entities/invoice.dart';
import '../repositories/invoices_repository.dart';

@injectable
class SearchInvoices {
  final InvoicesRepository _invoicesRepository;

  SearchInvoices(this._invoicesRepository);

  Future<List<Invoice>> call(String searchKey) async {
    final result = await _invoicesRepository.searchInvoices(searchKey);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (invoices) => invoices,
    );
  }
}

