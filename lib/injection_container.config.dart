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
import 'features/accounts/data/datasources/account_tags_remote_data_source.dart'
    as _i569;
import 'features/accounts/data/datasources/account_timeline_remote_data_source.dart'
    as _i817;
import 'features/accounts/data/datasources/accounts_remote_data_source.dart'
    as _i852;
import 'features/accounts/data/repositories/account_tags_repository_impl.dart'
    as _i813;
import 'features/accounts/data/repositories/account_timeline_repository_impl.dart'
    as _i735;
import 'features/accounts/data/repositories/accounts_repository_impl.dart'
    as _i395;
import 'features/accounts/domain/repositories/account_tags_repository.dart'
    as _i363;
import 'features/accounts/domain/repositories/account_timeline_repository.dart'
    as _i446;
import 'features/accounts/domain/repositories/accounts_repository.dart' as _i42;
import 'features/accounts/domain/usecases/create_account_usecase.dart' as _i968;
import 'features/accounts/domain/usecases/delete_account_usecase.dart' as _i823;
import 'features/accounts/domain/usecases/get_account_by_id_usecase.dart'
    as _i400;
import 'features/accounts/domain/usecases/get_account_tags_usecase.dart'
    as _i227;
import 'features/accounts/domain/usecases/get_account_timeline_usecase.dart'
    as _i711;
import 'features/accounts/domain/usecases/get_accounts_usecase.dart' as _i684;
import 'features/accounts/domain/usecases/update_account_usecase.dart' as _i651;
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
  gh.factory<_i852.AccountsRemoteDataSource>(
    () => _i852.AccountsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i569.AccountTagsRemoteDataSource>(
    () => _i569.AccountTagsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i817.AccountTimelineRemoteDataSource>(
    () => _i817.AccountTimelineRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i45.DioClient>(
    () => _i45.DioClient(gh<_i558.FlutterSecureStorage>()),
  );
  gh.factory<_i363.AccountTagsRepository>(
    () => _i813.AccountTagsRepositoryImpl(
      gh<_i569.AccountTagsRemoteDataSource>(),
    ),
  );
  gh.factory<_i767.AuthRemoteDataSource>(
    () => _i767.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i42.AccountsRepository>(
    () => _i395.AccountsRepositoryImpl(gh<_i852.AccountsRemoteDataSource>()),
  );
  gh.factory<_i493.SecureStorageService>(
    () => _i493.SecureStorageService(gh<_i558.FlutterSecureStorage>()),
  );
  gh.factory<_i227.GetAccountTagsUseCase>(
    () => _i227.GetAccountTagsUseCase(gh<_i363.AccountTagsRepository>()),
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
  gh.factory<_i1015.AuthRepository>(
    () => _i111.AuthRepositoryImpl(
      gh<_i767.AuthRemoteDataSource>(),
      gh<_i493.SecureStorageService>(),
      gh<_i842.JwtService>(),
    ),
  );
  gh.factory<_i446.AccountTimelineRepository>(
    () => _i735.AccountTimelineRepositoryImpl(
      gh<_i817.AccountTimelineRemoteDataSource>(),
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
  gh.factory<_i795.AccountsBloc>(
    () => _i795.AccountsBloc(
      getAccountsUseCase: gh<_i684.GetAccountsUseCase>(),
      getAccountByIdUseCase: gh<_i400.GetAccountByIdUseCase>(),
      createAccountUseCase: gh<_i968.CreateAccountUseCase>(),
      updateAccountUseCase: gh<_i651.UpdateAccountUseCase>(),
      deleteAccountUseCase: gh<_i823.DeleteAccountUseCase>(),
      getAccountTimelineUseCase: gh<_i711.GetAccountTimelineUseCase>(),
      getAccountTagsUseCase: gh<_i227.GetAccountTagsUseCase>(),
      accountsRepository: gh<_i42.AccountsRepository>(),
      accountTagsRepository: gh<_i363.AccountTagsRepository>(),
    ),
  );
  return getIt;
}

class _$InjectionModule extends _i670.InjectionModule {}
