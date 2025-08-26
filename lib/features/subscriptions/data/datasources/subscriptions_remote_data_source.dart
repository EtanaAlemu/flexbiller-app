import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/subscription_model.dart';
import '../models/create_subscription_request_model.dart';
import '../models/subscription_custom_field_model.dart';
import '../models/add_subscription_custom_fields_request_model.dart';
import '../models/update_subscription_custom_fields_request_model.dart';
import '../models/remove_subscription_custom_fields_request_model.dart';
import '../models/remove_subscription_custom_fields_response_model.dart';
import '../../../../core/constants/api_endpoints.dart';

abstract class SubscriptionsRemoteDataSource {
  Future<List<SubscriptionModel>> getRecentSubscriptions();
  Future<SubscriptionModel> getSubscriptionById(String id);
  Future<List<SubscriptionModel>> getSubscriptionsForAccount(String accountId);
  Future<SubscriptionModel> createSubscription(
    CreateSubscriptionRequestModel request,
  );
  Future<SubscriptionModel> updateSubscription({
    required String id,
    required Map<String, dynamic> payload,
  });
  Future<void> cancelSubscription(String id);
  
  // Custom Fields methods
  Future<List<SubscriptionCustomFieldModel>> addSubscriptionCustomFields({
    required String subscriptionId,
    required List<AddSubscriptionCustomFieldsRequestModel> customFields,
  });
  Future<List<SubscriptionCustomFieldModel>> getSubscriptionCustomFields(String subscriptionId);
  Future<List<SubscriptionCustomFieldModel>> updateSubscriptionCustomFields({
    required String subscriptionId,
    required List<UpdateSubscriptionCustomFieldsRequestModel> customFields,
  });
  Future<RemoveSubscriptionCustomFieldsResponseModel> removeSubscriptionCustomFields({
    required String subscriptionId,
    required RemoveSubscriptionCustomFieldsRequestModel request,
  });
}

@Injectable(as: SubscriptionsRemoteDataSource)
class SubscriptionsRemoteDataSourceImpl implements SubscriptionsRemoteDataSource {
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
  Future<SubscriptionModel> getSubscriptionById(String id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.getSubscriptionById}/$id');

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
  Future<List<SubscriptionModel>> getSubscriptionsForAccount(String accountId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getSubscriptionsForAccount}/$accountId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => SubscriptionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load subscriptions for account');
      }
    } catch (e) {
      throw Exception('Failed to load subscriptions for account: $e');
    }
  }

  @override
  Future<SubscriptionModel> createSubscription(
    CreateSubscriptionRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.getSubscriptionById,
        data: request.toJson(),
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
  Future<SubscriptionModel> updateSubscription({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.getSubscriptionById}/$id',
        data: payload,
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
  Future<void> cancelSubscription(String id) async {
    try {
      final response = await _dio.delete(
        '${ApiEndpoints.getSubscriptionById}/$id',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to cancel subscription');
      }
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  @override
  Future<List<SubscriptionCustomFieldModel>> addSubscriptionCustomFields({
    required String subscriptionId,
    required List<AddSubscriptionCustomFieldsRequestModel> customFields,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.subscriptionCustomFields}/$subscriptionId/customFields',
        data: customFields.map((field) => field.toJson()).toList(),
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as List;
        return data.map((json) => SubscriptionCustomFieldModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to add subscription custom fields');
      }
    } catch (e) {
      throw Exception('Failed to add subscription custom fields: $e');
    }
  }

  @override
  Future<List<SubscriptionCustomFieldModel>> getSubscriptionCustomFields(String subscriptionId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.subscriptionCustomFields}/$subscriptionId/customFields',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => SubscriptionCustomFieldModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load subscription custom fields');
      }
    } catch (e) {
      throw Exception('Failed to load subscription custom fields: $e');
    }
  }

  @override
  Future<List<SubscriptionCustomFieldModel>> updateSubscriptionCustomFields({
    required String subscriptionId,
    required List<UpdateSubscriptionCustomFieldsRequestModel> customFields,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.subscriptionCustomFields}/$subscriptionId/customFields',
        data: customFields.map((field) => field.toJson()).toList(),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => SubscriptionCustomFieldModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to update subscription custom fields');
      }
    } catch (e) {
      throw Exception('Failed to update subscription custom fields: $e');
    }
  }

  @override
  Future<RemoveSubscriptionCustomFieldsResponseModel> removeSubscriptionCustomFields({
    required String subscriptionId,
    required RemoveSubscriptionCustomFieldsRequestModel request,
  }) async {
    try {
      final response = await _dio.delete(
        '${ApiEndpoints.subscriptionCustomFields}/$subscriptionId/customFields',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return RemoveSubscriptionCustomFieldsResponseModel.fromJson(data);
      } else {
        throw Exception('Failed to remove subscription custom fields');
      }
    } catch (e) {
      throw Exception('Failed to remove subscription custom fields: $e');
    }
  }
}
