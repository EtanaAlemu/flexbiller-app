import 'package:injectable/injectable.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

@injectable
class CreateProductUseCase {
  final ProductsRepository _productsRepository;

  CreateProductUseCase(this._productsRepository);

  Future<Product> call(Product product) async {
    return await _productsRepository.createProduct(product);
  }
}
