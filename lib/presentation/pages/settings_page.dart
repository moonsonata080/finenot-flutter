import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../data/models/settings.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Настройки',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme settings
              _buildSectionHeader('Внешний вид'),
              _buildThemeSettings(controller),
              const SizedBox(height: 24),

              // Notification settings
              _buildSectionHeader('Уведомления'),
              _buildNotificationSettings(controller),
              const SizedBox(height: 24),

              // Security settings
              _buildSectionHeader('Безопасность'),
              _buildSecuritySettings(controller),
              const SizedBox(height: 24),

              // Backup settings
              _buildSectionHeader('Резервное копирование'),
              _buildBackupSettings(controller),
              const SizedBox(height: 24),

              // Reset settings
              _buildSectionHeader('Сброс'),
              _buildResetSettings(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.heading4.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSettings(SettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Тема приложения',
              style: AppTextStyles.body1,
            ),
            subtitle: Text(
              controller.getThemeModeName(controller.settings.value.themeMode),
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showThemeDialog(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(SettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Уведомления',
              style: AppTextStyles.body1,
            ),
            subtitle: Text(
              controller.areNotificationsEnabled.value 
                  ? 'Включены' 
                  : 'Отключены',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Switch(
              value: controller.areNotificationsEnabled.value,
              onChanged: (value) {
                if (value) {
                  controller.requestNotificationPermissions();
                }
              },
            ),
          ),
          ListTile(
            title: Text(
              'Напоминать за',
              style: AppTextStyles.body1,
            ),
            subtitle: Text(
              '${controller.notifyAheadHours.value} часов',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showNotificationHoursDialog(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(SettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Блокировка приложения',
              style: AppTextStyles.body1,
            ),
            subtitle: Text(
              controller.getLockTypeName(controller.currentLockType.value),
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Switch(
              value: controller.isLockEnabled.value,
              onChanged: controller.toggleLock,
            ),
          ),
          if (controller.isLockEnabled.value) ...[
            if (controller.isPinSet())
              ListTile(
                title: Text(
                  'Изменить PIN-код',
                  style: AppTextStyles.body1,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showPinDialog(controller, isChange: true),
              ),
            if (!controller.isPinSet())
              ListTile(
                title: Text(
                  'Установить PIN-код',
                  style: AppTextStyles.body1,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showPinDialog(controller),
              ),
            if (controller.isBiometricAvailable.value)
              ListTile(
                title: Text(
                  'Биометрическая аутентификация',
                  style: AppTextStyles.body1,
                ),
                subtitle: Text(
                  controller.isBiometricEnabled() 
                      ? 'Включена' 
                      : 'Отключена',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Switch(
                  value: controller.isBiometricEnabled(),
                  onChanged: (value) {
                    if (value) {
                      controller.enableBiometric();
                    } else {
                      controller.disableBiometric();
                    }
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackupSettings(SettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Экспорт данных',
              style: AppTextStyles.body1,
            ),
            subtitle: Text(
              'Сохранить все данные в файл',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            leading: const Icon(Icons.upload, color: AppColors.primary),
            onTap: controller.exportData,
          ),
          ListTile(
            title: Text(
              'Импорт данных',
              style: AppTextStyles.body1,
            ),
            subtitle: Text(
              'Загрузить данные из файла',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            leading: const Icon(Icons.download, color: AppColors.primary),
            onTap: controller.importData,
          ),
        ],
      ),
    );
  }

  Widget _buildResetSettings(SettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error),
      ),
      child: ListTile(
        title: Text(
          'Сбросить все настройки',
          style: AppTextStyles.body1.copyWith(
            color: AppColors.error,
          ),
        ),
        subtitle: Text(
          'Удалить все данные и настройки',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        leading: const Icon(Icons.delete_forever, color: AppColors.error),
        onTap: () => _showResetConfirmationDialog(controller),
      ),
    );
  }

  void _showThemeDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Выберите тему'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return ListTile(
              title: Text(controller.getThemeModeName(mode)),
              trailing: controller.settings.value.themeMode == mode
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                controller.updateThemeMode(mode);
                Get.back();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showNotificationHoursDialog(SettingsController controller) {
    final hoursController = TextEditingController();
    hoursController.text = controller.notifyAheadHours.value.toString();

    Get.dialog(
      AlertDialog(
        title: const Text('Напоминать за'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Часов',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final hours = int.tryParse(hoursController.text);
              if (hours != null && hours > 0) {
                controller.updateNotifyAheadHours(hours);
                Get.back();
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showPinDialog(SettingsController controller, {bool isChange = false}) {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(isChange ? 'Изменить PIN-код' : 'Установить PIN-код'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'PIN-код (4-6 цифр)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Подтвердите PIN-код',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final pin = pinController.text;
              final confirmPin = confirmPinController.text;
              
              if (pin.length >= 4 && pin == confirmPin) {
                controller.setPin(pin);
                Get.back();
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmationDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Сбросить настройки'),
        content: const Text(
          'Вы уверены, что хотите сбросить все настройки? Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.resetSettings();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }
}
