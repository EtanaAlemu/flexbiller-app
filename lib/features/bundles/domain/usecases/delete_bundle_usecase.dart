import 'package:injectable/injectable.dart';
import '../repositories/bundles_repository.dart';

@injectable
class DeleteBundleUseCase {
  final BundlesRepository _bundlesRepository;

  DeleteBundleUseCase(this._bundlesRepository);

  Future<void> call(String bundleId) async {
    return await _bundlesRepository.deleteBundle(bundleId);
  }
}

