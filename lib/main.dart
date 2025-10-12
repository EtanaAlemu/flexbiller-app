import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/pages/authentication_flow_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'core/services/authentication_state_service.dart';
import 'core/services/crash_analytics_initializer.dart';
import 'core/services/crash_analytics_service.dart';
import 'core/services/startup_error_handler.dart';
import 'package:logger/logger.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/localization_service.dart';
import 'core/localization/app_strings.dart';
import 'core/widgets/crash_analytics_error_boundary.dart';
import 'core/utils/build_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _initializeApp();
    runApp(const MyApp());
  } catch (error, stackTrace) {
    // Emergency error handling if app startup fails
    await StartupErrorHandler.handleStartupError(error, stackTrace);
    runApp(StartupErrorHandler.createStartupErrorApp(error));
  }
}

Future<void> _initializeApp() async {
  final logger = Logger();

  // Initialize build info
  await BuildInfo.init();
  logger.i('Build Info initialized: ${BuildInfo.displayVersion}');

  // Initialize crash analytics first
  try {
    final crashAnalyticsInitializer = CrashAnalyticsInitializer(logger);
    await crashAnalyticsInitializer.initialize();
    logger.i('Crash analytics initialized successfully');
  } catch (e) {
    logger.e('Failed to initialize crash analytics: $e');
    // Continue app startup even if crash analytics fails
  }

  // Initialize services
  await LocalizationService.initialize();

  // Configure dependency injection
  di.configureDependencies();

  // Initialize crash analytics service
  try {
    final crashAnalytics = di.getIt<CrashAnalyticsService>();
    await crashAnalytics.initialize();
    logger.i('Crash analytics service initialized');
  } catch (e) {
    logger.e('Failed to initialize crash analytics service: $e');
  }

  // Restore user context for multi-user support (only if user is authenticated)
  try {
    final authRepository = di.getIt<AuthRepository>();
    final authStateService = di.getIt<AuthenticationStateService>();

    // Only restore user context if user is actually authenticated
    final isAuthenticated = await authStateService.isUserAuthenticated();
    if (isAuthenticated) {
      await authRepository.restoreUserContext();
      logger.i('User context restored for authenticated user');
    } else {
      logger.i(
        'No authenticated user found, skipping user context restoration',
      );
    }
  } catch (e) {
    // Log error but don't fail app startup
    logger.e('Error restoring user context: $e');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

// Global key for ScaffoldMessenger to show SnackBars from anywhere
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return BlocProvider(
            create: (context) => di.getIt<AuthBloc>(),
            child: CrashAnalyticsErrorBoundary(
              feature: 'app_root',
              child: MaterialApp(
                title: AppStrings.appTitle,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                scaffoldMessengerKey: scaffoldMessengerKey, // Add global key
                // Localization
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocalesList,
                locale: LocalizationService.currentLocale,
                localeResolutionCallback: (locale, supportedLocales) {
                  return AppLocalizations.getSupportedLocale(locale);
                },

                home: const AuthenticationFlowPage(),
                routes: {'/dashboard': (context) => const DashboardPage()},
                debugShowCheckedModeBanner: false,
              ),
            ),
          );
        },
      ),
    );
  }
}
