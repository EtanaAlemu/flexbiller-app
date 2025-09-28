import 'package:injectable/injectable.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

@injectable
class GetProductByIdUseCase {
  final ProductsRepository _productsRepository;

  GetProductByIdUseCase(this._productsRepository);

  Future<Product> call(String productId) async {
    return await _productsRepository.getProductById(productId);
  }
}
