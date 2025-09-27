import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart';
import 'core/services/export_service.dart';
import 'core/services/cache_service.dart';
import 'core/injection/analytics_module.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
void configureDependencies() {
  $initGetIt(getIt);

  // Manually register ExportService as it's not being recognized by injectable generator
  getIt.registerLazySingleton<ExportService>(() => ExportServiceImpl());
}
