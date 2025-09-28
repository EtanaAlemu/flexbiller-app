import 'package:injectable/injectable.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

@injectable
class UpdateProductUseCase {
  final ProductsRepository _productsRepository;

  UpdateProductUseCase(this._productsRepository);

  Future<Product> call(Product product) async {
    return await _productsRepository.updateProduct(product);
  }
}
