import 'package:injectable/injectable.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscriptions_repository.dart';
import '../datasources/subscriptions_remote_data_source.dart';

@Injectable(as: SubscriptionsRepository)
class SubscriptionsRepositoryImpl implements SubscriptionsRepository {
  final SubscriptionsRemoteDataSource _remoteDataSource;

  SubscriptionsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Subscription>> getRecentSubscriptions() async {
    try {
      final subscriptionModels = await _remoteDataSource
          .getRecentSubscriptions();
      return subscriptionModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Subscription> getSubscriptionById(String subscriptionId) async {
    try {
      final subscriptionModel = await _remoteDataSource.getSubscriptionById(
        subscriptionId,
      );
      return subscriptionModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Subscription>> getSubscriptionsForAccount(
    String accountId,
  ) async {
    try {
      final subscriptionModels = await _remoteDataSource
          .getSubscriptionsForAccount(accountId);
      return subscriptionModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Subscription> createSubscription(
    String accountId,
    String planName,
  ) async {
    try {
      final subscriptionModel = await _remoteDataSource.createSubscription(
        accountId,
        planName,
      );
      return subscriptionModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Subscription> updateSubscription(String subscriptionId, Map<String, dynamic> updateData) async {
    try {
      final subscriptionModel = await _remoteDataSource.updateSubscription(
        subscriptionId,
        updateData,
      );
      return subscriptionModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
