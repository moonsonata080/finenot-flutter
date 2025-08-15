import 'package:get/get.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/models/settings.dart';

class SettingsController extends GetxController {
  final SettingsRepository _settingsRepo = SettingsRepository();

  // Observable variables
  final Rx<Settings?> settings = Rx<Settings?>(null);
  
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isResetting = false.obs;

  // Settings observables
  final RxString themeMode = 'system'.obs;
  final RxInt notifyAheadHours = 24.obs;
  final RxBool lockEnabled = false.obs;
  final RxString lockType = 'none'.obs;
  final RxDouble? monthlyIncome = RxDouble(0.0);

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  // Load settings
  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final currentSettings = await _settingsRepo.getSettings();
      settings.value = currentSettings;
      
      // Update observables
      _updateObservables(currentSettings);
      
    } catch (e) {
      errorMessage.value = 'Ошибка загрузки настроек: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Update observables from settings
  void _updateObservables(Settings currentSettings) {
    themeMode.value = currentSettings.themeMode;
    notifyAheadHours.value = currentSettings.notifyAheadHours;
    lockEnabled.value = currentSettings.lockEnabled;
    lockType.value = currentSettings.lockType;
    monthlyIncome?.value = currentSettings.monthlyIncome ?? 0.0;
  }

  // Update theme mode
  Future<bool> updateThemeMode(String newThemeMode) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      if (settings.value == null) {
        errorMessage.value = 'Настройки не загружены';
        return false;
      }

      final updatedSettings = settings.value!.copyWith(themeMode: newThemeMode);
      await _settingsRepo.updateSettings(updatedSettings);
      
      settings.value = updatedSettings;
      themeMode.value = newThemeMode;
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка обновления темы: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Update notification settings
  Future<bool> updateNotificationSettings(int hours) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      if (settings.value == null) {
        errorMessage.value = 'Настройки не загружены';
        return false;
      }

      final updatedSettings = settings.value!.copyWith(notifyAheadHours: hours);
      await _settingsRepo.updateSettings(updatedSettings);
      
      settings.value = updatedSettings;
      notifyAheadHours.value = hours;
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка обновления уведомлений: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Update lock settings
  Future<bool> updateLockSettings(bool enabled, String type) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      if (settings.value == null) {
        errorMessage.value = 'Настройки не загружены';
        return false;
      }

      final updatedSettings = settings.value!.copyWith(
        lockEnabled: enabled,
        lockType: type,
      );
      await _settingsRepo.updateSettings(updatedSettings);
      
      settings.value = updatedSettings;
      lockEnabled.value = enabled;
      lockType.value = type;
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка обновления блокировки: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Update monthly income
  Future<bool> updateMonthlyIncome(double? income) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      if (settings.value == null) {
        errorMessage.value = 'Настройки не загружены';
        return false;
      }

      final updatedSettings = settings.value!.copyWith(monthlyIncome: income);
      await _settingsRepo.updateSettings(updatedSettings);
      
      settings.value = updatedSettings;
      monthlyIncome?.value = income ?? 0.0;
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка обновления дохода: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Reset settings to default
  Future<bool> resetToDefault() async {
    try {
      isResetting.value = true;
      errorMessage.value = '';

      await _settingsRepo.resetToDefault();
      await loadSettings();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка сброса настроек: $e';
      return false;
    } finally {
      isResetting.value = false;
    }
  }

  // Export settings
  Future<Map<String, dynamic>?> exportSettings() async {
    try {
      return await _settingsRepo.exportSettings();
    } catch (e) {
      errorMessage.value = 'Ошибка экспорта настроек: $e';
      return null;
    }
  }

  // Import settings
  Future<bool> importSettings(Map<String, dynamic> data) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      await _settingsRepo.importSettings(data);
      await loadSettings();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка импорта настроек: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Get settings summary
  Future<Map<String, dynamic>?> getSettingsSummary() async {
    try {
      return await _settingsRepo.getSettingsSummary();
    } catch (e) {
      errorMessage.value = 'Ошибка получения сводки настроек: $e';
      return null;
    }
  }

  // Validate settings
  Future<bool> validateSettings(Settings settingsToValidate) async {
    try {
      return await _settingsRepo.validateSettings(settingsToValidate);
    } catch (e) {
      errorMessage.value = 'Ошибка валидации настроек: $e';
      return false;
    }
  }

  // Check if settings need migration
  Future<bool> needsMigration() async {
    try {
      return await _settingsRepo.needsMigration();
    } catch (e) {
      errorMessage.value = 'Ошибка проверки миграции: $e';
      return false;
    }
  }

  // Migrate settings
  Future<bool> migrateSettings() async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      await _settingsRepo.migrateSettings();
      await loadSettings();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка миграции настроек: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Refresh settings
  Future<void> refresh() async {
    await loadSettings();
  }

  // Get theme mode display name
  String getThemeModeDisplayName(String mode) {
    switch (mode) {
      case 'system':
        return 'Системная';
      case 'light':
        return 'Светлая';
      case 'dark':
        return 'Тёмная';
      default:
        return mode;
    }
  }

  // Get lock type display name
  String getLockTypeDisplayName(String type) {
    switch (type) {
      case 'none':
        return 'Отключена';
      case 'pin':
        return 'PIN-код';
      case 'biometric':
        return 'Биометрия';
      default:
        return type;
    }
  }

  // Get notification hours display text
  String getNotificationHoursDisplayText(int hours) {
    if (hours == 0) return 'Отключены';
    if (hours == 1) return 'За 1 час';
    if (hours < 24) return 'За $hours часов';
    if (hours == 24) return 'За 1 день';
    final days = hours ~/ 24;
    return 'За $days дней';
  }

  // Check if notifications are enabled
  bool get notificationsEnabled => notifyAheadHours.value > 0;

  // Check if lock is enabled
  bool get isLockEnabled => lockEnabled.value && lockType.value != 'none';

  // Check if PIN lock is enabled
  bool get isPinLockEnabled => lockEnabled.value && lockType.value == 'pin';

  // Check if biometric lock is enabled
  bool get isBiometricLockEnabled => lockEnabled.value && lockType.value == 'biometric';

  // Check if monthly income is set
  bool get hasMonthlyIncome => monthlyIncome?.value != null && monthlyIncome!.value > 0;

  // Get monthly income formatted
  String get monthlyIncomeFormatted {
    if (monthlyIncome?.value == null || monthlyIncome!.value <= 0) {
      return 'Не указан';
    }
    return '${monthlyIncome!.value.toStringAsFixed(0)} ₽';
  }

  // Get settings for display
  Map<String, dynamic> getSettingsForDisplay() {
    if (settings.value == null) return {};

    return {
      'themeMode': themeMode.value,
      'themeModeDisplay': getThemeModeDisplayName(themeMode.value),
      'notifyAheadHours': notifyAheadHours.value,
      'notificationsEnabled': notificationsEnabled,
      'notificationDisplay': getNotificationHoursDisplayText(notifyAheadHours.value),
      'lockEnabled': lockEnabled.value,
      'lockType': lockType.value,
      'lockTypeDisplay': getLockTypeDisplayName(lockType.value),
      'isLockEnabled': isLockEnabled,
      'isPinLockEnabled': isPinLockEnabled,
      'isBiometricLockEnabled': isBiometricLockEnabled,
      'monthlyIncome': monthlyIncome?.value,
      'hasMonthlyIncome': hasMonthlyIncome,
      'monthlyIncomeFormatted': monthlyIncomeFormatted,
    };
  }

  // Get settings validation status
  Map<String, bool> getSettingsValidationStatus() {
    if (settings.value == null) return {};

    return {
      'isValid': true, // Will be updated with actual validation
      'hasThemeMode': themeMode.value.isNotEmpty,
      'hasValidNotificationHours': notifyAheadHours.value >= 0 && notifyAheadHours.value <= 168,
      'hasValidLockType': ['none', 'pin', 'biometric'].contains(lockType.value),
      'hasValidMonthlyIncome': monthlyIncome?.value == null || monthlyIncome!.value >= 0,
    };
  }

  // Check if data is loaded
  bool get isDataLoaded => !isLoading.value && errorMessage.value.isEmpty && settings.value != null;

  // Get error message
  String get error => errorMessage.value;

  // Check if there are any errors
  bool get hasError => errorMessage.value.isNotEmpty;

  // Check if any operation is in progress
  bool get isOperationInProgress => isUpdating.value || isResetting.value;

  // Get current settings
  Settings? get currentSettings => settings.value;
}

