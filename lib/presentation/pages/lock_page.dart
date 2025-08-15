import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/lock_controller.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../data/models/settings.dart';

class LockPage extends StatelessWidget {
  const LockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LockController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isAuthenticated.value) {
          // Navigate to home when authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed('/home');
          });
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo/icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                
                // App title
                Text(
                  'FinEnot',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Менеджер кредитов',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),

                // Authentication method
                if (controller.currentLockType.value == AppLockType.pin) ...[
                  _buildPinAuthentication(controller),
                ] else if (controller.currentLockType.value == AppLockType.biometric) ...[
                  _buildBiometricAuthentication(controller),
                ] else ...[
                  _buildNoLockMessage(),
                ],

                const SizedBox(height: 32),

                // Error message
                if (controller.error.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.error.value,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 24),

                // Switch authentication method
                if (controller.isBiometricAvailable.value && 
                    controller.isBiometricEnabled.value &&
                    controller.currentLockType.value == AppLockType.pin)
                  TextButton(
                    onPressed: controller.switchToBiometric,
                    child: Text(
                      'Использовать ${controller.getBiometricTypeName()}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                if (controller.currentLockType.value == AppLockType.biometric)
                  TextButton(
                    onPressed: controller.switchToPin,
                    child: Text(
                      'Использовать PIN-код',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                // Skip button (for development)
                if (controller.isLoading.value == false)
                  TextButton(
                    onPressed: controller.skipAuthentication,
                    child: Text(
                      'Пропустить (тест)',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPinAuthentication(LockController controller) {
    return Column(
      children: [
        Text(
          'Введите PIN-код',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 24),

        // PIN display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              final isFilled = index < controller.enteredPin.value.length;
              return Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? AppColors.primary : AppColors.border,
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 32),

        // PIN keypad
        _buildPinKeypad(controller),
      ],
    );
  }

  Widget _buildPinKeypad(LockController controller) {
    return Column(
      children: [
        for (int row = 0; row < 3; row++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int col = 0; col < 3; col++)
                _buildPinButton(
                  controller,
                  (row * 3 + col + 1).toString(),
                ),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPinButton(controller, ''),
            _buildPinButton(controller, '0'),
            _buildPinButton(controller, 'del', isDelete: true),
          ],
        ),
      ],
    );
  }

  Widget _buildPinButton(LockController controller, String digit, {bool isDelete = false}) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.isPinBlocked.value
              ? null
              : () {
                  if (isDelete) {
                    controller.removePinDigit();
                  } else if (digit.isNotEmpty) {
                    controller.addPinDigit(digit);
                  }
                },
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: digit.isEmpty ? Colors.transparent : AppColors.surface,
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: Center(
              child: digit.isEmpty
                  ? null
                  : isDelete
                      ? const Icon(Icons.backspace, color: AppColors.textPrimary)
                      : Text(
                          digit,
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricAuthentication(LockController controller) {
    return Column(
      children: [
        Text(
          'Биометрическая аутентификация',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 24),

        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(60),
            border: Border.all(
              color: AppColors.border,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.fingerprint,
            size: 60,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Приложите палец к сканеру',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: controller.authenticateWithBiometric,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Попробовать снова',
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }

  Widget _buildNoLockMessage() {
    return Column(
      children: [
        Text(
          'Блокировка не настроена',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        Text(
          'Перейдите в настройки для настройки блокировки',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
