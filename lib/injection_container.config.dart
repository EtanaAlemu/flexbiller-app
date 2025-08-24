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
  gh.factory<_i45.DioClient>(
    () => _i45.DioClient(gh<_i558.FlutterSecureStorage>()),
  );
  gh.factory<_i767.AuthRemoteDataSource>(
    () => _i767.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i493.SecureStorageService>(
    () => _i493.SecureStorageService(gh<_i558.FlutterSecureStorage>()),
  );
  gh.factory<_i1015.AuthRepository>(
    () => _i111.AuthRepositoryImpl(
      gh<_i767.AuthRemoteDataSource>(),
      gh<_i493.SecureStorageService>(),
      gh<_i842.JwtService>(),
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
  gh.factory<_i363.AuthBloc>(
    () => _i363.AuthBloc(
      loginUseCase: gh<_i206.LoginUseCase>(),
      forgotPasswordUseCase: gh<_i993.ForgotPasswordUseCase>(),
      changePasswordUseCase: gh<_i890.ChangePasswordUseCase>(),
      resetPasswordUseCase: gh<_i1070.ResetPasswordUseCase>(),
    ),
  );
  return getIt;
}

class _$InjectionModule extends _i670.InjectionModule {}
