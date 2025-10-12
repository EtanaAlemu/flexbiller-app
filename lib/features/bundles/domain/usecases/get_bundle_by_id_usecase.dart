import 'package:injectable/injectable.dart';
import '../entities/bundle.dart';
import '../repositories/bundles_repository.dart';

@injectable
class GetBundleByIdUseCase {
  final BundlesRepository _repository;

  GetBundleByIdUseCase(this._repository);

  Future<Bundle> call(String bundleId) async {
    return await _repository.getBundleById(bundleId);
  }
}
