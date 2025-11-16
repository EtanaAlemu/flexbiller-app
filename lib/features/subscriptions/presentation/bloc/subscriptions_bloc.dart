import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/bloc/bloc_error_handler_mixin.dart';
import '../../domain/usecases/get_recent_subscriptions_usecase.dart';
import '../../domain/usecases/get_subscription_by_id_usecase.dart';
import '../../domain/usecases/get_subscriptions_for_account_usecase.dart';
import '../../domain/usecases/create_subscription_usecase.dart';
import '../../domain/usecases/update_subscription_usecase.dart';
import '../../domain/usecases/cancel_subscription_usecase.dart';
import '../../domain/usecases/add_subscription_custom_fields_usecase.dart';
import '../../domain/usecases/get_subscription_custom_fields_usecase.dart';
import '../../domain/usecases/update_subscription_custom_fields_usecase.dart';
import '../../domain/usecases/remove_subscription_custom_fields_usecase.dart';
import '../../domain/usecases/block_subscription_usecase.dart';
import '../../domain/usecases/create_subscription_with_addons_usecase.dart';
import '../../domain/usecases/get_subscription_audit_logs_with_history_usecase.dart';
import '../../domain/usecases/update_subscription_bcd_usecase.dart';
import '../../domain/entities/subscription_addon_product.dart';
import '../../domain/entities/subscription_bcd_update.dart';
import 'subscriptions_event.dart';
import 'subscriptions_state.dart';

@injectable
class SubscriptionsBloc extends Bloc<SubscriptionsEvent, SubscriptionsState>
    with BlocErrorHandlerMixin {
  final GetRecentSubscriptionsUseCase _getRecentSubscriptionsUseCase;
  final GetSubscriptionByIdUseCase _getSubscriptionByIdUseCase;
  final GetSubscriptionsForAccountUseCase _getSubscriptionsForAccountUseCase;
  final CreateSubscriptionUseCase _createSubscriptionUseCase;
  final UpdateSubscriptionUseCase _updateSubscriptionUseCase;
  final CancelSubscriptionUseCase _cancelSubscriptionUseCase;
  final AddSubscriptionCustomFieldsUseCase _addSubscriptionCustomFieldsUseCase;
  final GetSubscriptionCustomFieldsUseCase _getSubscriptionCustomFieldsUseCase;
  final UpdateSubscriptionCustomFieldsUseCase
  _updateSubscriptionCustomFieldsUseCase;
  final RemoveSubscriptionCustomFieldsUseCase
  _removeSubscriptionCustomFieldsUseCase;
  final BlockSubscriptionUseCase _blockSubscriptionUseCase;
  final CreateSubscriptionWithAddOnsUseCase
  _createSubscriptionWithAddOnsUseCase;
  final GetSubscriptionAuditLogsWithHistoryUseCase
  _getSubscriptionAuditLogsWithHistoryUseCase;
  final UpdateSubscriptionBcdUseCase _updateSubscriptionBcdUseCase;

  SubscriptionsBloc(
    this._getRecentSubscriptionsUseCase,
    this._getSubscriptionByIdUseCase,
    this._getSubscriptionsForAccountUseCase,
    this._createSubscriptionUseCase,
    this._updateSubscriptionUseCase,
    this._cancelSubscriptionUseCase,
    this._addSubscriptionCustomFieldsUseCase,
    this._getSubscriptionCustomFieldsUseCase,
    this._updateSubscriptionCustomFieldsUseCase,
    this._removeSubscriptionCustomFieldsUseCase,
    this._blockSubscriptionUseCase,
    this._createSubscriptionWithAddOnsUseCase,
    this._getSubscriptionAuditLogsWithHistoryUseCase,
    this._updateSubscriptionBcdUseCase,
  ) : super(SubscriptionsInitial()) {
    on<LoadRecentSubscriptions>(_onLoadRecentSubscriptions);
    on<RefreshRecentSubscriptions>(_onRefreshRecentSubscriptions);
    on<GetSubscriptionById>(_onGetSubscriptionById);
    on<GetSubscriptionsForAccount>(_onGetSubscriptionsForAccount);
    on<CreateSubscription>(_onCreateSubscription);
    on<UpdateSubscription>(_onUpdateSubscription);
    on<CancelSubscription>(_onCancelSubscription);
    on<AddSubscriptionCustomFields>(_onAddSubscriptionCustomFields);
    on<GetSubscriptionCustomFields>(_onGetSubscriptionCustomFields);
    on<UpdateSubscriptionCustomFields>(_onUpdateSubscriptionCustomFields);
    on<RemoveSubscriptionCustomFields>(_onRemoveSubscriptionCustomFields);
    on<BlockSubscription>(_onBlockSubscription);
    on<CreateSubscriptionWithAddOns>(_onCreateSubscriptionWithAddOns);
    on<GetSubscriptionAuditLogsWithHistory>(
      _onGetSubscriptionAuditLogsWithHistory,
    );
    on<UpdateSubscriptionBcd>(_onUpdateSubscriptionBcd);
  }

  Future<void> _onLoadRecentSubscriptions(
    LoadRecentSubscriptions event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(SubscriptionsLoading());
    try {
      final subscriptions = await _getRecentSubscriptionsUseCase();
      emit(RecentSubscriptionsLoaded(subscriptions));
    } catch (e) {
      final message = handleException(e, context: 'load_recent_subscriptions');
      emit(SubscriptionsError(message));
    }
  }

  Future<void> _onRefreshRecentSubscriptions(
    RefreshRecentSubscriptions event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(SubscriptionsLoading());
    try {
      final subscriptions = await _getRecentSubscriptionsUseCase();
      emit(RecentSubscriptionsLoaded(subscriptions));
    } catch (e) {
      final message = handleException(e, context: 'load_recent_subscriptions');
      emit(SubscriptionsError(message));
    }
  }

  Future<void> _onGetSubscriptionById(
    GetSubscriptionById event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(SingleSubscriptionLoading());
    try {
      final subscription = await _getSubscriptionByIdUseCase(event.id);
      emit(SingleSubscriptionLoaded(subscription));
    } catch (e) {
      final message = handleException(
        e,
        context: 'get_subscription_by_id',
        metadata: {'subscriptionId': event.id},
      );
      emit(SingleSubscriptionError(message, event.id));
    }
  }

  Future<void> _onGetSubscriptionsForAccount(
    GetSubscriptionsForAccount event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(AccountSubscriptionsLoading());
    try {
      final subscriptions = await _getSubscriptionsForAccountUseCase(
        event.accountId,
      );
      emit(AccountSubscriptionsLoaded(subscriptions, event.accountId));
    } catch (e) {
      final message = handleException(
        e,
        context: 'get_subscriptions_for_account',
        metadata: {'accountId': event.accountId},
      );
      emit(AccountSubscriptionsError(message, event.accountId));
    }
  }

  Future<void> _onCreateSubscription(
    CreateSubscription event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(CreateSubscriptionLoading());
    try {
      final subscription = await _createSubscriptionUseCase(
        accountId: event.accountId,
        planName: event.planName,
      );
      emit(CreateSubscriptionSuccess(subscription));
    } catch (e) {
      final message = handleException(
        e,
        context: 'create_subscription',
        metadata: {'accountId': event.accountId, 'planName': event.planName},
      );
      emit(CreateSubscriptionError(message));
    }
  }

  Future<void> _onUpdateSubscription(
    UpdateSubscription event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(UpdateSubscriptionLoading());
    try {
      final subscription = await _updateSubscriptionUseCase(
        id: event.id,
        payload: event.payload,
      );
      emit(UpdateSubscriptionSuccess(subscription));
    } catch (e) {
      final message = handleException(
        e,
        context: 'update_subscription',
        metadata: {'subscriptionId': event.id},
      );
      emit(UpdateSubscriptionError(message, event.id));
    }
  }

  Future<void> _onCancelSubscription(
    CancelSubscription event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(CancelSubscriptionLoading());
    try {
      await _cancelSubscriptionUseCase(event.id);
      emit(CancelSubscriptionSuccess(event.id));
    } catch (e) {
      final message = handleException(
        e,
        context: 'cancel_subscription',
        metadata: {'subscriptionId': event.id},
      );
      emit(CancelSubscriptionError(message, event.id));
    }
  }

  Future<void> _onAddSubscriptionCustomFields(
    AddSubscriptionCustomFields event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(AddSubscriptionCustomFieldsLoading());
    try {
      final customFields = await _addSubscriptionCustomFieldsUseCase(
        subscriptionId: event.subscriptionId,
        customFields: event.customFields,
      );
      emit(
        AddSubscriptionCustomFieldsSuccess(customFields, event.subscriptionId),
      );
    } catch (e) {
      final message = handleException(
        e,
        context: 'add_subscription_custom_fields',
        metadata: {'subscriptionId': event.subscriptionId},
      );
      emit(AddSubscriptionCustomFieldsError(message, event.subscriptionId));
    }
  }

  Future<void> _onGetSubscriptionCustomFields(
    GetSubscriptionCustomFields event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(SubscriptionCustomFieldsLoading());
    try {
      final customFields = await _getSubscriptionCustomFieldsUseCase(
        event.subscriptionId,
      );
      emit(SubscriptionCustomFieldsLoaded(customFields, event.subscriptionId));
    } catch (e) {
      final message = handleException(
        e,
        context: 'get_subscription_custom_fields',
        metadata: {'subscriptionId': event.subscriptionId},
      );
      emit(SubscriptionCustomFieldsError(message, event.subscriptionId));
    }
  }

  Future<void> _onUpdateSubscriptionCustomFields(
    UpdateSubscriptionCustomFields event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(UpdateSubscriptionCustomFieldsLoading());
    try {
      final customFields = await _updateSubscriptionCustomFieldsUseCase(
        subscriptionId: event.subscriptionId,
        customFields: event.customFields,
      );
      emit(
        UpdateSubscriptionCustomFieldsSuccess(
          customFields,
          event.subscriptionId,
        ),
      );
    } catch (e) {
      final message = handleException(
        e,
        context: 'update_subscription_custom_fields',
        metadata: {'subscriptionId': event.subscriptionId},
      );
      emit(UpdateSubscriptionCustomFieldsError(message, event.subscriptionId));
    }
  }

  Future<void> _onRemoveSubscriptionCustomFields(
    RemoveSubscriptionCustomFields event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(RemoveSubscriptionCustomFieldsLoading());
    try {
      final result = await _removeSubscriptionCustomFieldsUseCase(
        subscriptionId: event.subscriptionId,
        customFieldIds: event.customFieldIds,
      );
      emit(RemoveSubscriptionCustomFieldsSuccess(result, event.subscriptionId));
    } catch (e) {
      final message = handleException(
        e,
        context: 'remove_subscription_custom_fields',
        metadata: {'subscriptionId': event.subscriptionId},
      );
      emit(RemoveSubscriptionCustomFieldsError(message, event.subscriptionId));
    }
  }

  Future<void> _onBlockSubscription(
    BlockSubscription event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(BlockSubscriptionLoading());
    try {
      final result = await _blockSubscriptionUseCase(
        subscriptionId: event.subscriptionId,
        blockingData: event.blockingData,
      );
      emit(BlockSubscriptionSuccess(result, event.subscriptionId));
    } catch (e) {
      final message = handleException(
        e,
        context: 'block_subscription',
        metadata: {'subscriptionId': event.subscriptionId},
      );
      emit(BlockSubscriptionError(message, event.subscriptionId));
    }
  }

  Future<void> _onCreateSubscriptionWithAddOns(
    CreateSubscriptionWithAddOns event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(CreateSubscriptionWithAddOnsLoading());
    try {
      final addonProducts = event.addonProducts
          .map(
            (addon) => SubscriptionAddonProduct(
              accountId: addon['accountId']!,
              productName: addon['productName']!,
              productCategory: addon['productCategory']!,
              billingPeriod: addon['billingPeriod']!,
              priceList: addon['priceList']!,
            ),
          )
          .toList();

      final result = await _createSubscriptionWithAddOnsUseCase(
        addonProducts: addonProducts,
      );
      emit(CreateSubscriptionWithAddOnsSuccess(result));
    } catch (e) {
      final message = handleException(
        e,
        context: 'create_subscription_with_addons',
      );
      emit(CreateSubscriptionWithAddOnsError(message));
    }
  }

  Future<void> _onGetSubscriptionAuditLogsWithHistory(
    GetSubscriptionAuditLogsWithHistory event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(GetSubscriptionAuditLogsWithHistoryLoading());
    try {
      final auditLogs = await _getSubscriptionAuditLogsWithHistoryUseCase(
        event.subscriptionId,
      );
      emit(
        GetSubscriptionAuditLogsWithHistorySuccess(
          auditLogs,
          event.subscriptionId,
        ),
      );
    } catch (e) {
      final message = handleException(
        e,
        context: 'get_subscription_audit_logs',
        metadata: {'subscriptionId': event.subscriptionId},
      );
      emit(
        GetSubscriptionAuditLogsWithHistoryError(message, event.subscriptionId),
      );
    }
  }

  Future<void> _onUpdateSubscriptionBcd(
    UpdateSubscriptionBcd event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(UpdateSubscriptionBcdLoading());
    try {
      final bcdUpdate = SubscriptionBcdUpdate(
        accountId: event.bcdData['accountId']!,
        bundleId: event.bcdData['bundleId']!,
        subscriptionId: event.bcdData['subscriptionId']!,
        startDate: DateTime.parse(event.bcdData['startDate']!),
        productName: event.bcdData['productName']!,
        productCategory: event.bcdData['productCategory']!,
        billingPeriod: event.bcdData['billingPeriod']!,
        priceList: event.bcdData['priceList']!,
        phaseType: event.bcdData['phaseType']!,
        billCycleDayLocal: event.bcdData['billCycleDayLocal']!,
      );

      final result = await _updateSubscriptionBcdUseCase(
        subscriptionId: event.subscriptionId,
        bcdUpdate: bcdUpdate,
      );
      emit(UpdateSubscriptionBcdSuccess(result, event.subscriptionId));
    } catch (e) {
      final message = handleException(
        e,
        context: 'update_subscription_bcd',
        metadata: {'subscriptionId': event.subscriptionId},
      );
      emit(UpdateSubscriptionBcdError(message, event.subscriptionId));
    }
  }
}
