import 'package:injectable/injectable.dart';
import '../entities/bundle.dart';
import '../repositories/bundles_repository.dart';

@injectable
class GetCachedBundlesUseCase {
  final BundlesRepository _repository;

  GetCachedBundlesUseCase(this._repository);

  Future<List<Bundle>> call() async {
    return await _repository.getCachedBundles();
  }
}
