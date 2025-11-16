import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/bundle_model.dart';
import '../../../../core/constants/api_endpoints.dart';

abstract class BundlesRemoteDataSource {
  Future<List<BundleModel>> getAllBundles();
  Future<BundleModel> getBundleById(String bundleId);
  Future<List<BundleModel>> getBundlesForAccount(String accountId);
  Future<void> deleteBundle(String bundleId);
}

@Injectable(as: BundlesRemoteDataSource)
class BundlesRemoteDataSourceImpl implements BundlesRemoteDataSource {
  final Dio _dio;

  BundlesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<BundleModel>> getAllBundles() async {
    try {
      final response = await _dio.get(ApiEndpoints.bundles);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => BundleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bundles');
      }
    } catch (e) {
      throw Exception('Failed to load bundles: $e');
    }
  }

  @override
  Future<BundleModel> getBundleById(String bundleId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.bundles}/$bundleId');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BundleModel.fromJson(data);
      } else {
        throw Exception('Failed to load bundle');
      }
    } catch (e) {
      throw Exception('Failed to load bundle: $e');
    }
  }

  @override
  Future<List<BundleModel>> getBundlesForAccount(String accountId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.bundles}?accountId=$accountId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => BundleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bundles for account');
      }
    } catch (e) {
      throw Exception('Failed to load bundles for account: $e');
    }
  }

  @override
  Future<void> deleteBundle(String bundleId) async {
    try {
      final response = await _dio.delete('${ApiEndpoints.bundles}/$bundleId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw Exception('Failed to delete bundle: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete bundle: $e');
    }
  }
}
