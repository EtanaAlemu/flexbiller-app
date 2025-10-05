import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../constants/app_constants.dart';
import '../services/sync_service.dart';
import '../services/export_service.dart';
import '../services/crash_analytics_service.dart';
import '../services/crash_analytics_initializer.dart';
import '../network/network_info.dart';
import '../services/database_service.dart';
import '../../features/tag_definitions/data/datasources/tag_definitions_local_data_source.dart';
import 'analytics_module.dart';

@module
abstract class InjectionModule {
  @singleton
  Logger get logger => Logger();

  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  @singleton
  Dio get dio => Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  @singleton
  LocalAuthentication get localAuth => LocalAuthentication();

  @singleton
  Connectivity get connectivity => Connectivity();

  @singleton
  SyncService syncService(NetworkInfo networkInfo) => SyncService(networkInfo);

  @singleton
  FirebaseCrashlytics get firebaseCrashlytics => FirebaseCrashlytics.instance;

  @singleton
  TagDefinitionsLocalDataSource tagDefinitionsLocalDataSource(
    DatabaseService databaseService,
  ) =>
      TagDefinitionsLocalDataSourceImpl(databaseService);
}
