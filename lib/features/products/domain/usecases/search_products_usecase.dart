import 'package:injectable/injectable.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

@injectable
class SearchProductsUseCase {
  final ProductsRepository _productsRepository;

  SearchProductsUseCase(this._productsRepository);

  Future<List<Product>> call(String searchKey) async {
    return await _productsRepository.searchProducts(searchKey);
  }
}
