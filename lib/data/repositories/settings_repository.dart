// Simple Settings Repository without Isar for testing
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/settings.dart';

class SettingsRepository {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static Settings? _cachedSettings;

  static const String _pinKey = 'app_pin';
  static const String _biometricKey = 'biometric_enabled';

  // Settings management
  Future<Settings> getSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    // Return default settings for now
    _cachedSettings = Settings(
      id: 1,
      themeMode: AppThemeMode.system,
      lockEnabled: false,
      lockType: AppLockType.none,
      notifyAheadHours: 24,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    return _cachedSettings!;
  }

  Future<void> updateSettings(Settings settings) async {
    settings.updatedAt = DateTime.now();
    _cachedSettings = settings;
  }

  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final settings = await getSettings();
    settings.themeMode = themeMode;
    await updateSettings(settings);
  }

  Future<void> updateLockEnabled(bool enabled) async {
    final settings = await getSettings();
    settings.lockEnabled = enabled;
    if (!enabled) {
      settings.lockType = AppLockType.none;
    }
    await updateSettings(settings);
  }

  Future<void> updateLockType(AppLockType lockType) async {
    final settings = await getSettings();
    settings.lockType = lockType;
    settings.lockEnabled = lockType != AppLockType.none;
    await updateSettings(settings);
  }

  Future<void> updateNotifyAheadHours(int hours) async {
    final settings = await getSettings();
    settings.notifyAheadHours = hours;
    await updateSettings(settings);
  }

  // Secure storage for PIN and biometric settings
  Future<void> setPin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);
  }

  Future<String?> getPin() async {
    return await _secureStorage.read(key: _pinKey);
  }

  Future<void> removePin() async {
    await _secureStorage.delete(key: _pinKey);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(key: _biometricKey, value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _biometricKey);
    return value == 'true';
  }

  // Validation
  Future<bool> validatePin(String pin) async {
    final storedPin = await getPin();
    return storedPin == pin;
  }

  // Reset all settings
  Future<void> resetSettings() async {
    await _secureStorage.deleteAll();
    _cachedSettings = null;
    
    // Create default settings
    final defaultSettings = Settings(
      id: 1,
      themeMode: AppThemeMode.system,
      lockEnabled: false,
      lockType: AppLockType.none,
      notifyAheadHours: 24,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await updateSettings(defaultSettings);
  }

  // JSON serialization for backup/restore
  Map<String, dynamic> toJson() {
    return {
      'settings': _cachedSettings?.toJson(),
      'pin': null, // PIN is stored securely, not in backup
      'biometricEnabled': null, // Biometric setting is stored securely, not in backup
    };
  }

  Future<void> fromJson(Map<String, dynamic> json) async {
    if (json['settings'] != null) {
      final settings = Settings.fromJson(json['settings']);
      await updateSettings(settings);
    }
  }
}
