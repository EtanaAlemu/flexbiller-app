import 'package:injectable/injectable.dart';
import '../entities/bundle.dart';
import '../repositories/bundles_repository.dart';

@injectable
class GetBundlesForAccountUseCase {
  final BundlesRepository _repository;

  GetBundlesForAccountUseCase(this._repository);

  Future<List<Bundle>> call(String accountId) async {
    return await _repository.getBundlesForAccount(accountId);
  }
}
