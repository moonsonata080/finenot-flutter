import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/settings_repository.dart';

class AuthLockService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static final SettingsRepository _settingsRepo = SettingsRepository();

  // Check if device supports biometric authentication
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } on PlatformException catch (e) {
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      return [];
    }
  }

  // Check if lock is enabled
  static Future<bool> isLockEnabled() async {
    final settings = await _settingsRepo.getSettings();
    return settings.lockEnabled;
  }

  // Check if PIN is set
  static Future<bool> isPinSet() async {
    final pin = await _settingsRepo.getPin();
    return pin != null && pin.isNotEmpty;
  }

  // Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    return await _settingsRepo.isBiometricEnabled();
  }

  // Authenticate with PIN
  static Future<bool> authenticateWithPin(String pin) async {
    final storedPin = await _settingsRepo.getPin();
    return storedPin == pin;
  }

  // Authenticate with biometric
  static Future<bool> authenticateWithBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) return false;

      final availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access FinEnot',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return authenticated;
    } on PlatformException catch (e) {
      return false;
    }
  }

  // Set PIN
  static Future<void> setPin(String pin) async {
    await _settingsRepo.setPin(pin);
    await _settingsRepo.updateLockType(LockType.pin);
  }

  // Remove PIN
  static Future<void> removePin() async {
    await _settingsRepo.removePin();
    await _settingsRepo.updateLockType(LockType.none);
  }

  // Enable biometric authentication
  static Future<bool> enableBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric authentication for FinEnot',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        await _settingsRepo.setBiometricEnabled(true);
        await _settingsRepo.updateLockType(LockType.biometric);
        return true;
      }

      return false;
    } on PlatformException catch (e) {
      return false;
    }
  }

  // Disable biometric authentication
  static Future<void> disableBiometric() async {
    await _settingsRepo.setBiometricEnabled(false);
    await _settingsRepo.updateLockType(LockType.none);
  }

  // Authenticate based on current lock type
  static Future<bool> authenticate() async {
    final settings = await _settingsRepo.getSettings();
    
    if (!settings.lockEnabled) return true;

    switch (settings.lockType) {
      case LockType.pin:
        // PIN authentication should be handled by UI
        return false;
      case LockType.biometric:
        return await authenticateWithBiometric();
      case LockType.none:
      default:
        return true;
    }
  }

  // Check if authentication is required
  static Future<bool> isAuthenticationRequired() async {
    final settings = await _settingsRepo.getSettings();
    return settings.lockEnabled && settings.lockType != LockType.none;
  }

  // Get current lock type
  static Future<LockType> getCurrentLockType() async {
    final settings = await _settingsRepo.getSettings();
    return settings.lockType;
  }

  // Validate PIN format (4-6 digits)
  static bool isValidPin(String pin) {
    return pin.length >= 4 && pin.length <= 6 && int.tryParse(pin) != null;
  }

  // Get biometric type name
  static String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      default:
        return 'Biometric';
    }
  }

  // Get available biometric types as strings
  static Future<List<String>> getAvailableBiometricNames() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.map((type) => getBiometricTypeName(type)).toList();
  }

  // Check if device has any biometric authentication
  static Future<bool> hasAnyBiometric() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.isNotEmpty;
  }

  // Reset all authentication settings
  static Future<void> resetAuthentication() async {
    await _settingsRepo.removePin();
    await _settingsRepo.setBiometricEnabled(false);
    await _settingsRepo.updateLockEnabled(false);
  }
}
