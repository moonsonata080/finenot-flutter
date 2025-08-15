import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../db/isar_provider.dart';
import '../models/settings.dart';

class SettingsRepository {
  final Isar _isar = IsarProvider.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _pinKey = 'app_pin';
  static const String _biometricKey = 'biometric_enabled';

  // Settings management
  Future<Settings> getSettings() async {
    Settings? settings = await _isar.settingss.get(1);
    
    if (settings == null) {
      // Create default settings
      settings = Settings();
      await _isar.writeTxn(() async {
        await _isar.settingss.put(settings!);
      });
    }
    
    return settings;
  }

  Future<void> updateSettings(Settings settings) async {
    settings.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.settingss.put(settings);
    });
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final settings = await getSettings();
    settings.themeMode = themeMode;
    await updateSettings(settings);
  }

  Future<void> updateLockEnabled(bool enabled) async {
    final settings = await getSettings();
    settings.lockEnabled = enabled;
    if (!enabled) {
      settings.lockType = LockType.none;
    }
    await updateSettings(settings);
  }

  Future<void> updateLockType(LockType lockType) async {
    final settings = await getSettings();
    settings.lockType = lockType;
    settings.lockEnabled = lockType != LockType.none;
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
    await _isar.writeTxn(() async {
      await _isar.settingss.clear();
    });
    
    await _secureStorage.deleteAll();
    
    // Create default settings
    final defaultSettings = Settings();
    await _isar.writeTxn(() async {
      await _isar.settingss.put(defaultSettings);
    });
  }

  // Export/Import settings
  Map<String, dynamic> settingsToJson(Settings settings) {
    return {
      'themeMode': settings.themeMode.name,
      'lockEnabled': settings.lockEnabled,
      'lockType': settings.lockType.name,
      'notifyAheadHours': settings.notifyAheadHours,
      'createdAt': settings.createdAt?.toIso8601String(),
      'updatedAt': settings.updatedAt?.toIso8601String(),
    };
  }

  Future<Settings> settingsFromJson(Map<String, dynamic> json) async {
    final settings = Settings();
    
    settings.themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == json['themeMode'],
      orElse: () => ThemeMode.system,
    );
    
    settings.lockEnabled = json['lockEnabled'] ?? false;
    
    settings.lockType = LockType.values.firstWhere(
      (e) => e.name == json['lockType'],
      orElse: () => LockType.none,
    );
    
    settings.notifyAheadHours = json['notifyAheadHours'] ?? 24;
    
    if (json['createdAt'] != null) {
      settings.createdAt = DateTime.parse(json['createdAt']);
    }
    
    if (json['updatedAt'] != null) {
      settings.updatedAt = DateTime.parse(json['updatedAt']);
    }
    
    return settings;
  }
}
