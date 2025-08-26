import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/subscription_model.dart';
import '../models/create_subscription_request_model.dart';
import '../../../../core/constants/api_endpoints.dart';

abstract class SubscriptionsRemoteDataSource {
  Future<List<SubscriptionModel>> getRecentSubscriptions();
  Future<SubscriptionModel> getSubscriptionById(String subscriptionId);
  Future<List<SubscriptionModel>> getSubscriptionsForAccount(String accountId);
  Future<SubscriptionModel> createSubscription(
    String accountId,
    String planName,
  );
  Future<SubscriptionModel> updateSubscription(
    String subscriptionId,
    Map<String, dynamic> updateData,
  );
  Future<Map<String, dynamic>> cancelSubscription(String subscriptionId);
  Future<List<String>> getSubscriptionTags(String subscriptionId);
}

@Injectable(as: SubscriptionsRemoteDataSource)
class SubscriptionsRemoteDataSourceImpl
    implements SubscriptionsRemoteDataSource {
  final Dio _dio;

  SubscriptionsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<SubscriptionModel>> getRecentSubscriptions() async {
    try {
      final response = await _dio.get(ApiEndpoints.recentSubscriptions);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => SubscriptionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recent subscriptions');
      }
    } catch (e) {
      throw Exception('Failed to load recent subscriptions: $e');
    }
  }

  @override
  Future<SubscriptionModel> getSubscriptionById(String subscriptionId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getSubscriptionById}/$subscriptionId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SubscriptionModel.fromJson(data);
      } else {
        throw Exception('Failed to load subscription');
      }
    } catch (e) {
      throw Exception('Failed to load subscription: $e');
    }
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptionsForAccount(
    String accountId,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getSubscriptionsForAccount}/$accountId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => SubscriptionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load account subscriptions');
      }
    } catch (e) {
      throw Exception('Failed to load account subscriptions: $e');
    }
  }

  @override
  Future<SubscriptionModel> createSubscription(
    String accountId,
    String planName,
  ) async {
    try {
      final requestModel = CreateSubscriptionRequestModel(
        accountId: accountId,
        planName: planName,
      );

      final response = await _dio.post(
        ApiEndpoints.getSubscriptionById, // Using the same endpoint for POST
        data: requestModel.toJson(),
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SubscriptionModel.fromJson(data);
      } else {
        throw Exception('Failed to create subscription');
      }
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  @override
  Future<SubscriptionModel> updateSubscription(
    String subscriptionId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.getSubscriptionById}/$subscriptionId',
        data: updateData,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SubscriptionModel.fromJson(data);
      } else {
        throw Exception('Failed to update subscription');
      }
    } catch (e) {
      throw Exception('Failed to update subscription: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> cancelSubscription(String subscriptionId) async {
    try {
      final response = await _dio.delete(
        '${ApiEndpoints.getSubscriptionById}/$subscriptionId',
      );

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to cancel subscription');
      }
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  @override
  Future<List<String>> getSubscriptionTags(String subscriptionId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getSubscriptionById}/$subscriptionId/tags',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.cast<String>();
      } else {
        throw Exception('Failed to load subscription tags');
      }
    } catch (e) {
      throw Exception('Failed to load subscription tags: $e');
    }
  }
}
