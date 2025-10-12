import 'package:injectable/injectable.dart';
import '../entities/bundle.dart';
import '../repositories/bundles_repository.dart';

@injectable
class GetCachedBundleByIdUseCase {
  final BundlesRepository _repository;

  GetCachedBundleByIdUseCase(this._repository);

  Future<Bundle?> call(String bundleId) async {
    return await _repository.getCachedBundleById(bundleId);
  }
}
