import 'package:injectable/injectable.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_custom_field.dart';
import '../../domain/entities/subscription_blocking_state.dart';
import '../../domain/entities/subscription_addon_product.dart';
import '../../domain/repositories/subscriptions_repository.dart';
import '../datasources/subscriptions_remote_data_source.dart';
import '../models/create_subscription_request_model.dart';
import '../models/add_subscription_custom_fields_request_model.dart';
import '../models/update_subscription_custom_fields_request_model.dart';
import '../models/remove_subscription_custom_fields_request_model.dart';
import '../models/block_subscription_request_model.dart';
import '../models/create_subscription_with_addons_request_model.dart';

@Injectable(as: SubscriptionsRepository)
class SubscriptionsRepositoryImpl implements SubscriptionsRepository {
  final SubscriptionsRemoteDataSource _remoteDataSource;

  SubscriptionsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Subscription>> getRecentSubscriptions() async {
    try {
      final subscriptionModels = await _remoteDataSource.getRecentSubscriptions();
      return subscriptionModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Subscription> getSubscriptionById(String id) async {
    try {
      final subscriptionModel = await _remoteDataSource.getSubscriptionById(id);
      return subscriptionModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Subscription>> getSubscriptionsForAccount(String accountId) async {
    try {
      final subscriptionModels = await _remoteDataSource.getSubscriptionsForAccount(accountId);
      return subscriptionModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Subscription> createSubscription({
    required String accountId,
    required String planName,
  }) async {
    try {
      final request = CreateSubscriptionRequestModel(
        accountId: accountId,
        planName: planName,
      );

      final subscriptionModel = await _remoteDataSource.createSubscription(request);
      return subscriptionModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Subscription> updateSubscription({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final subscriptionModel = await _remoteDataSource.updateSubscription(
        id: id,
        payload: payload,
      );
      return subscriptionModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> cancelSubscription(String id) async {
    try {
      await _remoteDataSource.cancelSubscription(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SubscriptionCustomField>> addSubscriptionCustomFields({
    required String subscriptionId,
    required List<Map<String, String>> customFields,
  }) async {
    try {
      final customFieldModels = customFields.map((field) =>
        AddSubscriptionCustomFieldsRequestModel(
          name: field['name']!,
          value: field['value']!,
        )
      ).toList();

      final result = await _remoteDataSource.addSubscriptionCustomFields(
        subscriptionId: subscriptionId,
        customFields: customFieldModels,
      );
      return result.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SubscriptionCustomField>> getSubscriptionCustomFields(String subscriptionId) async {
    try {
      final customFieldModels = await _remoteDataSource.getSubscriptionCustomFields(subscriptionId);
      return customFieldModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SubscriptionCustomField>> updateSubscriptionCustomFields({
    required String subscriptionId,
    required List<Map<String, String>> customFields,
  }) async {
    try {
      final customFieldModels = customFields.map((field) =>
        UpdateSubscriptionCustomFieldsRequestModel(
          customFieldId: field['customFieldId']!,
          name: field['name']!,
          value: field['value']!,
        )
      ).toList();

      final result = await _remoteDataSource.updateSubscriptionCustomFields(
        subscriptionId: subscriptionId,
        customFields: customFieldModels,
      );
      return result.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> removeSubscriptionCustomFields({
    required String subscriptionId,
    required String customFieldIds,
  }) async {
    try {
      final request = RemoveSubscriptionCustomFieldsRequestModel(
        customFieldIds: customFieldIds,
      );

      final result = await _remoteDataSource.removeSubscriptionCustomFields(
        subscriptionId: subscriptionId,
        request: request,
      );

      return {
        'subscriptionId': result.subscriptionId,
        'removedCustomFields': result.removedCustomFields,
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SubscriptionBlockingState> blockSubscription({
    required String subscriptionId,
    required Map<String, dynamic> blockingData,
  }) async {
    try {
      final request = BlockSubscriptionRequestModel(
        stateName: blockingData['stateName'] ?? 'BLOCKED',
        service: blockingData['service'] ?? 'PAYMENT',
        isBlockChange: blockingData['isBlockChange'] ?? true,
        isBlockEntitlement: blockingData['isBlockEntitlement'] ?? true,
        isBlockBilling: blockingData['isBlockBilling'] ?? true,
        effectiveDate: blockingData['effectiveDate'] ?? DateTime.now().toIso8601String(),
        type: blockingData['type'] ?? 'SUBSCRIPTION',
      );

      final result = await _remoteDataSource.blockSubscription(
        subscriptionId: subscriptionId,
        request: request,
      );

      return SubscriptionBlockingState(
        stateName: result.stateName,
        service: result.service,
        isBlockChange: result.isBlockChange,
        isBlockEntitlement: result.isBlockEntitlement,
        isBlockBilling: result.isBlockBilling,
        effectiveDate: DateTime.parse(result.effectiveDate),
        type: result.type,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createSubscriptionWithAddOns({
    required List<SubscriptionAddonProduct> addonProducts,
  }) async {
    try {
      final addonProductModels = addonProducts.map((addon) =>
        CreateSubscriptionWithAddonsRequestModel(
          accountId: addon.accountId,
          productName: addon.productName,
          productCategory: addon.productCategory,
          billingPeriod: addon.billingPeriod,
          priceList: addon.priceList,
        )
      ).toList();

      final result = await _remoteDataSource.createSubscriptionWithAddOns(
        addonProducts: addonProductModels,
      );

      return {
        'success': result.success,
        'code': result.code,
        'data': result.data,
        'message': result.message,
      };
    } catch (e) {
      rethrow;
    }
  }
}
