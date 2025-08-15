import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/theme.dart';
import '../data/repositories/settings_repository.dart';
import '../data/models/settings.dart';
import '../presentation/controllers/dashboard_controller.dart';
import '../presentation/controllers/credits_controller.dart';
import '../presentation/controllers/payments_controller.dart';
import '../presentation/controllers/settings_controller.dart';
import '../presentation/controllers/lock_controller.dart';
import 'routes.dart';

class FinEnotApp extends StatelessWidget {
  const FinEnotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FinEnot',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      initialBinding: BindingsBuilder(() {
        // Initialize controllers
        Get.lazyPut(() => DashboardController());
        Get.lazyPut(() => CreditsController());
        Get.lazyPut(() => PaymentsController());
        Get.lazyPut(() => SettingsController());
        Get.lazyPut(() => LockController());
      }),
      builder: (context, child) {
        return FutureBuilder<Settings>(
          future: SettingsRepository().getSettings(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final settings = snapshot.data!;
              return GetMaterialApp(
                title: 'FinEnot',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: _getThemeMode(settings.themeMode),
                initialRoute: AppRoutes.splash,
                getPages: AppRoutes.routes,
                initialBinding: BindingsBuilder(() {
                  // Initialize controllers
                  Get.lazyPut(() => DashboardController());
                  Get.lazyPut(() => CreditsController());
                  Get.lazyPut(() => PaymentsController());
                  Get.lazyPut(() => SettingsController());
                  Get.lazyPut(() => LockController());
                }),
              );
            }
            
            // Default app while loading settings
            return GetMaterialApp(
              title: 'FinEnot',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              initialRoute: AppRoutes.splash,
              getPages: AppRoutes.routes,
              initialBinding: BindingsBuilder(() {
                // Initialize controllers
                Get.lazyPut(() => DashboardController());
                Get.lazyPut(() => CreditsController());
                Get.lazyPut(() => PaymentsController());
                Get.lazyPut(() => SettingsController());
                Get.lazyPut(() => LockController());
              }),
            );
          },
        );
      },
    );
  }

  ThemeMode _getThemeMode(ThemeMode settingsThemeMode) {
    switch (settingsThemeMode) {
      case ThemeMode.light:
        return ThemeMode.light;
      case ThemeMode.dark:
        return ThemeMode.dark;
      case ThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }
}
