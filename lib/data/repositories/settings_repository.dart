import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings.dart';
import '../../core/services/hive_provider.dart';

class SettingsRepository {
  final Box<Settings> _settingsBox = HiveProvider.settingsBox;
  static const String _defaultSettingsKey = 'default_settings';

  // Get settings (singleton pattern)
  Future<Settings> getSettings() async {
    final settings = _settingsBox.get(_defaultSettingsKey);
    if (settings != null) {
      return settings;
    }
    
    // Create default settings if none exist
    final defaultSettings = Settings(
      themeMode: 'system',
      notifyAheadHours: 24,
      lockEnabled: false,
      lockType: 'none',
      monthlyIncome: null,
    );
    
    await _settingsBox.put(_defaultSettingsKey, defaultSettings);
    return defaultSettings;
  }

  // Update settings
  Future<void> updateSettings(Settings settings) async {
    await _settingsBox.put(_defaultSettingsKey, settings);
  }

  // Update theme mode
  Future<void> updateThemeMode(String themeMode) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(themeMode: themeMode);
    await updateSettings(updatedSettings);
  }

  // Update notification settings
  Future<void> updateNotificationSettings(int notifyAheadHours) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(notifyAheadHours: notifyAheadHours);
    await updateSettings(updatedSettings);
  }

  // Update lock settings
  Future<void> updateLockSettings(bool lockEnabled, String lockType) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(
      lockEnabled: lockEnabled,
      lockType: lockType,
    );
    await updateSettings(updatedSettings);
  }

  // Update monthly income
  Future<void> updateMonthlyIncome(double? monthlyIncome) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(monthlyIncome: monthlyIncome);
    await updateSettings(updatedSettings);
  }

  // Get theme mode
  Future<String> getThemeMode() async {
    final settings = await getSettings();
    return settings.themeMode;
  }

  // Get notification hours
  Future<int> getNotifyAheadHours() async {
    final settings = await getSettings();
    return settings.notifyAheadHours;
  }

  // Check if lock is enabled
  Future<bool> isLockEnabled() async {
    final settings = await getSettings();
    return settings.lockEnabled;
  }

  // Get lock type
  Future<String> getLockType() async {
    final settings = await getSettings();
    return settings.lockType;
  }

  // Get monthly income
  Future<double?> getMonthlyIncome() async {
    final settings = await getSettings();
    return settings.monthlyIncome;
  }

  // Reset settings to default
  Future<void> resetToDefault() async {
    final defaultSettings = Settings(
      themeMode: 'system',
      notifyAheadHours: 24,
      lockEnabled: false,
      lockType: 'none',
      monthlyIncome: null,
    );
    
    await updateSettings(defaultSettings);
  }

  // Export settings as Map
  Future<Map<String, dynamic>> exportSettings() async {
    final settings = await getSettings();
    return {
      'themeMode': settings.themeMode,
      'notifyAheadHours': settings.notifyAheadHours,
      'lockEnabled': settings.lockEnabled,
      'lockType': settings.lockType,
      'monthlyIncome': settings.monthlyIncome,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // Import settings from Map
  Future<void> importSettings(Map<String, dynamic> data) async {
    final settings = Settings(
      themeMode: data['themeMode'] ?? 'system',
      notifyAheadHours: data['notifyAheadHours'] ?? 24,
      lockEnabled: data['lockEnabled'] ?? false,
      lockType: data['lockType'] ?? 'none',
      monthlyIncome: data['monthlyIncome'],
    );
    
    await updateSettings(settings);
  }

  // Get settings summary
  Future<Map<String, dynamic>> getSettingsSummary() async {
    final settings = await getSettings();
    return {
      'themeMode': settings.themeMode,
      'notificationsEnabled': settings.notifyAheadHours > 0,
      'notifyAheadHours': settings.notifyAheadHours,
      'lockEnabled': settings.lockEnabled,
      'lockType': settings.lockType,
      'hasMonthlyIncome': settings.monthlyIncome != null,
      'monthlyIncome': settings.monthlyIncome,
    };
  }

  // Validate settings
  Future<bool> validateSettings(Settings settings) async {
    // Validate theme mode
    if (!['system', 'light', 'dark'].contains(settings.themeMode)) {
      return false;
    }
    
    // Validate notification hours
    if (settings.notifyAheadHours < 0 || settings.notifyAheadHours > 168) {
      return false;
    }
    
    // Validate lock type
    if (!['none', 'pin', 'biometric'].contains(settings.lockType)) {
      return false;
    }
    
    // Validate monthly income
    if (settings.monthlyIncome != null && settings.monthlyIncome! < 0) {
      return false;
    }
    
    return true;
  }

  // Check if settings need migration
  Future<bool> needsMigration() async {
    final settings = await getSettings();
    
    // Check if settings are using old format or missing fields
    return settings.themeMode.isEmpty || 
           settings.lockType.isEmpty ||
           settings.notifyAheadHours <= 0;
  }

  // Migrate settings to new format
  Future<void> migrateSettings() async {
    final settings = await getSettings();
    
    // Apply migration rules
    final migratedSettings = Settings(
      themeMode: settings.themeMode.isEmpty ? 'system' : settings.themeMode,
      notifyAheadHours: settings.notifyAheadHours <= 0 ? 24 : settings.notifyAheadHours,
      lockEnabled: settings.lockEnabled,
      lockType: settings.lockType.isEmpty ? 'none' : settings.lockType,
      monthlyIncome: settings.monthlyIncome,
    );
    
    await updateSettings(migratedSettings);
  }
}
