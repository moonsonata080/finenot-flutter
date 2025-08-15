import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLockService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  static const String _pinKey = 'app_pin';
  static const String _lockTypeKey = 'lock_type';

  // Check if device supports biometric authentication
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Set PIN code
  static Future<void> setPin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);
    await _secureStorage.write(key: _lockTypeKey, value: 'pin');
  }

  // Set biometric authentication
  static Future<void> setBiometric() async {
    await _secureStorage.delete(key: _pinKey);
    await _secureStorage.write(key: _lockTypeKey, value: 'biometric');
  }

  // Disable lock
  static Future<void> disableLock() async {
    await _secureStorage.delete(key: _pinKey);
    await _secureStorage.delete(key: _lockTypeKey);
  }

  // Get current lock type
  static Future<String> getLockType() async {
    return await _secureStorage.read(key: _lockTypeKey) ?? 'none';
  }

  // Authenticate with PIN
  static Future<bool> authenticateWithPin(String pin) async {
    final storedPin = await _secureStorage.read(key: _pinKey);
    return storedPin == pin;
  }

  // Authenticate with biometric
  static Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Подтвердите личность для входа в приложение',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // Authenticate based on current lock type
  static Future<bool> authenticate() async {
    final lockType = await getLockType();
    
    switch (lockType) {
      case 'pin':
        // This should be handled by the UI that calls authenticateWithPin
        return false;
      case 'biometric':
        return await authenticateWithBiometric();
      case 'none':
      default:
        return true;
    }
  }

  // Check if lock is enabled
  static Future<bool> isLockEnabled() async {
    final lockType = await getLockType();
    return lockType != 'none';
  }
}
