// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_crashlytics/firebase_crashlytics.dart' as _i141;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:local_auth/local_auth.dart' as _i152;
import 'package:logger/logger.dart' as _i974;

import 'core/injection/analytics_module.dart' as _i950;
import 'core/injection/injection_module.dart' as _i670;
import 'core/network/dio_client.dart' as _i45;
import 'core/network/network_info.dart' as _i75;
import 'core/services/auth_guard_service.dart' as _i280;
import 'core/services/authentication_state_service.dart' as _i751;
import 'core/services/biometric_auth_service.dart' as _i626;
import 'core/services/cache_service.dart' as _i325;
import 'core/services/crash_analytics_config.dart' as _i1059;
import 'core/services/crash_analytics_initializer.dart' as _i563;
import 'core/services/crash_analytics_service.dart' as _i924;
import 'core/services/database_service.dart' as _i916;
import 'core/services/database_service_backup.dart' as _i683;
import 'core/services/export_service.dart' as _i580;
import 'core/services/jwt_service.dart' as _i842;
import 'core/services/mock_crash_analytics_service.dart' as _i579;
import 'core/services/secure_storage_service.dart' as _i493;
import 'core/services/sync_service.dart' as _i443;
import 'core/services/user_persistence_service.dart' as _i915;
import 'core/services/user_session_service.dart' as _i140;
import 'features/accounts/data/datasources/local/account_audit_logs_local_data_source.dart'
    as _i273;
import 'features/accounts/data/datasources/local/account_blocking_states_local_data_source.dart'
    as _i804;
import 'features/accounts/data/datasources/local/account_custom_fields_local_data_source.dart'
    as _i632;
import 'features/accounts/data/datasources/local/account_emails_local_data_source.dart'
    as _i929;
import 'features/accounts/data/datasources/local/account_invoice_payments_local_data_source.dart'
    as _i250;
import 'features/accounts/data/datasources/local/account_invoices_local_data_source.dart'
    as _i377;
import 'features/accounts/data/datasources/local/account_payment_methods_local_data_source.dart'
    as _i275;
import 'features/accounts/data/datasources/local/account_payments_local_data_source.dart'
    as _i1023;
import 'features/accounts/data/datasources/local/account_tags_local_data_source.dart'
    as _i201;
import 'features/accounts/data/datasources/local/account_timeline_local_data_source.dart'
    as _i474;
import 'features/accounts/data/datasources/local/accounts_local_data_source.dart'
    as _i339;
import 'features/accounts/data/datasources/local/child_account_local_data_source.dart'
    as _i895;
import 'features/accounts/data/datasources/remote/account_audit_logs_remote_data_source.dart'
    as _i172;
import 'features/accounts/data/datasources/remote/account_blocking_states_remote_data_source.dart'
    as _i1063;
import 'features/accounts/data/datasources/remote/account_bundles_remote_data_source.dart'
    as _i421;
import 'features/accounts/data/datasources/remote/account_cba_rebalancing_remote_data_source.dart'
    as _i886;
import 'features/accounts/data/datasources/remote/account_custom_fields_remote_data_source.dart'
    as _i241;
import 'features/accounts/data/datasources/remote/account_emails_remote_data_source.dart'
    as _i676;
import 'features/accounts/data/datasources/remote/account_export_remote_data_source.dart'
    as _i1020;
import 'features/accounts/data/datasources/remote/account_invoice_payments_remote_data_source.dart'
    as _i961;
import 'features/accounts/data/datasources/remote/account_invoices_remote_data_source.dart'
    as _i225;
import 'features/accounts/data/datasources/remote/account_overdue_state_remote_data_source.dart'
    as _i505;
import 'features/accounts/data/datasources/remote/account_payment_methods_remote_data_source.dart'
    as _i975;
import 'features/accounts/data/datasources/remote/account_payments_remote_data_source.dart'
    as _i913;
import 'features/accounts/data/datasources/remote/account_tags_remote_data_source.dart'
    as _i1042;
import 'features/accounts/data/datasources/remote/account_timeline_remote_data_source.dart'
    as _i5;
import 'features/accounts/data/datasources/remote/accounts_remote_data_source.dart'
    as _i3;
import 'features/accounts/data/datasources/remote/child_account_remote_data_source.dart'
    as _i1058;
import 'features/accounts/data/repositories/account_audit_logs_repository_impl.dart'
    as _i510;
import 'features/accounts/data/repositories/account_blocking_states_repository_impl.dart'
    as _i552;
import 'features/accounts/data/repositories/account_cba_rebalancing_repository_impl.dart'
    as _i761;
import 'features/accounts/data/repositories/account_custom_fields_repository_impl.dart'
    as _i762;
import 'features/accounts/data/repositories/account_emails_repository_impl.dart'
    as _i31;
import 'features/accounts/data/repositories/account_export_repository_impl.dart'
    as _i973;
import 'features/accounts/data/repositories/account_invoice_payments_repository_impl.dart'
    as _i636;
import 'features/accounts/data/repositories/account_invoices_repository_impl.dart'
    as _i309;
import 'features/accounts/data/repositories/account_overdue_state_repository_impl.dart'
    as _i681;
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
import 'features/accounts/data/repositories/child_account_repository_impl.dart'
    as _i311;
import 'features/accounts/domain/repositories/account_audit_logs_repository.dart'
    as _i271;
import 'features/accounts/domain/repositories/account_blocking_states_repository.dart'
    as _i696;
import 'features/accounts/domain/repositories/account_cba_rebalancing_repository.dart'
    as _i1067;
import 'features/accounts/domain/repositories/account_custom_fields_repository.dart'
    as _i221;
import 'features/accounts/domain/repositories/account_emails_repository.dart'
    as _i330;
import 'features/accounts/domain/repositories/account_export_repository.dart'
    as _i930;
import 'features/accounts/domain/repositories/account_invoice_payments_repository.dart'
    as _i378;
import 'features/accounts/domain/repositories/account_invoices_repository.dart'
    as _i521;
import 'features/accounts/domain/repositories/account_overdue_state_repository.dart'
    as _i455;
import 'features/accounts/domain/repositories/account_payment_methods_repository.dart'
    as _i845;
import 'features/accounts/domain/repositories/account_payments_repository.dart'
    as _i1054;
import 'features/accounts/domain/repositories/account_tags_repository.dart'
    as _i363;
import 'features/accounts/domain/repositories/account_timeline_repository.dart'
    as _i446;
import 'features/accounts/domain/repositories/accounts_repository.dart' as _i42;
import 'features/accounts/domain/repositories/child_account_repository.dart'
    as _i596;
import 'features/accounts/domain/usecases/assign_multiple_tags_to_account_usecase.dart'
    as _i377;
import 'features/accounts/domain/usecases/assign_tag_to_account_usecase.dart'
    as _i221;
import 'features/accounts/domain/usecases/create_account_custom_field_usecase.dart'
    as _i629;
import 'features/accounts/domain/usecases/create_account_payment_usecase.dart'
    as _i463;
import 'features/accounts/domain/usecases/create_account_usecase.dart' as _i968;
import 'features/accounts/domain/usecases/create_child_account_usecase.dart'
    as _i743;
import 'features/accounts/domain/usecases/create_global_payment_usecase.dart'
    as _i1047;
import 'features/accounts/domain/usecases/create_invoice_payment_usecase.dart'
    as _i350;
import 'features/accounts/domain/usecases/create_multiple_account_custom_fields_usecase.dart'
    as _i234;
import 'features/accounts/domain/usecases/create_tag_usecase.dart' as _i0;
import 'features/accounts/domain/usecases/delete_account_custom_field_usecase.dart'
    as _i336;
import 'features/accounts/domain/usecases/delete_account_usecase.dart' as _i823;
import 'features/accounts/domain/usecases/delete_multiple_account_custom_fields_usecase.dart'
    as _i82;
import 'features/accounts/domain/usecases/delete_tag_usecase.dart' as _i277;
import 'features/accounts/domain/usecases/export_account_data_usecase.dart'
    as _i553;
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
import 'features/accounts/domain/usecases/get_child_accounts_usecase.dart'
    as _i88;
import 'features/accounts/domain/usecases/get_invoices_usecase.dart' as _i747;
import 'features/accounts/domain/usecases/get_overdue_state_usecase.dart'
    as _i512;
import 'features/accounts/domain/usecases/get_paginated_invoices_usecase.dart'
    as _i887;
import 'features/accounts/domain/usecases/rebalance_cba_usecase.dart' as _i84;
import 'features/accounts/domain/usecases/refresh_account_tags_usecase.dart'
    as _i911;
import 'features/accounts/domain/usecases/refresh_payment_methods_usecase.dart'
    as _i905;
import 'features/accounts/domain/usecases/refund_account_payment_usecase.dart'
    as _i781;
import 'features/accounts/domain/usecases/remove_multiple_tags_from_account_usecase.dart'
    as _i582;
import 'features/accounts/domain/usecases/remove_tag_from_account_usecase.dart'
    as _i279;
import 'features/accounts/domain/usecases/search_accounts_usecase.dart'
    as _i266;
import 'features/accounts/domain/usecases/set_default_payment_method_use_case.dart'
    as _i706;
import 'features/accounts/domain/usecases/update_account_custom_field_usecase.dart'
    as _i734;
import 'features/accounts/domain/usecases/update_account_usecase.dart' as _i651;
import 'features/accounts/domain/usecases/update_multiple_account_custom_fields_usecase.dart'
    as _i435;
import 'features/accounts/domain/usecases/update_tag_usecase.dart' as _i677;
import 'features/accounts/presentation/bloc/account_custom_fields_bloc.dart'
    as _i1008;
import 'features/accounts/presentation/bloc/account_detail_bloc.dart' as _i219;
import 'features/accounts/presentation/bloc/account_export_bloc.dart' as _i203;
import 'features/accounts/presentation/bloc/account_invoices_bloc.dart'
    as _i116;
import 'features/accounts/presentation/bloc/account_multiselect_bloc.dart'
    as _i966;
import 'features/accounts/presentation/bloc/account_payment_methods_bloc.dart'
    as _i462;
import 'features/accounts/presentation/bloc/account_payments_bloc.dart'
    as _i406;
import 'features/accounts/presentation/bloc/account_subscriptions_bloc.dart'
    as _i892;
import 'features/accounts/presentation/bloc/account_tags_bloc.dart' as _i859;
import 'features/accounts/presentation/bloc/account_timeline_bloc.dart'
    as _i1052;
import 'features/accounts/presentation/bloc/accounts_list_bloc.dart' as _i470;
import 'features/accounts/presentation/bloc/accounts_orchestrator_bloc.dart'
    as _i421;
import 'features/auth/data/datasources/auth_remote_data_source.dart' as _i767;
import 'features/auth/data/datasources/user_local_data_source.dart' as _i254;
import 'features/auth/data/repositories/auth_repository_impl.dart' as _i111;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/usecases/change_password_usecase.dart' as _i890;
import 'features/auth/domain/usecases/forgot_password_usecase.dart' as _i993;
import 'features/auth/domain/usecases/login_usecase.dart' as _i206;
import 'features/auth/domain/usecases/logout_usecase.dart' as _i824;
import 'features/auth/domain/usecases/reset_password_usecase.dart' as _i1070;
import 'features/auth/domain/usecases/update_user_usecase.dart' as _i457;
import 'features/auth/presentation/bloc/auth_bloc.dart' as _i363;
import 'features/dashboard/data/datasources/dashboard_local_data_source.dart'
    as _i336;
import 'features/dashboard/data/datasources/dashboard_mock_data_source.dart'
    as _i500;
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i448;
import 'features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i557;
import 'features/dashboard/domain/usecases/get_dashboard_data.dart' as _i983;
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart' as _i521;
import 'features/invoices/data/datasources/local/invoices_local_data_source.dart'
    as _i277;
import 'features/invoices/data/datasources/remote/invoices_remote_data_source.dart'
    as _i656;
import 'features/invoices/data/repositories/invoices_repository_impl.dart'
    as _i941;
import 'features/invoices/domain/repositories/invoices_repository.dart'
    as _i164;
import 'features/invoices/domain/usecases/adjust_invoice_item.dart' as _i1019;
import 'features/invoices/domain/usecases/get_account_invoices.dart' as _i648;
import 'features/invoices/domain/usecases/get_invoice_audit_logs_with_history.dart'
    as _i1072;
import 'features/invoices/domain/usecases/get_invoice_by_id.dart' as _i458;
import 'features/invoices/domain/usecases/get_invoices.dart' as _i857;
import 'features/invoices/domain/usecases/search_invoices.dart' as _i982;
import 'features/invoices/presentation/bloc/invoice_multiselect_bloc.dart'
    as _i181;
import 'features/invoices/presentation/bloc/invoices_bloc.dart' as _i834;
import 'features/payments/data/datasources/local/payments_local_data_source.dart'
    as _i770;
import 'features/payments/data/datasources/remote/payments_remote_data_source.dart'
    as _i20;
import 'features/payments/data/repositories/payments_repository_impl.dart'
    as _i54;
import 'features/payments/domain/repositories/payments_repository.dart'
    as _i891;
import 'features/payments/domain/usecases/get_payment_by_id.dart' as _i391;
import 'features/payments/domain/usecases/get_payments.dart' as _i973;
import 'features/payments/domain/usecases/get_payments_by_account_id.dart'
    as _i564;
import 'features/payments/domain/usecases/search_payments.dart' as _i918;
import 'features/payments/presentation/bloc/payment_multiselect_bloc.dart'
    as _i720;
import 'features/payments/presentation/bloc/payments_bloc.dart' as _i854;
import 'features/plans/data/datasources/local/plans_local_data_source.dart'
    as _i52;
import 'features/plans/data/datasources/remote/plans_remote_data_source.dart'
    as _i393;
import 'features/plans/data/repositories/plans_repository_impl.dart' as _i14;
import 'features/plans/domain/repositories/plans_repository.dart' as _i692;
import 'features/plans/domain/usecases/get_plan_by_id.dart' as _i868;
import 'features/plans/domain/usecases/get_plans.dart' as _i460;
import 'features/plans/presentation/bloc/plans_bloc.dart' as _i451;
import 'features/plans/presentation/bloc/plans_multiselect_bloc.dart' as _i402;
import 'features/products/data/datasources/local/products_local_data_source.dart'
    as _i229;
import 'features/products/data/datasources/remote/products_remote_data_source.dart'
    as _i579;
import 'features/products/data/repositories/products_repository_impl.dart'
    as _i531;
import 'features/products/domain/repositories/products_repository.dart'
    as _i508;
import 'features/products/domain/usecases/create_product_usecase.dart' as _i872;
import 'features/products/domain/usecases/delete_product_usecase.dart' as _i70;
import 'features/products/domain/usecases/get_product_by_id_usecase.dart'
    as _i272;
import 'features/products/domain/usecases/get_products_usecase.dart' as _i320;
import 'features/products/domain/usecases/search_products_usecase.dart'
    as _i132;
import 'features/products/domain/usecases/update_product_usecase.dart' as _i819;
import 'features/products/presentation/bloc/product_multiselect_bloc.dart'
    as _i756;
import 'features/products/presentation/bloc/products_list_bloc.dart' as _i516;
import 'features/subscriptions/data/datasources/subscriptions_local_data_source.dart'
    as _i167;
import 'features/subscriptions/data/datasources/subscriptions_remote_data_source.dart'
    as _i976;
import 'features/subscriptions/data/repositories/subscriptions_repository_impl.dart'
    as _i234;
import 'features/subscriptions/domain/repositories/subscriptions_repository.dart'
    as _i154;
import 'features/subscriptions/domain/usecases/add_subscription_custom_fields_usecase.dart'
    as _i1055;
import 'features/subscriptions/domain/usecases/block_subscription_usecase.dart'
    as _i497;
import 'features/subscriptions/domain/usecases/cancel_subscription_usecase.dart'
    as _i1005;
import 'features/subscriptions/domain/usecases/create_subscription_usecase.dart'
    as _i862;
import 'features/subscriptions/domain/usecases/create_subscription_with_addons_usecase.dart'
    as _i814;
import 'features/subscriptions/domain/usecases/get_recent_subscriptions_usecase.dart'
    as _i825;
import 'features/subscriptions/domain/usecases/get_subscription_audit_logs_with_history_usecase.dart'
    as _i887;
import 'features/subscriptions/domain/usecases/get_subscription_by_id_usecase.dart'
    as _i815;
import 'features/subscriptions/domain/usecases/get_subscription_custom_fields_usecase.dart'
    as _i939;
import 'features/subscriptions/domain/usecases/get_subscriptions_for_account_usecase.dart'
    as _i233;
import 'features/subscriptions/domain/usecases/remove_subscription_custom_fields_usecase.dart'
    as _i175;
import 'features/subscriptions/domain/usecases/update_subscription_bcd_usecase.dart'
    as _i400;
import 'features/subscriptions/domain/usecases/update_subscription_custom_fields_usecase.dart'
    as _i354;
import 'features/subscriptions/domain/usecases/update_subscription_usecase.dart'
    as _i676;
import 'features/subscriptions/presentation/bloc/subscriptions_bloc.dart'
    as _i675;
import 'features/tag_definitions/data/datasources/tag_definitions_local_data_source.dart'
    as _i400;
import 'features/tag_definitions/data/datasources/tag_definitions_remote_data_source.dart'
    as _i692;
import 'features/tag_definitions/data/repositories/tag_definitions_repository_impl.dart'
    as _i17;
import 'features/tag_definitions/domain/repositories/tag_definitions_repository.dart'
    as _i866;
import 'features/tag_definitions/domain/usecases/create_tag_definition_usecase.dart'
    as _i732;
import 'features/tag_definitions/domain/usecases/delete_tag_definition_usecase.dart'
    as _i528;
import 'features/tag_definitions/domain/usecases/get_tag_definition_audit_logs_with_history_usecase.dart'
    as _i982;
import 'features/tag_definitions/domain/usecases/get_tag_definition_by_id_usecase.dart'
    as _i448;
import 'features/tag_definitions/domain/usecases/get_tag_definitions_usecase.dart'
    as _i235;
import 'features/tag_definitions/presentation/bloc/tag_definitions_bloc.dart'
    as _i65;
import 'features/tags/data/datasources/tags_local_data_source.dart' as _i818;
import 'features/tags/data/datasources/tags_remote_data_source.dart' as _i376;
import 'features/tags/data/repositories/tags_repository_impl.dart' as _i990;
import 'features/tags/domain/repositories/tags_repository.dart' as _i734;
import 'features/tags/domain/usecases/get_all_tags_usecase.dart' as _i348;
import 'features/tags/domain/usecases/search_tags_usecase.dart' as _i335;
import 'features/tags/presentation/bloc/tags_bloc.dart' as _i844;

const String _test = 'test';

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final injectionModule = _$InjectionModule();
  final analyticsModule = _$AnalyticsModule();
  gh.factory<_i402.PlansMultiSelectBloc>(() => _i402.PlansMultiSelectBloc());
  gh.factory<_i203.AccountExportBloc>(() => _i203.AccountExportBloc());
  gh.factory<_i842.JwtService>(() => _i842.JwtService());
  gh.factory<_i580.ExportServiceImpl>(() => _i580.ExportServiceImpl());
  gh.factory<_i916.DatabaseService>(() => _i916.DatabaseService());
  gh.factory<_i683.DatabaseService>(() => _i683.DatabaseService());
  gh.factory<_i720.PaymentMultiSelectBloc>(
    () => _i720.PaymentMultiSelectBloc(),
  );
  gh.factory<_i181.InvoiceMultiSelectBloc>(
    () => _i181.InvoiceMultiSelectBloc(),
  );
  gh.singleton<_i974.Logger>(() => injectionModule.logger);
  gh.singleton<_i558.FlutterSecureStorage>(() => injectionModule.secureStorage);
  gh.singleton<_i361.Dio>(() => injectionModule.dio);
  gh.singleton<_i152.LocalAuthentication>(() => injectionModule.localAuth);
  gh.singleton<_i895.Connectivity>(() => injectionModule.connectivity);
  gh.singleton<_i141.FirebaseCrashlytics>(
    () => injectionModule.firebaseCrashlytics,
  );
  gh.singleton<_i1059.CrashAnalyticsConfig>(
    () => analyticsModule.crashAnalyticsConfig(),
  );
  gh.singleton<_i45.DioClient>(
    () => _i45.DioClient(gh<_i361.Dio>(), gh<_i558.FlutterSecureStorage>()),
  );
  gh.singleton<_i400.TagDefinitionsLocalDataSource>(
    () => injectionModule.tagDefinitionsLocalDataSource(
      gh<_i916.DatabaseService>(),
    ),
  );
  gh.factory<_i626.BiometricAuthService>(
    () => _i626.BiometricAuthService(gh<_i152.LocalAuthentication>()),
  );
  gh.lazySingleton<_i75.NetworkInfo>(() => _i75.NetworkInfoImpl());
  gh.factory<_i692.TagDefinitionsRemoteDataSource>(
    () => _i692.TagDefinitionsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i924.CrashAnalyticsService>(
    () => _i924.CrashAnalyticsServiceImpl(
      gh<_i141.FirebaseCrashlytics>(),
      gh<_i974.Logger>(),
      gh<_i1059.CrashAnalyticsConfig>(),
    ),
  );
  gh.lazySingleton<_i924.CrashAnalyticsService>(
    () => _i579.MockCrashAnalyticsService(),
    registerFor: {_test},
  );
  gh.factory<_i493.SecureStorageService>(
    () => _i493.SecureStorageService(
      gh<_i558.FlutterSecureStorage>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i376.TagsRemoteDataSource>(
    () => _i376.TagsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.singleton<_i924.CrashAnalyticsErrorHandler>(
    () => analyticsModule.crashAnalyticsErrorHandler(
      gh<_i924.CrashAnalyticsService>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.lazySingleton<_i336.DashboardLocalDataSource>(
    () => _i500.DashboardMockDataSource(),
  );
  gh.lazySingleton<_i563.CrashAnalyticsInitializer>(
    () => _i563.CrashAnalyticsInitializer(gh<_i974.Logger>()),
  );
  gh.factory<_i976.SubscriptionsRemoteDataSource>(
    () => _i976.SubscriptionsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i751.AuthenticationStateService>(
    () => _i751.AuthenticationStateService(
      gh<_i493.SecureStorageService>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.lazySingleton<_i656.InvoicesRemoteDataSource>(
    () => _i656.InvoicesRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.factory<_i421.AccountBundlesRemoteDataSource>(
    () => _i421.AccountBundlesRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.lazySingleton<_i277.InvoicesLocalDataSource>(
    () => _i277.InvoicesLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i975.AccountPaymentMethodsRemoteDataSource>(
    () => _i975.AccountPaymentMethodsRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.factory<_i140.UserSessionService>(
    () => _i140.UserSessionService(gh<_i493.SecureStorageService>()),
  );
  gh.factory<_i1058.ChildAccountRemoteDataSource>(
    () => _i1058.ChildAccountRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.lazySingleton<_i557.DashboardRepository>(
    () => _i448.DashboardRepositoryImpl(
      localDataSource: gh<_i336.DashboardLocalDataSource>(),
    ),
  );
  gh.factory<_i1063.AccountBlockingStatesRemoteDataSource>(
    () =>
        _i1063.AccountBlockingStatesRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.lazySingleton<_i393.PlansRemoteDataSource>(
    () => _i393.PlansRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.factory<_i1020.AccountExportRemoteDataSource>(
    () => _i1020.AccountExportRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.factory<_i886.AccountCbaRebalancingRemoteDataSource>(
    () => _i886.AccountCbaRebalancingRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.singleton<_i443.SyncService>(
    () => injectionModule.syncService(gh<_i75.NetworkInfo>()),
  );
  gh.factory<_i225.AccountInvoicesRemoteDataSource>(
    () => _i225.AccountInvoicesRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.factory<_i579.ProductsRemoteDataSource>(
    () => _i579.ProductsRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.lazySingleton<_i770.PaymentsLocalDataSource>(
    () => _i770.PaymentsLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i1042.AccountTagsRemoteDataSource>(
    () => _i1042.AccountTagsRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.factory<_i913.AccountPaymentsRemoteDataSource>(
    () => _i913.AccountPaymentsRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.lazySingleton<_i20.PaymentsRemoteDataSource>(
    () => _i20.PaymentsRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.factory<_i505.AccountOverdueStateRemoteDataSource>(
    () => _i505.AccountOverdueStateRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.factory<_i676.AccountEmailsRemoteDataSource>(
    () => _i676.AccountEmailsRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.factory<_i172.AccountAuditLogsRemoteDataSource>(
    () => _i172.AccountAuditLogsRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.factory<_i767.AuthRemoteDataSource>(
    () => _i767.AuthRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.factory<_i3.AccountsRemoteDataSource>(
    () => _i3.AccountsRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.factory<_i961.AccountInvoicePaymentsRemoteDataSource>(
    () =>
        _i961.AccountInvoicePaymentsRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.lazySingleton<_i52.PlansLocalDataSource>(
    () => _i52.PlansLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i241.AccountCustomFieldsRemoteDataSource>(
    () => _i241.AccountCustomFieldsRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.factory<_i5.AccountTimelineRemoteDataSource>(
    () => _i5.AccountTimelineRemoteDataSourceImpl(gh<_i45.DioClient>()),
  );
  gh.factory<_i377.AccountInvoicesLocalDataSource>(
    () => _i377.AccountInvoicesLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i140.UserSessionService>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i818.TagsLocalDataSource>(
    () => _i818.TagsLocalDataSourceImpl(gh<_i916.DatabaseService>()),
  );
  gh.lazySingleton<_i167.SubscriptionsLocalDataSource>(
    () => _i167.SubscriptionsLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i275.AccountPaymentMethodsLocalDataSource>(
    () => _i275.AccountPaymentMethodsLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i140.UserSessionService>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i250.AccountInvoicePaymentsLocalDataSource>(
    () => _i250.AccountInvoicePaymentsLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i140.UserSessionService>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i1023.AccountPaymentsLocalDataSource>(
    () => _i1023.AccountPaymentsLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i140.UserSessionService>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i929.AccountEmailsLocalDataSource>(
    () => _i929.AccountEmailsLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i140.UserSessionService>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i455.AccountOverdueStateRepository>(
    () => _i681.AccountOverdueStateRepositoryImpl(
      gh<_i505.AccountOverdueStateRemoteDataSource>(),
    ),
  );
  gh.factory<_i512.GetOverdueStateUseCase>(
    () =>
        _i512.GetOverdueStateUseCase(gh<_i455.AccountOverdueStateRepository>()),
  );
  gh.factory<_i866.TagDefinitionsRepository>(
    () => _i17.TagDefinitionsRepositoryImpl(
      gh<_i692.TagDefinitionsRemoteDataSource>(),
      gh<_i400.TagDefinitionsLocalDataSource>(),
      gh<_i75.NetworkInfo>(),
    ),
  );
  gh.factory<_i895.ChildAccountLocalDataSource>(
    () => _i895.ChildAccountLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i140.UserSessionService>(),
    ),
  );
  gh.factory<_i930.AccountExportRepository>(
    () => _i973.AccountExportRepositoryImpl(
      gh<_i1020.AccountExportRemoteDataSource>(),
    ),
  );
  gh.factory<_i474.AccountTimelineLocalDataSource>(
    () => _i474.AccountTimelineLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i140.UserSessionService>(),
    ),
  );
  gh.factory<_i632.AccountCustomFieldsLocalDataSource>(
    () => _i632.AccountCustomFieldsLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i140.UserSessionService>(),
    ),
  );
  gh.factory<_i596.ChildAccountRepository>(
    () => _i311.ChildAccountRepositoryImpl(
      remoteDataSource: gh<_i1058.ChildAccountRemoteDataSource>(),
      localDataSource: gh<_i895.ChildAccountLocalDataSource>(),
      networkInfo: gh<_i75.NetworkInfo>(),
    ),
  );
  gh.factory<_i339.AccountsLocalDataSource>(
    () => _i339.AccountsLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i140.UserSessionService>(),
    ),
  );
  gh.factory<_i88.GetChildAccountsUseCase>(
    () => _i88.GetChildAccountsUseCase(gh<_i596.ChildAccountRepository>()),
  );
  gh.factory<_i743.CreateChildAccountUseCase>(
    () => _i743.CreateChildAccountUseCase(gh<_i596.ChildAccountRepository>()),
  );
  gh.factory<_i201.AccountTagsLocalDataSource>(
    () => _i201.AccountTagsLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i140.UserSessionService>(),
    ),
  );
  gh.factory<_i983.GetDashboardData>(
    () => _i983.GetDashboardData(gh<_i557.DashboardRepository>()),
  );
  gh.factory<_i521.AccountInvoicesRepository>(
    () => _i309.AccountInvoicesRepositoryImpl(
      gh<_i225.AccountInvoicesRemoteDataSource>(),
      gh<_i377.AccountInvoicesLocalDataSource>(),
      gh<_i75.NetworkInfo>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i1054.AccountPaymentsRepository>(
    () => _i626.AccountPaymentsRepositoryImpl(
      gh<_i913.AccountPaymentsRemoteDataSource>(),
      gh<_i1023.AccountPaymentsLocalDataSource>(),
      gh<_i75.NetworkInfo>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i363.AccountTagsRepository>(
    () => _i813.AccountTagsRepositoryImpl(
      gh<_i1042.AccountTagsRemoteDataSource>(),
      gh<_i201.AccountTagsLocalDataSource>(),
      gh<_i75.NetworkInfo>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i887.GetPaginatedInvoicesUseCase>(
    () => _i887.GetPaginatedInvoicesUseCase(
      gh<_i521.AccountInvoicesRepository>(),
    ),
  );
  gh.factory<_i747.GetInvoicesUseCase>(
    () => _i747.GetInvoicesUseCase(gh<_i521.AccountInvoicesRepository>()),
  );
  gh.factory<_i273.AccountAuditLogsLocalDataSource>(
    () => _i273.AccountAuditLogsLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i140.UserSessionService>(),
    ),
  );
  gh.factory<_i734.TagsRepository>(
    () => _i990.TagsRepositoryImpl(
      gh<_i376.TagsRemoteDataSource>(),
      gh<_i818.TagsLocalDataSource>(),
      gh<_i75.NetworkInfo>(),
    ),
  );
  gh.factory<_i229.ProductsLocalDataSource>(
    () => _i229.ProductsLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i140.UserSessionService>(),
    ),
  );
  gh.lazySingleton<_i42.AccountsRepository>(
    () => _i395.AccountsRepositoryImpl(
      remoteDataSource: gh<_i3.AccountsRemoteDataSource>(),
      localDataSource: gh<_i339.AccountsLocalDataSource>(),
      networkInfo: gh<_i75.NetworkInfo>(),
      syncService: gh<_i443.SyncService>(),
    ),
  );
  gh.factory<_i378.AccountInvoicePaymentsRepository>(
    () => _i636.AccountInvoicePaymentsRepositoryImpl(
      gh<_i961.AccountInvoicePaymentsRemoteDataSource>(),
      gh<_i250.AccountInvoicePaymentsLocalDataSource>(),
      gh<_i75.NetworkInfo>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.lazySingleton<_i164.InvoicesRepository>(
    () => _i941.InvoicesRepositoryImpl(
      remoteDataSource: gh<_i656.InvoicesRemoteDataSource>(),
      localDataSource: gh<_i277.InvoicesLocalDataSource>(),
      networkInfo: gh<_i75.NetworkInfo>(),
      logger: gh<_i974.Logger>(),
    ),
  );
  gh.lazySingleton<_i692.PlansRepository>(
    () => _i14.PlansRepositoryImpl(
      remoteDataSource: gh<_i393.PlansRemoteDataSource>(),
      localDataSource: gh<_i52.PlansLocalDataSource>(),
      networkInfo: gh<_i75.NetworkInfo>(),
    ),
  );
  gh.factory<_i804.AccountBlockingStatesLocalDataSource>(
    () => _i804.AccountBlockingStatesLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i140.UserSessionService>(),
    ),
  );
  gh.factory<_i845.AccountPaymentMethodsRepository>(
    () => _i421.AccountPaymentMethodsRepositoryImpl(
      gh<_i975.AccountPaymentMethodsRemoteDataSource>(),
      gh<_i275.AccountPaymentMethodsLocalDataSource>(),
      gh<_i75.NetworkInfo>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i254.UserLocalDataSource>(
    () => _i254.UserLocalDataSourceImpl(
      gh<_i916.DatabaseService>(),
      gh<_i140.UserSessionService>(),
    ),
  );
  gh.factory<_i460.GetPlans>(() => _i460.GetPlans(gh<_i692.PlansRepository>()));
  gh.factory<_i868.GetPlanById>(
    () => _i868.GetPlanById(gh<_i692.PlansRepository>()),
  );
  gh.factory<_i905.RefreshPaymentMethodsUseCase>(
    () => _i905.RefreshPaymentMethodsUseCase(
      gh<_i845.AccountPaymentMethodsRepository>(),
    ),
  );
  gh.factory<_i600.GetAccountPaymentMethodsUseCase>(
    () => _i600.GetAccountPaymentMethodsUseCase(
      gh<_i845.AccountPaymentMethodsRepository>(),
    ),
  );
  gh.factory<_i706.SetDefaultPaymentMethodUseCase>(
    () => _i706.SetDefaultPaymentMethodUseCase(
      gh<_i845.AccountPaymentMethodsRepository>(),
    ),
  );
  gh.factory<_i521.DashboardBloc>(
    () => _i521.DashboardBloc(getDashboardData: gh<_i983.GetDashboardData>()),
  );
  gh.factory<_i1067.AccountCbaRebalancingRepository>(
    () => _i761.AccountCbaRebalancingRepositoryImpl(
      gh<_i886.AccountCbaRebalancingRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i446.AccountTimelineRepository>(
    () => _i735.AccountTimelineRepositoryImpl(
      remoteDataSource: gh<_i5.AccountTimelineRemoteDataSource>(),
      localDataSource: gh<_i474.AccountTimelineLocalDataSource>(),
      networkInfo: gh<_i75.NetworkInfo>(),
    ),
  );
  gh.factory<_i982.GetTagDefinitionAuditLogsWithHistoryUseCase>(
    () => _i982.GetTagDefinitionAuditLogsWithHistoryUseCase(
      gh<_i866.TagDefinitionsRepository>(),
    ),
  );
  gh.factory<_i448.GetTagDefinitionByIdUseCase>(
    () =>
        _i448.GetTagDefinitionByIdUseCase(gh<_i866.TagDefinitionsRepository>()),
  );
  gh.factory<_i528.DeleteTagDefinitionUseCase>(
    () =>
        _i528.DeleteTagDefinitionUseCase(gh<_i866.TagDefinitionsRepository>()),
  );
  gh.factory<_i235.GetTagDefinitionsUseCase>(
    () => _i235.GetTagDefinitionsUseCase(gh<_i866.TagDefinitionsRepository>()),
  );
  gh.factory<_i732.CreateTagDefinitionUseCase>(
    () =>
        _i732.CreateTagDefinitionUseCase(gh<_i866.TagDefinitionsRepository>()),
  );
  gh.factory<_i330.AccountEmailsRepository>(
    () => _i31.AccountEmailsRepositoryImpl(
      gh<_i676.AccountEmailsRemoteDataSource>(),
      gh<_i929.AccountEmailsLocalDataSource>(),
      gh<_i75.NetworkInfo>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i335.SearchTagsUseCase>(
    () => _i335.SearchTagsUseCase(gh<_i734.TagsRepository>()),
  );
  gh.factory<_i348.GetAllTagsUseCase>(
    () => _i348.GetAllTagsUseCase(gh<_i734.TagsRepository>()),
  );
  gh.factory<_i915.UserPersistenceService>(
    () => _i915.UserPersistenceService(gh<_i254.UserLocalDataSource>()),
  );
  gh.factory<_i154.SubscriptionsRepository>(
    () => _i234.SubscriptionsRepositoryImpl(
      gh<_i976.SubscriptionsRemoteDataSource>(),
      gh<_i167.SubscriptionsLocalDataSource>(),
      gh<_i75.NetworkInfo>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i451.PlansBloc>(
    () => _i451.PlansBloc(
      getPlans: gh<_i460.GetPlans>(),
      getPlanById: gh<_i868.GetPlanById>(),
    ),
  );
  gh.factory<_i116.AccountInvoicesBloc>(
    () => _i116.AccountInvoicesBloc(
      getInvoicesUseCase: gh<_i747.GetInvoicesUseCase>(),
    ),
  );
  gh.lazySingleton<_i891.PaymentsRepository>(
    () => _i54.PaymentsRepositoryImpl(
      remoteDataSource: gh<_i20.PaymentsRemoteDataSource>(),
      localDataSource: gh<_i770.PaymentsLocalDataSource>(),
      networkInfo: gh<_i75.NetworkInfo>(),
      logger: gh<_i974.Logger>(),
    ),
  );
  gh.lazySingleton<_i696.AccountBlockingStatesRepository>(
    () => _i552.AccountBlockingStatesRepositoryImpl(
      localDataSource: gh<_i804.AccountBlockingStatesLocalDataSource>(),
      remoteDataSource: gh<_i1063.AccountBlockingStatesRemoteDataSource>(),
      networkInfo: gh<_i75.NetworkInfo>(),
    ),
  );
  gh.factory<_i711.GetAccountTimelineUseCase>(
    () =>
        _i711.GetAccountTimelineUseCase(gh<_i446.AccountTimelineRepository>()),
  );
  gh.factory<_i377.AssignMultipleTagsToAccountUseCase>(
    () => _i377.AssignMultipleTagsToAccountUseCase(
      gh<_i363.AccountTagsRepository>(),
    ),
  );
  gh.factory<_i911.RefreshAccountTagsUseCase>(
    () => _i911.RefreshAccountTagsUseCase(gh<_i363.AccountTagsRepository>()),
  );
  gh.factory<_i582.RemoveMultipleTagsFromAccountUseCase>(
    () => _i582.RemoveMultipleTagsFromAccountUseCase(
      gh<_i363.AccountTagsRepository>(),
    ),
  );
  gh.factory<_i227.GetAccountTagsUseCase>(
    () => _i227.GetAccountTagsUseCase(gh<_i363.AccountTagsRepository>()),
  );
  gh.factory<_i0.CreateTagUseCase>(
    () => _i0.CreateTagUseCase(gh<_i363.AccountTagsRepository>()),
  );
  gh.factory<_i677.UpdateTagUseCase>(
    () => _i677.UpdateTagUseCase(gh<_i363.AccountTagsRepository>()),
  );
  gh.factory<_i279.RemoveTagFromAccountUseCase>(
    () => _i279.RemoveTagFromAccountUseCase(gh<_i363.AccountTagsRepository>()),
  );
  gh.factory<_i277.DeleteTagUseCase>(
    () => _i277.DeleteTagUseCase(gh<_i363.AccountTagsRepository>()),
  );
  gh.factory<_i384.GetAllTagsForAccountUseCase>(
    () => _i384.GetAllTagsForAccountUseCase(gh<_i363.AccountTagsRepository>()),
  );
  gh.factory<_i221.AssignTagToAccountUseCase>(
    () => _i221.AssignTagToAccountUseCase(gh<_i363.AccountTagsRepository>()),
  );
  gh.factory<_i553.ExportAccountDataUseCase>(
    () => _i553.ExportAccountDataUseCase(gh<_i930.AccountExportRepository>()),
  );
  gh.factory<_i325.CacheService>(
    () => _i325.CacheService(
      gh<_i915.UserPersistenceService>(),
      gh<_i493.SecureStorageService>(),
    ),
  );
  gh.factory<_i982.SearchInvoices>(
    () => _i982.SearchInvoices(gh<_i164.InvoicesRepository>()),
  );
  gh.factory<_i400.GetAccountByIdUseCase>(
    () => _i400.GetAccountByIdUseCase(gh<_i42.AccountsRepository>()),
  );
  gh.factory<_i651.UpdateAccountUseCase>(
    () => _i651.UpdateAccountUseCase(gh<_i42.AccountsRepository>()),
  );
  gh.factory<_i684.GetAccountsUseCase>(
    () => _i684.GetAccountsUseCase(gh<_i42.AccountsRepository>()),
  );
  gh.factory<_i823.DeleteAccountUseCase>(
    () => _i823.DeleteAccountUseCase(gh<_i42.AccountsRepository>()),
  );
  gh.factory<_i266.SearchAccountsUseCase>(
    () => _i266.SearchAccountsUseCase(gh<_i42.AccountsRepository>()),
  );
  gh.factory<_i968.CreateAccountUseCase>(
    () => _i968.CreateAccountUseCase(gh<_i42.AccountsRepository>()),
  );
  gh.factory<_i350.CreateInvoicePaymentUseCase>(
    () => _i350.CreateInvoicePaymentUseCase(
      gh<_i378.AccountInvoicePaymentsRepository>(),
    ),
  );
  gh.factory<_i584.GetAccountInvoicePaymentsUseCase>(
    () => _i584.GetAccountInvoicePaymentsUseCase(
      gh<_i378.AccountInvoicePaymentsRepository>(),
    ),
  );
  gh.lazySingleton<_i221.AccountCustomFieldsRepository>(
    () => _i762.AccountCustomFieldsRepositoryImpl(
      localDataSource: gh<_i632.AccountCustomFieldsLocalDataSource>(),
      remoteDataSource: gh<_i241.AccountCustomFieldsRemoteDataSource>(),
      networkInfo: gh<_i75.NetworkInfo>(),
    ),
  );
  gh.factory<_i1015.AuthRepository>(
    () => _i111.AuthRepositoryImpl(
      gh<_i767.AuthRemoteDataSource>(),
      gh<_i493.SecureStorageService>(),
      gh<_i842.JwtService>(),
      gh<_i254.UserLocalDataSource>(),
      gh<_i140.UserSessionService>(),
    ),
  );
  gh.factory<_i857.GetInvoices>(
    () => _i857.GetInvoices(gh<_i164.InvoicesRepository>()),
  );
  gh.factory<_i65.TagDefinitionsBloc>(
    () => _i65.TagDefinitionsBloc(
      gh<_i235.GetTagDefinitionsUseCase>(),
      gh<_i732.CreateTagDefinitionUseCase>(),
      gh<_i448.GetTagDefinitionByIdUseCase>(),
      gh<_i982.GetTagDefinitionAuditLogsWithHistoryUseCase>(),
      gh<_i528.DeleteTagDefinitionUseCase>(),
      gh<_i400.TagDefinitionsLocalDataSource>(),
    ),
  );
  gh.lazySingleton<_i271.AccountAuditLogsRepository>(
    () => _i510.AccountAuditLogsRepositoryImpl(
      remoteDataSource: gh<_i172.AccountAuditLogsRemoteDataSource>(),
      localDataSource: gh<_i273.AccountAuditLogsLocalDataSource>(),
      networkInfo: gh<_i75.NetworkInfo>(),
    ),
  );
  gh.factory<_i334.GetAccountEmailsUseCase>(
    () => _i334.GetAccountEmailsUseCase(gh<_i330.AccountEmailsRepository>()),
  );
  gh.factory<_i470.AccountsListBloc>(
    () => _i470.AccountsListBloc(
      getAccountsUseCase: gh<_i684.GetAccountsUseCase>(),
      searchAccountsUseCase: gh<_i266.SearchAccountsUseCase>(),
      accountsRepository: gh<_i42.AccountsRepository>(),
    ),
  );
  gh.factory<_i859.AccountTagsBloc>(
    () => _i859.AccountTagsBloc(
      gh<_i227.GetAccountTagsUseCase>(),
      gh<_i384.GetAllTagsForAccountUseCase>(),
      gh<_i0.CreateTagUseCase>(),
      gh<_i677.UpdateTagUseCase>(),
      gh<_i277.DeleteTagUseCase>(),
      gh<_i221.AssignTagToAccountUseCase>(),
      gh<_i377.AssignMultipleTagsToAccountUseCase>(),
      gh<_i279.RemoveTagFromAccountUseCase>(),
      gh<_i582.RemoveMultipleTagsFromAccountUseCase>(),
      gh<_i911.RefreshAccountTagsUseCase>(),
      gh<_i363.AccountTagsRepository>(),
    ),
  );
  gh.lazySingleton<_i508.ProductsRepository>(
    () => _i531.ProductsRepositoryImpl(
      remoteDataSource: gh<_i579.ProductsRemoteDataSource>(),
      localDataSource: gh<_i229.ProductsLocalDataSource>(),
      networkInfo: gh<_i75.NetworkInfo>(),
      syncService: gh<_i443.SyncService>(),
    ),
  );
  gh.factory<_i280.AuthGuardService>(
    () => _i280.AuthGuardService(
      gh<_i493.SecureStorageService>(),
      gh<_i626.BiometricAuthService>(),
      gh<_i751.AuthenticationStateService>(),
      gh<_i140.UserSessionService>(),
      gh<_i1015.AuthRepository>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i391.GetPaymentById>(
    () => _i391.GetPaymentById(gh<_i891.PaymentsRepository>()),
  );
  gh.factory<_i564.GetPaymentsByAccountId>(
    () => _i564.GetPaymentsByAccountId(gh<_i891.PaymentsRepository>()),
  );
  gh.factory<_i973.GetPayments>(
    () => _i973.GetPayments(gh<_i891.PaymentsRepository>()),
  );
  gh.factory<_i84.RebalanceCbaUseCase>(
    () =>
        _i84.RebalanceCbaUseCase(gh<_i1067.AccountCbaRebalancingRepository>()),
  );
  gh.factory<_i824.LogoutUseCase>(
    () => _i824.LogoutUseCase(
      gh<_i751.AuthenticationStateService>(),
      gh<_i443.SyncService>(),
      gh<_i254.UserLocalDataSource>(),
    ),
  );
  gh.factory<_i1047.CreateGlobalPaymentUseCase>(
    () => _i1047.CreateGlobalPaymentUseCase(
      gh<_i1054.AccountPaymentsRepository>(),
    ),
  );
  gh.factory<_i463.CreateAccountPaymentUseCase>(
    () => _i463.CreateAccountPaymentUseCase(
      gh<_i1054.AccountPaymentsRepository>(),
    ),
  );
  gh.factory<_i374.GetAccountPaymentsUseCase>(
    () =>
        _i374.GetAccountPaymentsUseCase(gh<_i1054.AccountPaymentsRepository>()),
  );
  gh.factory<_i781.RefundAccountPaymentUseCase>(
    () => _i781.RefundAccountPaymentUseCase(
      gh<_i1054.AccountPaymentsRepository>(),
    ),
  );
  gh.factory<_i834.InvoicesBloc>(
    () => _i834.InvoicesBloc(
      getInvoices: gh<_i857.GetInvoices>(),
      searchInvoices: gh<_i982.SearchInvoices>(),
      logger: gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i648.GetAccountInvoices>(
    () => _i648.GetAccountInvoices(
      gh<_i164.InvoicesRepository>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i458.GetInvoiceById>(
    () => _i458.GetInvoiceById(
      gh<_i164.InvoicesRepository>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i1072.GetInvoiceAuditLogsWithHistory>(
    () => _i1072.GetInvoiceAuditLogsWithHistory(
      gh<_i164.InvoicesRepository>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i1019.AdjustInvoiceItem>(
    () => _i1019.AdjustInvoiceItem(
      gh<_i164.InvoicesRepository>(),
      gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i939.GetSubscriptionCustomFieldsUseCase>(
    () => _i939.GetSubscriptionCustomFieldsUseCase(
      gh<_i154.SubscriptionsRepository>(),
    ),
  );
  gh.factory<_i676.UpdateSubscriptionUseCase>(
    () => _i676.UpdateSubscriptionUseCase(gh<_i154.SubscriptionsRepository>()),
  );
  gh.factory<_i862.CreateSubscriptionUseCase>(
    () => _i862.CreateSubscriptionUseCase(gh<_i154.SubscriptionsRepository>()),
  );
  gh.factory<_i175.RemoveSubscriptionCustomFieldsUseCase>(
    () => _i175.RemoveSubscriptionCustomFieldsUseCase(
      gh<_i154.SubscriptionsRepository>(),
    ),
  );
  gh.factory<_i233.GetSubscriptionsForAccountUseCase>(
    () => _i233.GetSubscriptionsForAccountUseCase(
      gh<_i154.SubscriptionsRepository>(),
    ),
  );
  gh.factory<_i400.UpdateSubscriptionBcdUseCase>(
    () =>
        _i400.UpdateSubscriptionBcdUseCase(gh<_i154.SubscriptionsRepository>()),
  );
  gh.factory<_i814.CreateSubscriptionWithAddOnsUseCase>(
    () => _i814.CreateSubscriptionWithAddOnsUseCase(
      gh<_i154.SubscriptionsRepository>(),
    ),
  );
  gh.factory<_i815.GetSubscriptionByIdUseCase>(
    () => _i815.GetSubscriptionByIdUseCase(gh<_i154.SubscriptionsRepository>()),
  );
  gh.factory<_i1055.AddSubscriptionCustomFieldsUseCase>(
    () => _i1055.AddSubscriptionCustomFieldsUseCase(
      gh<_i154.SubscriptionsRepository>(),
    ),
  );
  gh.factory<_i887.GetSubscriptionAuditLogsWithHistoryUseCase>(
    () => _i887.GetSubscriptionAuditLogsWithHistoryUseCase(
      gh<_i154.SubscriptionsRepository>(),
    ),
  );
  gh.factory<_i354.UpdateSubscriptionCustomFieldsUseCase>(
    () => _i354.UpdateSubscriptionCustomFieldsUseCase(
      gh<_i154.SubscriptionsRepository>(),
    ),
  );
  gh.factory<_i825.GetRecentSubscriptionsUseCase>(
    () => _i825.GetRecentSubscriptionsUseCase(
      gh<_i154.SubscriptionsRepository>(),
    ),
  );
  gh.factory<_i497.BlockSubscriptionUseCase>(
    () => _i497.BlockSubscriptionUseCase(gh<_i154.SubscriptionsRepository>()),
  );
  gh.factory<_i1005.CancelSubscriptionUseCase>(
    () => _i1005.CancelSubscriptionUseCase(gh<_i154.SubscriptionsRepository>()),
  );
  gh.factory<_i918.SearchPayments>(
    () => _i918.SearchPayments(gh<_i891.PaymentsRepository>()),
  );
  gh.factory<_i82.DeleteMultipleAccountCustomFieldsUseCase>(
    () => _i82.DeleteMultipleAccountCustomFieldsUseCase(
      gh<_i221.AccountCustomFieldsRepository>(),
    ),
  );
  gh.factory<_i336.DeleteAccountCustomFieldUseCase>(
    () => _i336.DeleteAccountCustomFieldUseCase(
      gh<_i221.AccountCustomFieldsRepository>(),
    ),
  );
  gh.factory<_i435.UpdateMultipleAccountCustomFieldsUseCase>(
    () => _i435.UpdateMultipleAccountCustomFieldsUseCase(
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
  gh.factory<_i844.TagsBloc>(
    () => _i844.TagsBloc(
      gh<_i348.GetAllTagsUseCase>(),
      gh<_i335.SearchTagsUseCase>(),
      gh<_i580.ExportService>(),
      gh<_i818.TagsLocalDataSource>(),
    ),
  );
  gh.factory<_i729.GetAccountBlockingStatesUseCase>(
    () => _i729.GetAccountBlockingStatesUseCase(
      gh<_i696.AccountBlockingStatesRepository>(),
    ),
  );
  gh.factory<_i657.GetAccountAuditLogsUseCase>(
    () => _i657.GetAccountAuditLogsUseCase(
      gh<_i271.AccountAuditLogsRepository>(),
    ),
  );
  gh.factory<_i1008.AccountCustomFieldsBloc>(
    () => _i1008.AccountCustomFieldsBloc(
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
      accountCustomFieldsRepository: gh<_i221.AccountCustomFieldsRepository>(),
    ),
  );
  gh.factory<_i462.AccountPaymentMethodsBloc>(
    () => _i462.AccountPaymentMethodsBloc(
      getAccountPaymentMethodsUseCase:
          gh<_i600.GetAccountPaymentMethodsUseCase>(),
      setDefaultPaymentMethodUseCase:
          gh<_i706.SetDefaultPaymentMethodUseCase>(),
      refreshPaymentMethodsUseCase: gh<_i905.RefreshPaymentMethodsUseCase>(),
    ),
  );
  gh.factory<_i993.ForgotPasswordUseCase>(
    () => _i993.ForgotPasswordUseCase(gh<_i1015.AuthRepository>()),
  );
  gh.factory<_i206.LoginUseCase>(
    () => _i206.LoginUseCase(gh<_i1015.AuthRepository>()),
  );
  gh.factory<_i966.AccountMultiSelectBloc>(
    () => _i966.AccountMultiSelectBloc(
      deleteAccountUseCase: gh<_i823.DeleteAccountUseCase>(),
    ),
  );
  gh.factory<_i70.DeleteProductUseCase>(
    () => _i70.DeleteProductUseCase(gh<_i508.ProductsRepository>()),
  );
  gh.factory<_i132.SearchProductsUseCase>(
    () => _i132.SearchProductsUseCase(gh<_i508.ProductsRepository>()),
  );
  gh.factory<_i320.GetProductsUseCase>(
    () => _i320.GetProductsUseCase(gh<_i508.ProductsRepository>()),
  );
  gh.factory<_i272.GetProductByIdUseCase>(
    () => _i272.GetProductByIdUseCase(gh<_i508.ProductsRepository>()),
  );
  gh.factory<_i819.UpdateProductUseCase>(
    () => _i819.UpdateProductUseCase(gh<_i508.ProductsRepository>()),
  );
  gh.factory<_i872.CreateProductUseCase>(
    () => _i872.CreateProductUseCase(gh<_i508.ProductsRepository>()),
  );
  gh.factory<_i890.ChangePasswordUseCase>(
    () => _i890.ChangePasswordUseCase(gh<_i1015.AuthRepository>()),
  );
  gh.factory<_i1070.ResetPasswordUseCase>(
    () => _i1070.ResetPasswordUseCase(gh<_i1015.AuthRepository>()),
  );
  gh.factory<_i457.UpdateUserUseCase>(
    () => _i457.UpdateUserUseCase(gh<_i1015.AuthRepository>()),
  );
  gh.factory<_i1052.AccountTimelineBloc>(
    () => _i1052.AccountTimelineBloc(
      gh<_i711.GetAccountTimelineUseCase>(),
      gh<_i446.AccountTimelineRepository>(),
    ),
  );
  gh.factory<_i675.SubscriptionsBloc>(
    () => _i675.SubscriptionsBloc(
      gh<_i825.GetRecentSubscriptionsUseCase>(),
      gh<_i815.GetSubscriptionByIdUseCase>(),
      gh<_i233.GetSubscriptionsForAccountUseCase>(),
      gh<_i862.CreateSubscriptionUseCase>(),
      gh<_i676.UpdateSubscriptionUseCase>(),
      gh<_i1005.CancelSubscriptionUseCase>(),
      gh<_i1055.AddSubscriptionCustomFieldsUseCase>(),
      gh<_i939.GetSubscriptionCustomFieldsUseCase>(),
      gh<_i354.UpdateSubscriptionCustomFieldsUseCase>(),
      gh<_i175.RemoveSubscriptionCustomFieldsUseCase>(),
      gh<_i497.BlockSubscriptionUseCase>(),
      gh<_i814.CreateSubscriptionWithAddOnsUseCase>(),
      gh<_i887.GetSubscriptionAuditLogsWithHistoryUseCase>(),
      gh<_i400.UpdateSubscriptionBcdUseCase>(),
    ),
  );
  gh.factory<_i892.AccountSubscriptionsBloc>(
    () => _i892.AccountSubscriptionsBloc(
      getSubscriptionsForAccountUseCase:
          gh<_i233.GetSubscriptionsForAccountUseCase>(),
    ),
  );
  gh.factory<_i219.AccountDetailBloc>(
    () => _i219.AccountDetailBloc(
      getAccountByIdUseCase: gh<_i400.GetAccountByIdUseCase>(),
      createAccountUseCase: gh<_i968.CreateAccountUseCase>(),
      updateAccountUseCase: gh<_i651.UpdateAccountUseCase>(),
      deleteAccountUseCase: gh<_i823.DeleteAccountUseCase>(),
      getAccountTimelineUseCase: gh<_i711.GetAccountTimelineUseCase>(),
      getAccountTagsUseCase: gh<_i227.GetAccountTagsUseCase>(),
      assignMultipleTagsToAccountUseCase:
          gh<_i377.AssignMultipleTagsToAccountUseCase>(),
      removeMultipleTagsFromAccountUseCase:
          gh<_i582.RemoveMultipleTagsFromAccountUseCase>(),
      getAllTagsForAccountUseCase: gh<_i384.GetAllTagsForAccountUseCase>(),
      getAccountCustomFieldsUseCase: gh<_i397.GetAccountCustomFieldsUseCase>(),
      createAccountCustomFieldUseCase:
          gh<_i629.CreateAccountCustomFieldUseCase>(),
      updateAccountCustomFieldUseCase:
          gh<_i734.UpdateAccountCustomFieldUseCase>(),
      deleteAccountCustomFieldUseCase:
          gh<_i336.DeleteAccountCustomFieldUseCase>(),
      getAccountEmailsUseCase: gh<_i334.GetAccountEmailsUseCase>(),
      getAccountBlockingStatesUseCase:
          gh<_i729.GetAccountBlockingStatesUseCase>(),
      getAccountInvoicePaymentsUseCase:
          gh<_i584.GetAccountInvoicePaymentsUseCase>(),
      getAccountAuditLogsUseCase: gh<_i657.GetAccountAuditLogsUseCase>(),
      getAccountPaymentMethodsUseCase:
          gh<_i600.GetAccountPaymentMethodsUseCase>(),
      getAccountPaymentsUseCase: gh<_i374.GetAccountPaymentsUseCase>(),
      createAccountPaymentUseCase: gh<_i463.CreateAccountPaymentUseCase>(),
      accountsRepository: gh<_i42.AccountsRepository>(),
    ),
  );
  gh.factory<_i406.AccountPaymentsBloc>(
    () => _i406.AccountPaymentsBloc(
      getAccountPaymentsUseCase: gh<_i374.GetAccountPaymentsUseCase>(),
      refundAccountPaymentUseCase: gh<_i781.RefundAccountPaymentUseCase>(),
    ),
  );
  gh.factory<_i363.AuthBloc>(
    () => _i363.AuthBloc(
      loginUseCase: gh<_i206.LoginUseCase>(),
      logoutUseCase: gh<_i824.LogoutUseCase>(),
      forgotPasswordUseCase: gh<_i993.ForgotPasswordUseCase>(),
      changePasswordUseCase: gh<_i890.ChangePasswordUseCase>(),
      resetPasswordUseCase: gh<_i1070.ResetPasswordUseCase>(),
      updateUserUseCase: gh<_i457.UpdateUserUseCase>(),
    ),
  );
  gh.factory<_i854.PaymentsBloc>(
    () => _i854.PaymentsBloc(
      getPayments: gh<_i973.GetPayments>(),
      getPaymentById: gh<_i391.GetPaymentById>(),
      getPaymentsByAccountId: gh<_i564.GetPaymentsByAccountId>(),
      searchPayments: gh<_i918.SearchPayments>(),
      logger: gh<_i974.Logger>(),
    ),
  );
  gh.factory<_i756.ProductMultiSelectBloc>(
    () => _i756.ProductMultiSelectBloc(
      deleteProductUseCase: gh<_i70.DeleteProductUseCase>(),
    ),
  );
  gh.factory<_i516.ProductsListBloc>(
    () => _i516.ProductsListBloc(
      getProductsUseCase: gh<_i320.GetProductsUseCase>(),
      searchProductsUseCase: gh<_i132.SearchProductsUseCase>(),
      productsRepository: gh<_i508.ProductsRepository>(),
    ),
  );
  gh.factory<_i421.AccountsOrchestratorBloc>(
    () => _i421.AccountsOrchestratorBloc(
      accountsListBloc: gh<_i470.AccountsListBloc>(),
      accountDetailBloc: gh<_i219.AccountDetailBloc>(),
      accountMultiSelectBloc: gh<_i966.AccountMultiSelectBloc>(),
      accountExportBloc: gh<_i203.AccountExportBloc>(),
    ),
  );
  return getIt;
}

class _$InjectionModule extends _i670.InjectionModule {}

class _$AnalyticsModule extends _i950.AnalyticsModule {}
