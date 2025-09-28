import 'package:injectable/injectable.dart';
import '../entities/product.dart';
import '../entities/products_query_params.dart';
import '../repositories/products_repository.dart';

@injectable
class GetProductsUseCase {
  final ProductsRepository _productsRepository;

  GetProductsUseCase(this._productsRepository);

  Future<List<Product>> call(ProductsQueryParams params) async {
    return await _productsRepository.getProducts(params);
  }
}
