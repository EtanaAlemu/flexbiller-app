import 'package:injectable/injectable.dart';
import '../../domain/entities/account_payment_method.dart';
import '../../domain/repositories/account_payment_methods_repository.dart';
import '../datasources/account_payment_methods_remote_data_source.dart';

@Injectable(as: AccountPaymentMethodsRepository)
class AccountPaymentMethodsRepositoryImpl implements AccountPaymentMethodsRepository {
  final AccountPaymentMethodsRemoteDataSource _remoteDataSource;

  AccountPaymentMethodsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AccountPaymentMethod>> getAccountPaymentMethods(String accountId) async {
    try {
      final methodModels = await _remoteDataSource.getAccountPaymentMethods(accountId);
      return methodModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethod> getAccountPaymentMethod(String accountId, String paymentMethodId) async {
    try {
      final methodModel = await _remoteDataSource.getAccountPaymentMethod(accountId, paymentMethodId);
      return methodModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethod?> getDefaultPaymentMethod(String accountId) async {
    try {
      final methodModel = await _remoteDataSource.getDefaultPaymentMethod(accountId);
      return methodModel?.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethod>> getActivePaymentMethods(String accountId) async {
    try {
      final methodModels = await _remoteDataSource.getActivePaymentMethods(accountId);
      return methodModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethod>> getPaymentMethodsByType(String accountId, String type) async {
    try {
      final methodModels = await _remoteDataSource.getPaymentMethodsByType(accountId, type);
      return methodModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethod> setDefaultPaymentMethod(
    String accountId,
    String paymentMethodId,
    bool payAllUnpaidInvoices,
  ) async {
    try {
      final methodModel = await _remoteDataSource.setDefaultPaymentMethod(
        accountId,
        paymentMethodId,
        payAllUnpaidInvoices,
      );
      return methodModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethod> createPaymentMethod(
    String accountId,
    String paymentMethodType,
    String paymentMethodName,
    Map<String, dynamic> paymentDetails,
  ) async {
    try {
      final methodModel = await _remoteDataSource.createPaymentMethod(
        accountId,
        paymentMethodType,
        paymentMethodName,
        paymentDetails,
      );
      return methodModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethod> updatePaymentMethod(
    String accountId,
    String paymentMethodId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final methodModel = await _remoteDataSource.updatePaymentMethod(
        accountId,
        paymentMethodId,
        updates,
      );
      return methodModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deletePaymentMethod(String accountId, String paymentMethodId) async {
    try {
      await _remoteDataSource.deletePaymentMethod(accountId, paymentMethodId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethod> deactivatePaymentMethod(String accountId, String paymentMethodId) async {
    try {
      final methodModel = await _remoteDataSource.deactivatePaymentMethod(accountId, paymentMethodId);
      return methodModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethod> reactivatePaymentMethod(String accountId, String paymentMethodId) async {
    try {
      final methodModel = await _remoteDataSource.reactivatePaymentMethod(accountId, paymentMethodId);
      return methodModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethod>> refreshPaymentMethods(String accountId) async {
    try {
      final methodModels = await _remoteDataSource.refreshPaymentMethods(accountId);
      return methodModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
