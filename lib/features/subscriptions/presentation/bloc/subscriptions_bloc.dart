import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_recent_subscriptions_usecase.dart';
import '../../domain/usecases/get_subscription_by_id_usecase.dart';
import '../../domain/usecases/get_subscriptions_for_account_usecase.dart';
import '../../domain/usecases/create_subscription_usecase.dart';
import 'subscriptions_event.dart';
import 'subscriptions_state.dart';

@injectable
class SubscriptionsBloc extends Bloc<SubscriptionsEvent, SubscriptionsState> {
  final GetRecentSubscriptionsUseCase _getRecentSubscriptionsUseCase;
  final GetSubscriptionByIdUseCase _getSubscriptionByIdUseCase;
  final GetSubscriptionsForAccountUseCase _getSubscriptionsForAccountUseCase;
  final CreateSubscriptionUseCase _createSubscriptionUseCase;

  SubscriptionsBloc(
    this._getRecentSubscriptionsUseCase,
    this._getSubscriptionByIdUseCase,
    this._getSubscriptionsForAccountUseCase,
    this._createSubscriptionUseCase,
  ) : super(SubscriptionsInitial()) {
    on<LoadRecentSubscriptions>(_onLoadRecentSubscriptions);
    on<RefreshSubscriptions>(_onRefreshSubscriptions);
    on<LoadSubscriptionById>(_onLoadSubscriptionById);
    on<LoadSubscriptionsForAccount>(_onLoadSubscriptionsForAccount);
    on<CreateSubscription>(_onCreateSubscription);
  }

  Future<void> _onLoadRecentSubscriptions(
    LoadRecentSubscriptions event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(SubscriptionsLoading());
    try {
      final subscriptions = await _getRecentSubscriptionsUseCase();
      emit(SubscriptionsLoaded(subscriptions));
    } catch (e) {
      emit(SubscriptionsError(e.toString()));
    }
  }

  Future<void> _onRefreshSubscriptions(
    RefreshSubscriptions event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(SubscriptionsLoading());
    try {
      final subscriptions = await _getRecentSubscriptionsUseCase();
      emit(SubscriptionsLoaded(subscriptions));
    } catch (e) {
      emit(SubscriptionsError(e.toString()));
    }
  }

  Future<void> _onLoadSubscriptionById(
    LoadSubscriptionById event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(SingleSubscriptionLoading());
    try {
      final subscription = await _getSubscriptionByIdUseCase(
        event.subscriptionId,
      );
      emit(SingleSubscriptionLoaded(subscription));
    } catch (e) {
      emit(SingleSubscriptionError(e.toString()));
    }
  }

  Future<void> _onLoadSubscriptionsForAccount(
    LoadSubscriptionsForAccount event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(AccountSubscriptionsLoading());
    try {
      final subscriptions = await _getSubscriptionsForAccountUseCase(
        event.accountId,
      );
      emit(
        AccountSubscriptionsLoaded(
          accountId: event.accountId,
          subscriptions: subscriptions,
        ),
      );
    } catch (e) {
      emit(AccountSubscriptionsError(e.toString()));
    }
  }

  Future<void> _onCreateSubscription(
    CreateSubscription event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(CreateSubscriptionLoading());
    try {
      final subscription = await _createSubscriptionUseCase(
        event.accountId,
        event.planName,
      );
      emit(CreateSubscriptionSuccess(subscription));
    } catch (e) {
      emit(CreateSubscriptionError(e.toString()));
    }
  }
}
