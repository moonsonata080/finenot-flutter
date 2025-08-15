import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Загрузка настроек...'),
              ],
            ),
          );
        }

        if (controller.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки настроек',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.error,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadSettings(),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadSettings(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme settings
                _buildSettingsSection(
                  context,
                  'Внешний вид',
                  Icons.palette,
                  [
                    _buildThemeModeTile(context, controller),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Notification settings
                _buildSettingsSection(
                  context,
                  'Уведомления',
                  Icons.notifications,
                  [
                    _buildNotificationTile(context, controller),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Security settings
                _buildSettingsSection(
                  context,
                  'Безопасность',
                  Icons.security,
                  [
                    _buildLockTile(context, controller),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Financial settings
                _buildSettingsSection(
                  context,
                  'Финансы',
                  Icons.account_balance_wallet,
                  [
                    _buildIncomeTile(context, controller),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Data management
                _buildSettingsSection(
                  context,
                  'Данные',
                  Icons.storage,
                  [
                    _buildBackupTile(context, controller),
                    _buildResetTile(context, controller),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Section content
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeModeTile(BuildContext context, SettingsController controller) {
    return ListTile(
      title: const Text('Тема приложения'),
      subtitle: Text(controller.getThemeModeDisplayName(controller.themeMode.value)),
      leading: const Icon(Icons.brightness_6),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => _showThemeDialog(context, controller),
    );
  }

  Widget _buildNotificationTile(BuildContext context, SettingsController controller) {
    return ListTile(
      title: const Text('Уведомления о платежах'),
      subtitle: Text(controller.getNotificationHoursDisplayText(controller.notifyAheadHours.value)),
      leading: const Icon(Icons.schedule),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => _showNotificationDialog(context, controller),
    );
  }

  Widget _buildLockTile(BuildContext context, SettingsController controller) {
    return ListTile(
      title: const Text('Блокировка приложения'),
      subtitle: Text(controller.getLockTypeDisplayName(controller.lockType.value)),
      leading: const Icon(Icons.lock),
      trailing: Switch(
        value: controller.lockEnabled.value,
        onChanged: (value) => _showLockDialog(context, controller, value),
      ),
    );
  }

  Widget _buildIncomeTile(BuildContext context, SettingsController controller) {
    return ListTile(
      title: const Text('Ежемесячный доход'),
      subtitle: Text(controller.monthlyIncomeFormatted),
      leading: const Icon(Icons.monetization_on),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => _showIncomeDialog(context, controller),
    );
  }

  Widget _buildBackupTile(BuildContext context, SettingsController controller) {
    return ListTile(
      title: const Text('Резервное копирование'),
      subtitle: const Text('Экспорт и импорт данных'),
      leading: const Icon(Icons.backup),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => _showBackupDialog(context, controller),
    );
  }

  Widget _buildResetTile(BuildContext context, SettingsController controller) {
    return ListTile(
      title: const Text('Сброс настроек'),
      subtitle: const Text('Вернуть настройки по умолчанию'),
      leading: const Icon(Icons.restore),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => _showResetDialog(context, controller),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsController controller) {
    final themes = ['system', 'light', 'dark'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите тему'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes.map((theme) => RadioListTile<String>(
            title: Text(controller.getThemeModeDisplayName(theme)),
            value: theme,
            groupValue: controller.themeMode.value,
            onChanged: (value) async {
              Navigator.of(context).pop();
              final success = await controller.updateThemeMode(value!);
              if (success) {
                Get.snackbar(
                  'Успешно',
                  'Тема изменена',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showNotificationDialog(BuildContext context, SettingsController controller) {
    final hours = [0, 1, 3, 6, 12, 24, 48, 72];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Уведомления о платежах'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: hours.map((hour) => RadioListTile<int>(
            title: Text(controller.getNotificationHoursDisplayText(hour)),
            value: hour,
            groupValue: controller.notifyAheadHours.value,
            onChanged: (value) async {
              Navigator.of(context).pop();
              final success = await controller.updateNotificationSettings(value!);
              if (success) {
                Get.snackbar(
                  'Успешно',
                  'Настройки уведомлений обновлены',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showLockDialog(BuildContext context, SettingsController controller, bool enabled) {
    if (!enabled) {
      controller.updateLockSettings(false, 'none');
      return;
    }

    final lockTypes = ['pin', 'biometric'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тип блокировки'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: lockTypes.map((type) => RadioListTile<String>(
            title: Text(controller.getLockTypeDisplayName(type)),
            value: type,
            groupValue: controller.lockType.value,
            onChanged: (value) async {
              Navigator.of(context).pop();
              final success = await controller.updateLockSettings(true, value!);
              if (success) {
                Get.snackbar(
                  'Успешно',
                  'Блокировка включена',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showIncomeDialog(BuildContext context, SettingsController controller) {
    final incomeController = TextEditingController(
      text: controller.monthlyIncome?.value?.toString() ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ежемесячный доход'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Укажите ваш ежемесячный доход для расчета DSR'),
            const SizedBox(height: 16),
            TextField(
              controller: incomeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Доход',
                suffixText: '₽',
                hintText: '50000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final income = double.tryParse(incomeController.text);
              Navigator.of(context).pop();
              
              final success = await controller.updateMonthlyIncome(income);
              if (success) {
                Get.snackbar(
                  'Успешно',
                  'Доход обновлен',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Резервное копирование'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Экспорт и импорт данных будет добавлен в следующей версии'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сброс настроек'),
        content: const Text('Вы уверены, что хотите сбросить все настройки к значениям по умолчанию?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final success = await controller.resetToDefault();
              if (success) {
                Get.snackbar(
                  'Успешно',
                  'Настройки сброшены',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }
}
