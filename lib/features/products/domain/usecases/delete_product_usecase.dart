import 'package:injectable/injectable.dart';
import '../repositories/products_repository.dart';

@injectable
class DeleteProductUseCase {
  final ProductsRepository _productsRepository;

  DeleteProductUseCase(this._productsRepository);

  Future<void> call(String productId) async {
    return await _productsRepository.deleteProduct(productId);
  }
}
