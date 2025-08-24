// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'core/injection/injection_module.dart' as _i670;
import 'core/network/dio_client.dart' as _i45;
import 'core/network/network_info.dart' as _i75;
import 'core/services/database_service.dart' as _i916;
import 'core/services/secure_storage_service.dart' as _i493;
import 'features/auth/data/repositories/auth_repository_impl.dart' as _i111;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/usecases/login_usecase.dart' as _i206;
import 'features/auth/presentation/bloc/auth_bloc.dart' as _i363;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final injectionModule = _$InjectionModule();
  gh.factory<_i916.DatabaseService>(() => _i916.DatabaseService());
  gh.factory<_i75.NetworkInfoImpl>(() => _i75.NetworkInfoImpl());
  gh.singleton<_i558.FlutterSecureStorage>(() => injectionModule.secureStorage);
  gh.factory<_i1015.AuthRepository>(() => _i111.AuthRepositoryImpl());
  gh.factory<_i45.DioClient>(
    () => _i45.DioClient(gh<_i558.FlutterSecureStorage>()),
  );
  gh.factory<_i206.LoginUseCase>(
    () => _i206.LoginUseCase(gh<_i1015.AuthRepository>()),
  );
  gh.factory<_i493.SecureStorageService>(
    () => _i493.SecureStorageService(gh<_i558.FlutterSecureStorage>()),
  );
  gh.factory<_i363.AuthBloc>(
    () => _i363.AuthBloc(loginUseCase: gh<_i206.LoginUseCase>()),
  );
  return getIt;
}

class _$InjectionModule extends _i670.InjectionModule {}
