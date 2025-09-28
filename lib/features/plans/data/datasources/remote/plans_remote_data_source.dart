import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../data/models/plan_model.dart';

abstract class PlansRemoteDataSource {
  Future<List<PlanModel>> getPlans();
  Future<PlanModel> getPlanById(String planId);
}

@LazySingleton(as: PlansRemoteDataSource)
class PlansRemoteDataSourceImpl implements PlansRemoteDataSource {
  final DioClient _dioClient;

  PlansRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<PlanModel>> getPlans() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.plans);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> plansJson = data['data'];
          return plansJson
              .map((json) => PlanModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
            'Failed to fetch plans: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to fetch plans: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<PlanModel> getPlanById(String planId) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiEndpoints.plans}/$planId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return PlanModel.fromJson(data['data'] as Map<String, dynamic>);
        } else {
          throw Exception(
            'Failed to fetch plan: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to fetch plan: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
