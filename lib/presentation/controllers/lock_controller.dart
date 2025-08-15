import 'package:get/get.dart';
import '../../core/services/auth_lock_service.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/models/settings.dart';

class LockController extends GetxController {
  final SettingsRepository _settingsRepository = SettingsRepository();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isAuthenticated = false.obs;
  final RxBool isLockEnabled = false.obs;
  final Rx<AppLockType> currentLockType = AppLockType.none.obs;

  // PIN authentication
  final RxString enteredPin = ''.obs;
  final RxBool isPinValid = true.obs;
  final RxInt pinAttempts = 0.obs;
  final RxBool isPinBlocked = false.obs;

  // Biometric authentication
  final RxBool isBiometricAvailable = false.obs;
  final RxBool isBiometricEnabled = false.obs;

  static const int maxPinAttempts = 5;
  static const int pinBlockDuration = 300; // 5 minutes in seconds

  @override
  void onInit() {
    super.onInit();
    checkLockStatus();
  }

  Future<void> checkLockStatus() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Check if lock is enabled
      isLockEnabled.value = await AuthLockService.isLockEnabled();
      
      if (!isLockEnabled.value) {
        // No lock enabled, proceed to app
        isAuthenticated.value = true;
        return;
      }

      // Get current lock type
      currentLockType.value = await AuthLockService.getCurrentLockType();
      
      // Check biometric availability
      isBiometricAvailable.value = await AuthLockService.hasAnyBiometric();
      isBiometricEnabled.value = await AuthLockService.isBiometricEnabled();

      // Try biometric authentication if available and enabled
      if (isBiometricAvailable.value && isBiometricEnabled.value) {
        await authenticateWithBiometric();
      }
    } catch (e) {
      error.value = 'Ошибка проверки блокировки: $e';
      print('Error checking lock status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> authenticateWithBiometric() async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await AuthLockService.authenticateWithBiometric();
      
      if (success) {
        isAuthenticated.value = true;
        Get.snackbar(
          'Успешно',
          'Биометрическая аутентификация пройдена',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        error.value = 'Биометрическая аутентификация не удалась';
      }
    } catch (e) {
      error.value = 'Ошибка биометрической аутентификации: $e';
      print('Error with biometric authentication: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> authenticateWithPin(String pin) async {
    try {
      // Check if PIN is blocked
      if (isPinBlocked.value) {
        error.value = 'PIN заблокирован. Попробуйте позже.';
        return;
      }

      isLoading.value = true;
      error.value = '';

      final success = await AuthLockService.authenticateWithPin(pin);
      
      if (success) {
        isAuthenticated.value = true;
        pinAttempts.value = 0;
        isPinValid.value = true;
        
        Get.snackbar(
          'Успешно',
          'PIN введен правильно',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        pinAttempts.value++;
        isPinValid.value = false;
        enteredPin.value = '';
        
        if (pinAttempts.value >= maxPinAttempts) {
          isPinBlocked.value = true;
          error.value = 'PIN заблокирован на 5 минут';
          
          // Unblock after 5 minutes
          Future.delayed(Duration(seconds: pinBlockDuration), () {
            isPinBlocked.value = false;
            pinAttempts.value = 0;
            error.value = '';
          });
        } else {
          final remainingAttempts = maxPinAttempts - pinAttempts.value;
          error.value = 'Неверный PIN. Осталось попыток: $remainingAttempts';
        }
      }
    } catch (e) {
      error.value = 'Ошибка аутентификации: $e';
      print('Error with PIN authentication: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // PIN input methods
  void addPinDigit(String digit) {
    if (isPinBlocked.value) return;
    
    if (enteredPin.value.length < 6) {
      enteredPin.value += digit;
      isPinValid.value = true;
      error.value = '';
    }
  }

  void removePinDigit() {
    if (enteredPin.value.isNotEmpty) {
      enteredPin.value = enteredPin.value.substring(0, enteredPin.value.length - 1);
      isPinValid.value = true;
      error.value = '';
    }
  }

  void clearPin() {
    enteredPin.value = '';
    isPinValid.value = true;
    error.value = '';
  }

  void submitPin() {
    if (enteredPin.value.length >= 4) {
      authenticateWithPin(enteredPin.value);
    } else {
      error.value = 'PIN должен содержать минимум 4 цифры';
    }
  }

  // Switch to PIN authentication
  void switchToPin() {
    currentLockType.value = AppLockType.pin;
    clearPin();
  }

  // Switch to biometric authentication
  void switchToBiometric() {
    if (isBiometricAvailable.value && isBiometricEnabled.value) {
      currentLockType.value = AppLockType.biometric;
      authenticateWithBiometric();
    }
  }

  // Skip authentication (for development/testing)
  void skipAuthentication() {
    isAuthenticated.value = true;
  }

  // Get remaining attempts
  int getRemainingAttempts() {
    return maxPinAttempts - pinAttempts.value;
  }

  // Check if PIN is complete
  bool get isPinComplete {
    return enteredPin.value.length >= 4;
  }

  // Get PIN display (masked)
  String get pinDisplay {
    return '*' * enteredPin.value.length;
  }

  // Get lock type display name
  String getLockTypeDisplayName() {
    switch (currentLockType.value) {
      case AppLockType.pin:
        return 'PIN-код';
      case AppLockType.biometric:
        return 'Биометрия';
      case AppLockType.none:
      default:
        return 'Без блокировки';
    }
  }

  // Get biometric type name
  String getBiometricTypeName() {
    if (isBiometricAvailable.value) {
      return 'Отпечаток пальца'; // Default, can be enhanced
    }
    return 'Биометрия';
  }

  // Check if authentication is required
  bool get isAuthenticationRequired {
    return isLockEnabled.value && currentLockType.value != AppLockType.none;
  }

  // Reset authentication state
  void resetAuthentication() {
    isAuthenticated.value = false;
    clearPin();
    pinAttempts.value = 0;
    isPinBlocked.value = false;
    error.value = '';
  }

  // Refresh lock status
  Future<void> refresh() async {
    await checkLockStatus();
  }
}
