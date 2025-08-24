// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'core/injection/injection_module.dart' as _i670;
import 'core/network/dio_client.dart' as _i45;
import 'core/network/network_info.dart' as _i75;
import 'core/services/database_service.dart' as _i916;
import 'core/services/jwt_service.dart' as _i842;
import 'core/services/secure_storage_service.dart' as _i493;
import 'features/accounts/data/datasources/account_audit_logs_remote_data_source.dart'
    as _i276;
import 'features/accounts/data/datasources/account_blocking_states_remote_data_source.dart'
    as _i819;
import 'features/accounts/data/datasources/account_custom_fields_remote_data_source.dart'
    as _i608;
import 'features/accounts/data/datasources/account_emails_remote_data_source.dart'
    as _i606;
import 'features/accounts/data/datasources/account_invoice_payments_remote_data_source.dart'
    as _i976;
import 'features/accounts/data/datasources/account_payment_methods_remote_data_source.dart'
    as _i361;
import 'features/accounts/data/datasources/account_payments_remote_data_source.dart'
    as _i164;
import 'features/accounts/data/datasources/account_tags_remote_data_source.dart'
    as _i569;
import 'features/accounts/data/datasources/account_timeline_remote_data_source.dart'
    as _i817;
import 'features/accounts/data/datasources/accounts_remote_data_source.dart'
    as _i852;
import 'features/accounts/data/repositories/account_audit_logs_repository_impl.dart'
    as _i510;
import 'features/accounts/data/repositories/account_blocking_states_repository_impl.dart'
    as _i552;
import 'features/accounts/data/repositories/account_custom_fields_repository_impl.dart'
    as _i762;
import 'features/accounts/data/repositories/account_emails_repository_impl.dart'
    as _i31;
import 'features/accounts/data/repositories/account_invoice_payments_repository_impl.dart'
    as _i636;
import 'features/accounts/data/repositories/account_payment_methods_repository_impl.dart'
    as _i421;
import 'features/accounts/data/repositories/account_payments_repository_impl.dart'
    as _i626;
import 'features/accounts/data/repositories/account_tags_repository_impl.dart'
    as _i813;
import 'features/accounts/data/repositories/account_timeline_repository_impl.dart'
    as _i735;
import 'features/accounts/data/repositories/accounts_repository_impl.dart'
    as _i395;
import 'features/accounts/domain/repositories/account_audit_logs_repository.dart'
    as _i271;
import 'features/accounts/domain/repositories/account_blocking_states_repository.dart'
    as _i696;
import 'features/accounts/domain/repositories/account_custom_fields_repository.dart'
    as _i221;
import 'features/accounts/domain/repositories/account_emails_repository.dart'
    as _i330;
import 'features/accounts/domain/repositories/account_invoice_payments_repository.dart'
    as _i378;
import 'features/accounts/domain/repositories/account_payment_methods_repository.dart'
    as _i845;
import 'features/accounts/domain/repositories/account_payments_repository.dart'
    as _i1054;
import 'features/accounts/domain/repositories/account_tags_repository.dart'
    as _i363;
import 'features/accounts/domain/repositories/account_timeline_repository.dart'
    as _i446;
import 'features/accounts/domain/repositories/accounts_repository.dart' as _i42;
import 'features/accounts/domain/usecases/assign_multiple_tags_to_account_usecase.dart'
    as _i377;
import 'features/accounts/domain/usecases/create_account_custom_field_usecase.dart'
    as _i629;
import 'features/accounts/domain/usecases/create_account_usecase.dart' as _i968;
import 'features/accounts/domain/usecases/create_invoice_payment_usecase.dart'
    as _i350;
import 'features/accounts/domain/usecases/create_multiple_account_custom_fields_usecase.dart'
    as _i234;
import 'features/accounts/domain/usecases/delete_account_custom_field_usecase.dart'
    as _i336;
import 'features/accounts/domain/usecases/delete_account_usecase.dart' as _i823;
import 'features/accounts/domain/usecases/delete_multiple_account_custom_fields_usecase.dart'
    as _i82;
import 'features/accounts/domain/usecases/get_account_audit_logs_usecase.dart'
    as _i657;
import 'features/accounts/domain/usecases/get_account_blocking_states_usecase.dart'
    as _i729;
import 'features/accounts/domain/usecases/get_account_by_id_usecase.dart'
    as _i400;
import 'features/accounts/domain/usecases/get_account_custom_fields_usecase.dart'
    as _i397;
import 'features/accounts/domain/usecases/get_account_emails_usecase.dart'
    as _i334;
import 'features/accounts/domain/usecases/get_account_invoice_payments_usecase.dart'
    as _i584;
import 'features/accounts/domain/usecases/get_account_payment_methods_usecase.dart'
    as _i600;
import 'features/accounts/domain/usecases/get_account_payments_usecase.dart'
    as _i374;
import 'features/accounts/domain/usecases/get_account_tags_usecase.dart'
    as _i227;
import 'features/accounts/domain/usecases/get_account_timeline_usecase.dart'
    as _i711;
import 'features/accounts/domain/usecases/get_accounts_usecase.dart' as _i684;
import 'features/accounts/domain/usecases/get_all_tags_for_account_usecase.dart'
    as _i384;
import 'features/accounts/domain/usecases/refresh_payment_methods_usecase.dart'
    as _i905;
import 'features/accounts/domain/usecases/remove_multiple_tags_from_account_usecase.dart'
    as _i582;
import 'features/accounts/domain/usecases/search_accounts_usecase.dart'
    as _i266;
import 'features/accounts/domain/usecases/set_default_payment_method_usecase.dart'
    as _i580;
import 'features/accounts/domain/usecases/update_account_custom_field_usecase.dart'
    as _i734;
import 'features/accounts/domain/usecases/update_account_usecase.dart' as _i651;
import 'features/accounts/domain/usecases/update_multiple_account_custom_fields_usecase.dart'
    as _i435;
import 'features/accounts/presentation/bloc/accounts_bloc.dart' as _i795;
import 'features/auth/data/datasources/auth_remote_data_source.dart' as _i767;
import 'features/auth/data/repositories/auth_repository_impl.dart' as _i111;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/usecases/change_password_usecase.dart' as _i890;
import 'features/auth/domain/usecases/forgot_password_usecase.dart' as _i993;
import 'features/auth/domain/usecases/login_usecase.dart' as _i206;
import 'features/auth/domain/usecases/reset_password_usecase.dart' as _i1070;
import 'features/auth/presentation/bloc/auth_bloc.dart' as _i363;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final injectionModule = _$InjectionModule();
  gh.factory<_i842.JwtService>(() => _i842.JwtService());
  gh.factory<_i916.DatabaseService>(() => _i916.DatabaseService());
  gh.factory<_i75.NetworkInfoImpl>(() => _i75.NetworkInfoImpl());
  gh.singleton<_i558.FlutterSecureStorage>(() => injectionModule.secureStorage);
  gh.singleton<_i361.Dio>(() => injectionModule.dio);
  gh.factory<_i276.AccountAuditLogsRemoteDataSource>(
    () => _i276.AccountAuditLogsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i164.AccountPaymentsRemoteDataSource>(
    () => _i164.AccountPaymentsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i852.AccountsRemoteDataSource>(
    () => _i852.AccountsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i1054.AccountPaymentsRepository>(
    () => _i626.AccountPaymentsRepositoryImpl(
      gh<_i164.AccountPaymentsRemoteDataSource>(),
    ),
  );
  gh.factory<_i569.AccountTagsRemoteDataSource>(
    () => _i569.AccountTagsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i606.AccountEmailsRemoteDataSource>(
    () => _i606.AccountEmailsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i374.GetAccountPaymentsUseCase>(
    () =>
        _i374.GetAccountPaymentsUseCase(gh<_i1054.AccountPaymentsRepository>()),
  );
  gh.factory<_i608.AccountCustomFieldsRemoteDataSource>(
    () => _i608.AccountCustomFieldsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i817.AccountTimelineRemoteDataSource>(
    () => _i817.AccountTimelineRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i976.AccountInvoicePaymentsRemoteDataSource>(
    () => _i976.AccountInvoicePaymentsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i271.AccountAuditLogsRepository>(
    () => _i510.AccountAuditLogsRepositoryImpl(
      gh<_i276.AccountAuditLogsRemoteDataSource>(),
    ),
  );
  gh.factory<_i45.DioClient>(
    () => _i45.DioClient(gh<_i558.FlutterSecureStorage>()),
  );
  gh.factory<_i819.AccountBlockingStatesRemoteDataSource>(
    () => _i819.AccountBlockingStatesRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i363.AccountTagsRepository>(
    () => _i813.AccountTagsRepositoryImpl(
      gh<_i569.AccountTagsRemoteDataSource>(),
    ),
  );
  gh.factory<_i657.GetAccountAuditLogsUseCase>(
    () => _i657.GetAccountAuditLogsUseCase(
      gh<_i271.AccountAuditLogsRepository>(),
    ),
  );
  gh.factory<_i361.AccountPaymentMethodsRemoteDataSource>(
    () => _i361.AccountPaymentMethodsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i767.AuthRemoteDataSource>(
    () => _i767.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i221.AccountCustomFieldsRepository>(
    () => _i762.AccountCustomFieldsRepositoryImpl(
      gh<_i608.AccountCustomFieldsRemoteDataSource>(),
    ),
  );
  gh.factory<_i42.AccountsRepository>(
    () => _i395.AccountsRepositoryImpl(gh<_i852.AccountsRemoteDataSource>()),
  );
  gh.factory<_i330.AccountEmailsRepository>(
    () => _i31.AccountEmailsRepositoryImpl(
      gh<_i606.AccountEmailsRemoteDataSource>(),
    ),
  );
  gh.factory<_i696.AccountBlockingStatesRepository>(
    () => _i552.AccountBlockingStatesRepositoryImpl(
      gh<_i819.AccountBlockingStatesRemoteDataSource>(),
    ),
  );
  gh.factory<_i493.SecureStorageService>(
    () => _i493.SecureStorageService(gh<_i558.FlutterSecureStorage>()),
  );
  gh.factory<_i227.GetAccountTagsUseCase>(
    () => _i227.GetAccountTagsUseCase(gh<_i363.AccountTagsRepository>()),
  );
  gh.factory<_i384.GetAllTagsForAccountUseCase>(
    () => _i384.GetAllTagsForAccountUseCase(gh<_i363.AccountTagsRepository>()),
  );
  gh.factory<_i377.AssignMultipleTagsToAccountUseCase>(
    () => _i377.AssignMultipleTagsToAccountUseCase(
      gh<_i363.AccountTagsRepository>(),
    ),
  );
  gh.factory<_i582.RemoveMultipleTagsFromAccountUseCase>(
    () => _i582.RemoveMultipleTagsFromAccountUseCase(
      gh<_i363.AccountTagsRepository>(),
    ),
  );
  gh.factory<_i400.GetAccountByIdUseCase>(
    () => _i400.GetAccountByIdUseCase(gh<_i42.AccountsRepository>()),
  );
  gh.factory<_i684.GetAccountsUseCase>(
    () => _i684.GetAccountsUseCase(gh<_i42.AccountsRepository>()),
  );
  gh.factory<_i968.CreateAccountUseCase>(
    () => _i968.CreateAccountUseCase(gh<_i42.AccountsRepository>()),
  );
  gh.factory<_i651.UpdateAccountUseCase>(
    () => _i651.UpdateAccountUseCase(gh<_i42.AccountsRepository>()),
  );
  gh.factory<_i823.DeleteAccountUseCase>(
    () => _i823.DeleteAccountUseCase(gh<_i42.AccountsRepository>()),
  );
  gh.factory<_i266.SearchAccountsUseCase>(
    () => _i266.SearchAccountsUseCase(gh<_i42.AccountsRepository>()),
  );
  gh.factory<_i1015.AuthRepository>(
    () => _i111.AuthRepositoryImpl(
      gh<_i767.AuthRemoteDataSource>(),
      gh<_i493.SecureStorageService>(),
      gh<_i842.JwtService>(),
    ),
  );
  gh.factory<_i378.AccountInvoicePaymentsRepository>(
    () => _i636.AccountInvoicePaymentsRepositoryImpl(
      gh<_i976.AccountInvoicePaymentsRemoteDataSource>(),
    ),
  );
  gh.factory<_i845.AccountPaymentMethodsRepository>(
    () => _i421.AccountPaymentMethodsRepositoryImpl(
      gh<_i361.AccountPaymentMethodsRemoteDataSource>(),
    ),
  );
  gh.factory<_i334.GetAccountEmailsUseCase>(
    () => _i334.GetAccountEmailsUseCase(gh<_i330.AccountEmailsRepository>()),
  );
  gh.factory<_i446.AccountTimelineRepository>(
    () => _i735.AccountTimelineRepositoryImpl(
      gh<_i817.AccountTimelineRemoteDataSource>(),
    ),
  );
  gh.factory<_i336.DeleteAccountCustomFieldUseCase>(
    () => _i336.DeleteAccountCustomFieldUseCase(
      gh<_i221.AccountCustomFieldsRepository>(),
    ),
  );
  gh.factory<_i734.UpdateAccountCustomFieldUseCase>(
    () => _i734.UpdateAccountCustomFieldUseCase(
      gh<_i221.AccountCustomFieldsRepository>(),
    ),
  );
  gh.factory<_i397.GetAccountCustomFieldsUseCase>(
    () => _i397.GetAccountCustomFieldsUseCase(
      gh<_i221.AccountCustomFieldsRepository>(),
    ),
  );
  gh.factory<_i629.CreateAccountCustomFieldUseCase>(
    () => _i629.CreateAccountCustomFieldUseCase(
      gh<_i221.AccountCustomFieldsRepository>(),
    ),
  );
  gh.factory<_i234.CreateMultipleAccountCustomFieldsUseCase>(
    () => _i234.CreateMultipleAccountCustomFieldsUseCase(
      gh<_i221.AccountCustomFieldsRepository>(),
    ),
  );
  gh.factory<_i435.UpdateMultipleAccountCustomFieldsUseCase>(
    () => _i435.UpdateMultipleAccountCustomFieldsUseCase(
      gh<_i221.AccountCustomFieldsRepository>(),
    ),
  );
  gh.factory<_i82.DeleteMultipleAccountCustomFieldsUseCase>(
    () => _i82.DeleteMultipleAccountCustomFieldsUseCase(
      gh<_i221.AccountCustomFieldsRepository>(),
    ),
  );
  gh.factory<_i729.GetAccountBlockingStatesUseCase>(
    () => _i729.GetAccountBlockingStatesUseCase(
      gh<_i696.AccountBlockingStatesRepository>(),
    ),
  );
  gh.factory<_i580.SetDefaultPaymentMethodUseCase>(
    () => _i580.SetDefaultPaymentMethodUseCase(
      gh<_i845.AccountPaymentMethodsRepository>(),
    ),
  );
  gh.factory<_i600.GetAccountPaymentMethodsUseCase>(
    () => _i600.GetAccountPaymentMethodsUseCase(
      gh<_i845.AccountPaymentMethodsRepository>(),
    ),
  );
  gh.factory<_i905.RefreshPaymentMethodsUseCase>(
    () => _i905.RefreshPaymentMethodsUseCase(
      gh<_i845.AccountPaymentMethodsRepository>(),
    ),
  );
  gh.factory<_i993.ForgotPasswordUseCase>(
    () => _i993.ForgotPasswordUseCase(gh<_i1015.AuthRepository>()),
  );
  gh.factory<_i206.LoginUseCase>(
    () => _i206.LoginUseCase(gh<_i1015.AuthRepository>()),
  );
  gh.factory<_i890.ChangePasswordUseCase>(
    () => _i890.ChangePasswordUseCase(gh<_i1015.AuthRepository>()),
  );
  gh.factory<_i1070.ResetPasswordUseCase>(
    () => _i1070.ResetPasswordUseCase(gh<_i1015.AuthRepository>()),
  );
  gh.factory<_i711.GetAccountTimelineUseCase>(
    () =>
        _i711.GetAccountTimelineUseCase(gh<_i446.AccountTimelineRepository>()),
  );
  gh.factory<_i363.AuthBloc>(
    () => _i363.AuthBloc(
      loginUseCase: gh<_i206.LoginUseCase>(),
      forgotPasswordUseCase: gh<_i993.ForgotPasswordUseCase>(),
      changePasswordUseCase: gh<_i890.ChangePasswordUseCase>(),
      resetPasswordUseCase: gh<_i1070.ResetPasswordUseCase>(),
    ),
  );
  gh.factory<_i584.GetAccountInvoicePaymentsUseCase>(
    () => _i584.GetAccountInvoicePaymentsUseCase(
      gh<_i378.AccountInvoicePaymentsRepository>(),
    ),
  );
  gh.factory<_i350.CreateInvoicePaymentUseCase>(
    () => _i350.CreateInvoicePaymentUseCase(
      gh<_i378.AccountInvoicePaymentsRepository>(),
    ),
  );
  gh.factory<_i795.AccountsBloc>(
    () => _i795.AccountsBloc(
      getAccountsUseCase: gh<_i684.GetAccountsUseCase>(),
      searchAccountsUseCase: gh<_i266.SearchAccountsUseCase>(),
      getAccountByIdUseCase: gh<_i400.GetAccountByIdUseCase>(),
      createAccountUseCase: gh<_i968.CreateAccountUseCase>(),
      updateAccountUseCase: gh<_i651.UpdateAccountUseCase>(),
      deleteAccountUseCase: gh<_i823.DeleteAccountUseCase>(),
      getAccountTimelineUseCase: gh<_i711.GetAccountTimelineUseCase>(),
      getAccountTagsUseCase: gh<_i227.GetAccountTagsUseCase>(),
      getAllTagsForAccountUseCase: gh<_i384.GetAllTagsForAccountUseCase>(),
      assignMultipleTagsToAccountUseCase:
          gh<_i377.AssignMultipleTagsToAccountUseCase>(),
      removeMultipleTagsFromAccountUseCase:
          gh<_i582.RemoveMultipleTagsFromAccountUseCase>(),
      getAccountCustomFieldsUseCase: gh<_i397.GetAccountCustomFieldsUseCase>(),
      createAccountCustomFieldUseCase:
          gh<_i629.CreateAccountCustomFieldUseCase>(),
      createMultipleAccountCustomFieldsUseCase:
          gh<_i234.CreateMultipleAccountCustomFieldsUseCase>(),
      updateAccountCustomFieldUseCase:
          gh<_i734.UpdateAccountCustomFieldUseCase>(),
      updateMultipleAccountCustomFieldsUseCase:
          gh<_i435.UpdateMultipleAccountCustomFieldsUseCase>(),
      deleteAccountCustomFieldUseCase:
          gh<_i336.DeleteAccountCustomFieldUseCase>(),
      deleteMultipleAccountCustomFieldsUseCase:
          gh<_i82.DeleteMultipleAccountCustomFieldsUseCase>(),
      getAccountEmailsUseCase: gh<_i334.GetAccountEmailsUseCase>(),
      getAccountBlockingStatesUseCase:
          gh<_i729.GetAccountBlockingStatesUseCase>(),
      getAccountInvoicePaymentsUseCase:
          gh<_i584.GetAccountInvoicePaymentsUseCase>(),
      createInvoicePaymentUseCase: gh<_i350.CreateInvoicePaymentUseCase>(),
      getAccountAuditLogsUseCase: gh<_i657.GetAccountAuditLogsUseCase>(),
      getAccountPaymentMethodsUseCase:
          gh<_i600.GetAccountPaymentMethodsUseCase>(),
      setDefaultPaymentMethodUseCase:
          gh<_i580.SetDefaultPaymentMethodUseCase>(),
      refreshPaymentMethodsUseCase: gh<_i905.RefreshPaymentMethodsUseCase>(),
      getAccountPaymentsUseCase: gh<_i374.GetAccountPaymentsUseCase>(),
      accountsRepository: gh<_i42.AccountsRepository>(),
      accountTagsRepository: gh<_i363.AccountTagsRepository>(),
      accountCustomFieldsRepository: gh<_i221.AccountCustomFieldsRepository>(),
      accountEmailsRepository: gh<_i330.AccountEmailsRepository>(),
    ),
  );
  return getIt;
}

class _$InjectionModule extends _i670.InjectionModule {}
