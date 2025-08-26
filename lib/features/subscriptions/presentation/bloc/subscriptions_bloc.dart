import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
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
import '../../domain/entities/subscription_addon_product.dart';
import 'subscriptions_event.dart';
import 'subscriptions_state.dart';

@injectable
class SubscriptionsBloc extends Bloc<SubscriptionsEvent, SubscriptionsState> {
  final GetRecentSubscriptionsUseCase _getRecentSubscriptionsUseCase;
  final GetSubscriptionByIdUseCase _getSubscriptionByIdUseCase;
  final GetSubscriptionsForAccountUseCase _getSubscriptionsForAccountUseCase;
  final CreateSubscriptionUseCase _createSubscriptionUseCase;
  final UpdateSubscriptionUseCase _updateSubscriptionUseCase;
  final CancelSubscriptionUseCase _cancelSubscriptionUseCase;
  final AddSubscriptionCustomFieldsUseCase _addSubscriptionCustomFieldsUseCase;
  final GetSubscriptionCustomFieldsUseCase _getSubscriptionCustomFieldsUseCase;
  final UpdateSubscriptionCustomFieldsUseCase _updateSubscriptionCustomFieldsUseCase;
  final RemoveSubscriptionCustomFieldsUseCase _removeSubscriptionCustomFieldsUseCase;
  final BlockSubscriptionUseCase _blockSubscriptionUseCase;
  final CreateSubscriptionWithAddOnsUseCase _createSubscriptionWithAddOnsUseCase;
  final GetSubscriptionAuditLogsWithHistoryUseCase _getSubscriptionAuditLogsWithHistoryUseCase;

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
    on<GetSubscriptionAuditLogsWithHistory>(_onGetSubscriptionAuditLogsWithHistory);
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
      emit(SubscriptionsError(e.toString()));
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
      emit(SubscriptionsError(e.toString()));
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
      emit(SingleSubscriptionError(e.toString(), event.id));
    }
  }

  Future<void> _onGetSubscriptionsForAccount(
    GetSubscriptionsForAccount event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(AccountSubscriptionsLoading());
    try {
      final subscriptions = await _getSubscriptionsForAccountUseCase(event.accountId);
      emit(AccountSubscriptionsLoaded(subscriptions, event.accountId));
    } catch (e) {
      emit(AccountSubscriptionsError(e.toString(), event.accountId));
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
      emit(CreateSubscriptionError(e.toString()));
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
      emit(UpdateSubscriptionError(e.toString(), event.id));
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
      emit(CancelSubscriptionError(e.toString(), event.id));
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
      emit(AddSubscriptionCustomFieldsSuccess(customFields, event.subscriptionId));
    } catch (e) {
      emit(AddSubscriptionCustomFieldsError(e.toString(), event.subscriptionId));
    }
  }

  Future<void> _onGetSubscriptionCustomFields(
    GetSubscriptionCustomFields event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(SubscriptionCustomFieldsLoading());
    try {
      final customFields = await _getSubscriptionCustomFieldsUseCase(event.subscriptionId);
      emit(SubscriptionCustomFieldsLoaded(customFields, event.subscriptionId));
    } catch (e) {
      emit(SubscriptionCustomFieldsError(e.toString(), event.subscriptionId));
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
      emit(UpdateSubscriptionCustomFieldsSuccess(customFields, event.subscriptionId));
    } catch (e) {
      emit(UpdateSubscriptionCustomFieldsError(e.toString(), event.subscriptionId));
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
      emit(RemoveSubscriptionCustomFieldsError(e.toString(), event.subscriptionId));
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
      emit(BlockSubscriptionError(e.toString(), event.subscriptionId));
    }
  }

  Future<void> _onCreateSubscriptionWithAddOns(
    CreateSubscriptionWithAddOns event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(CreateSubscriptionWithAddOnsLoading());
    try {
      final addonProducts = event.addonProducts.map((addon) => 
        SubscriptionAddonProduct(
          accountId: addon['accountId']!,
          productName: addon['productName']!,
          productCategory: addon['productCategory']!,
          billingPeriod: addon['billingPeriod']!,
          priceList: addon['priceList']!,
        )
      ).toList();

      final result = await _createSubscriptionWithAddOnsUseCase(
        addonProducts: addonProducts,
      );
      emit(CreateSubscriptionWithAddOnsSuccess(result));
    } catch (e) {
      emit(CreateSubscriptionWithAddOnsError(e.toString()));
    }
  }

  Future<void> _onGetSubscriptionAuditLogsWithHistory(
    GetSubscriptionAuditLogsWithHistory event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(GetSubscriptionAuditLogsWithHistoryLoading());
    try {
      final auditLogs = await _getSubscriptionAuditLogsWithHistoryUseCase(event.subscriptionId);
      emit(GetSubscriptionAuditLogsWithHistorySuccess(auditLogs, event.subscriptionId));
    } catch (e) {
      emit(GetSubscriptionAuditLogsWithHistoryError(e.toString(), event.subscriptionId));
    }
  }
}
