import 'package:get/get.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/models/settings.dart';
import '../../core/services/auth_lock_service.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/notification_service.dart';

class SettingsController extends GetxController {
  final SettingsRepository _settingsRepository = SettingsRepository();

  // Observable variables
  final Rx<Settings> settings = Settings().obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Authentication settings
  final RxBool isLockEnabled = false.obs;
  final Rx<AppLockType> currentLockType = AppLockType.none.obs;
  final RxBool isBiometricAvailable = false.obs;
  final RxList<String> availableBiometrics = <String>[].obs;

  // Notification settings
  final RxBool areNotificationsEnabled = false.obs;
  final RxInt notifyAheadHours = 24.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Load settings
      final currentSettings = await _settingsRepository.getSettings();
      settings.value = currentSettings;

      // Load authentication settings
      await _loadAuthenticationSettings();

      // Load notification settings
      await _loadNotificationSettings();
    } catch (e) {
      error.value = 'Ошибка загрузки настроек: $e';
      print('Error loading settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAuthenticationSettings() async {
    isLockEnabled.value = await AuthLockService.isLockEnabled();
    currentLockType.value = await AuthLockService.getCurrentLockType();
    isBiometricAvailable.value = await AuthLockService.hasAnyBiometric();
    availableBiometrics.value = await AuthLockService.getAvailableBiometricNames();
  }

  Future<void> _loadNotificationSettings() async {
    areNotificationsEnabled.value = await NotificationService.areNotificationsEnabled();
    notifyAheadHours.value = settings.value.notifyAheadHours;
  }

  // Theme settings
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    try {
      await _settingsRepository.updateThemeMode(themeMode);
      settings.value.themeMode = themeMode;
      
      Get.snackbar(
        'Успешно',
        'Тема изменена',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка изменения темы: $e';
      print('Error updating theme: $e');
    }
  }

  // Lock settings
  Future<void> toggleLock(bool enabled) async {
    try {
      await _settingsRepository.updateLockEnabled(enabled);
      isLockEnabled.value = enabled;
      
      if (!enabled) {
        currentLockType.value = AppLockType.none;
      }
      
      Get.snackbar(
        'Успешно',
        enabled ? 'Блокировка включена' : 'Блокировка отключена',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка изменения блокировки: $e';
      print('Error toggling lock: $e');
    }
  }

  Future<void> setPin(String pin) async {
    try {
      if (!AuthLockService.isValidPin(pin)) {
        error.value = 'PIN должен содержать 4-6 цифр';
        return;
      }

      await AuthLockService.setPin(pin);
      currentLockType.value = AppLockType.pin;
      
      Get.snackbar(
        'Успешно',
        'PIN установлен',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка установки PIN: $e';
      print('Error setting PIN: $e');
    }
  }

  Future<void> removePin() async {
    try {
      await AuthLockService.removePin();
      currentLockType.value = AppLockType.none;
      
      Get.snackbar(
        'Успешно',
        'PIN удален',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка удаления PIN: $e';
      print('Error removing PIN: $e');
    }
  }

  Future<void> enableBiometric() async {
    try {
      final success = await AuthLockService.enableBiometric();
      if (success) {
        currentLockType.value = AppLockType.biometric;
        Get.snackbar(
          'Успешно',
          'Биометрия включена',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        error.value = 'Не удалось включить биометрию';
      }
    } catch (e) {
      error.value = 'Ошибка включения биометрии: $e';
      print('Error enabling biometric: $e');
    }
  }

  Future<void> disableBiometric() async {
    try {
      await AuthLockService.disableBiometric();
      currentLockType.value = AppLockType.none;
      
      Get.snackbar(
        'Успешно',
        'Биометрия отключена',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка отключения биометрии: $e';
      print('Error disabling biometric: $e');
    }
  }

  // Notification settings
  Future<void> updateNotifyAheadHours(int hours) async {
    try {
      await _settingsRepository.updateNotifyAheadHours(hours);
      notifyAheadHours.value = hours;
      settings.value.notifyAheadHours = hours;
      
      // Reschedule notifications
      await NotificationService.onNotificationSettingsChanged();
      
      Get.snackbar(
        'Успешно',
        'Настройки уведомлений обновлены',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка обновления уведомлений: $e';
      print('Error updating notifications: $e');
    }
  }

  Future<void> requestNotificationPermissions() async {
    try {
      final granted = await NotificationService.requestPermissions();
      areNotificationsEnabled.value = granted;
      
      if (granted) {
        Get.snackbar(
          'Успешно',
          'Разрешения на уведомления получены',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        error.value = 'Разрешения на уведомления не получены';
      }
    } catch (e) {
      error.value = 'Ошибка запроса разрешений: $e';
      print('Error requesting permissions: $e');
    }
  }

  // Backup settings
  Future<void> exportData() async {
    try {
      isLoading.value = true;
      error.value = '';

      await BackupService.exportToFile();
      
      Get.snackbar(
        'Успешно',
        'Данные экспортированы',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка экспорта: $e';
      print('Error exporting data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> importData() async {
    try {
      isLoading.value = true;
      error.value = '';

      await BackupService.importFromFile();
      
      // Reschedule notifications after import
      await NotificationService.onNotificationSettingsChanged();
      
      Get.snackbar(
        'Успешно',
        'Данные импортированы',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка импорта: $e';
      print('Error importing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Reset settings
  Future<void> resetSettings() async {
    try {
      isLoading.value = true;
      error.value = '';

      await _settingsRepository.resetSettings();
      await AuthLockService.resetAuthentication();
      
      // Reload settings
      await loadSettings();
      
      Get.snackbar(
        'Успешно',
        'Настройки сброшены',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка сброса настроек: $e';
      print('Error resetting settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods
  String getThemeModeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'Системная';
      case AppThemeMode.light:
        return 'Светлая';
      case AppThemeMode.dark:
        return 'Темная';
      default:
        return 'Системная';
    }
  }

  String getLockTypeName(AppLockType type) {
    switch (type) {
      case AppLockType.none:
        return 'Отключена';
      case AppLockType.pin:
        return 'PIN-код';
      case AppLockType.biometric:
        return 'Биометрия';
      default:
        return 'Отключена';
    }
  }

  bool isPinSet() {
    return currentLockType.value == AppLockType.pin;
  }

  bool isBiometricEnabled() {
    return currentLockType.value == AppLockType.biometric;
  }

  // Refresh settings
  Future<void> refresh() async {
    await loadSettings();
  }
}
