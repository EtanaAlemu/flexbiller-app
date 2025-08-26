import 'package:injectable/injectable.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_custom_field.dart';
import '../../domain/entities/subscription_blocking_state.dart';
import '../../domain/entities/subscription_addon_product.dart';
import '../../domain/entities/subscription_audit_log.dart';
import '../../domain/entities/subscription_bcd_update.dart';
import '../../domain/repositories/subscriptions_repository.dart';
import '../datasources/subscriptions_remote_data_source.dart';
import '../models/create_subscription_request_model.dart';
import '../models/add_subscription_custom_fields_request_model.dart';
import '../models/update_subscription_custom_fields_request_model.dart';
import '../models/remove_subscription_custom_fields_request_model.dart';
import '../models/block_subscription_request_model.dart';
import '../models/create_subscription_with_addons_request_model.dart';
import '../models/subscription_audit_logs_response_model.dart';
import '../models/update_subscription_bcd_request_model.dart';
import '../models/update_subscription_bcd_response_model.dart';

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
        CreateSubscriptionWithAddOnsRequestModel(
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

  @override
  Future<List<SubscriptionAuditLog>> getSubscriptionAuditLogsWithHistory(String subscriptionId) async {
    try {
      final result = await _remoteDataSource.getSubscriptionAuditLogsWithHistory(subscriptionId);
      
      return result.data.map((model) => _mapAuditLogModelToEntity(model)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateSubscriptionBcd({
    required String subscriptionId,
    required SubscriptionBcdUpdate bcdUpdate,
  }) async {
    try {
      final request = UpdateSubscriptionBcdRequestModel(
        accountId: bcdUpdate.accountId,
        bundleId: bcdUpdate.bundleId,
        subscriptionId: bcdUpdate.subscriptionId,
        startDate: bcdUpdate.startDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        productName: bcdUpdate.productName,
        productCategory: bcdUpdate.productCategory,
        billingPeriod: bcdUpdate.billingPeriod,
        priceList: bcdUpdate.priceList,
        phaseType: bcdUpdate.phaseType,
        billCycleDayLocal: bcdUpdate.billCycleDayLocal,
      );

      final result = await _remoteDataSource.updateSubscriptionBcd(
        subscriptionId: subscriptionId,
        request: request,
      );

      return {
        'success': result.success,
        'code': result.code,
        'data': _mapBcdDataModelToMap(result.data),
        'message': result.message,
      };
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> _mapBcdDataModelToMap(SubscriptionBcdDataModel model) {
    return {
      'accountId': model.accountId,
      'bundleId': model.bundleId,
      'bundleExternalKey': model.bundleExternalKey,
      'subscriptionId': model.subscriptionId,
      'externalKey': model.externalKey,
      'startDate': model.startDate,
      'productName': model.productName,
      'productCategory': model.productCategory,
      'billingPeriod': model.billingPeriod,
      'phaseType': model.phaseType,
      'priceList': model.priceList,
      'planName': model.planName,
      'state': model.state,
      'sourceType': model.sourceType,
      'cancelledDate': model.cancelledDate,
      'chargedThroughDate': model.chargedThroughDate,
      'billingStartDate': model.billingStartDate,
      'billingEndDate': model.billingEndDate,
      'billCycleDayLocal': model.billCycleDayLocal,
      'quantity': model.quantity,
      'events': model.events?.map((event) => _mapEventModelToMap(event)).toList(),
      'priceOverrides': model.priceOverrides,
      'prices': model.prices?.map((price) => _mapPriceModelToMap(price)).toList(),
      'auditLogs': model.auditLogs,
    };
  }

  Map<String, dynamic> _mapEventModelToMap(SubscriptionEventModel event) {
    return {
      'eventId': event.eventId,
      'billingPeriod': event.billingPeriod,
      'effectiveDate': event.effectiveDate,
      'catalogEffectiveDate': event.catalogEffectiveDate,
      'plan': event.plan,
      'product': event.product,
      'priceList': event.priceList,
      'eventType': event.eventType,
      'isBlockedBilling': event.isBlockedBilling,
      'isBlockedEntitlement': event.isBlockedEntitlement,
      'serviceName': event.serviceName,
      'serviceStateName': event.serviceStateName,
      'phase': event.phase,
      'auditLogs': event.auditLogs,
    };
  }

  Map<String, dynamic> _mapPriceModelToMap(SubscriptionPriceModel price) {
    return {
      'planName': price.planName,
      'phaseName': price.phaseName,
      'phaseType': price.phaseType,
      'fixedPrice': price.fixedPrice,
      'recurringPrice': price.recurringPrice,
      'usagePrices': price.usagePrices,
    };
  }

  SubscriptionAuditLog _mapAuditLogModelToEntity(SubscriptionAuditLogModel model) {
    return SubscriptionAuditLog(
      changeType: model.changeType,
      changeDate: model.changeDate != null ? DateTime.parse(model.changeDate!) : null,
      objectType: model.objectType,
      objectId: model.objectId,
      changedBy: model.changedBy,
      reasonCode: model.reasonCode,
      comments: model.comments,
      userToken: model.userToken,
      history: model.history != null ? _mapAuditHistoryModelToEntity(model.history!) : null,
    );
  }

  SubscriptionAuditHistory _mapAuditHistoryModelToEntity(SubscriptionAuditHistoryModel model) {
    return SubscriptionAuditHistory(
      id: model.id,
      createdDate: model.createdDate != null ? DateTime.parse(model.createdDate!) : null,
      updatedDate: model.updatedDate != null ? DateTime.parse(model.updatedDate!) : null,
      recordId: model.recordId,
      accountRecordId: model.accountRecordId,
      tenantRecordId: model.tenantRecordId,
      bundleId: model.bundleId,
      externalKey: model.externalKey,
      category: model.category,
      startDate: model.startDate != null ? DateTime.parse(model.startDate!) : null,
      bundleStartDate: model.bundleStartDate != null ? DateTime.parse(model.bundleStartDate!) : null,
      chargedThroughDate: model.chargedThroughDate != null ? DateTime.parse(model.chargedThroughDate!) : null,
      migrated: model.migrated,
      tableName: model.tableName,
      historyTableName: model.historyTableName,
    );
  }
}
