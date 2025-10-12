import 'package:injectable/injectable.dart';
import '../entities/bundle.dart';
import '../repositories/bundles_repository.dart';

@injectable
class GetAllBundlesUseCase {
  final BundlesRepository _repository;

  GetAllBundlesUseCase(this._repository);

  Future<List<Bundle>> call() async {
    return await _repository.getAllBundles();
  }
}
