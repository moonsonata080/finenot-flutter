import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/credits_controller.dart';
import '../controllers/org_picker_controller.dart';
import '../widgets/credit_card.dart';
import 'add_edit_credit_page.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CreditsController controller = Get.find<CreditsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Кредиты'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, controller),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки кредитов',
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
                  onPressed: () => controller.loadCredits(),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (controller.credits.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadCredits(),
          child: Column(
            children: [
              // Summary cards
              _buildSummaryCards(context, controller),
              
              // Credits list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.credits.length,
                  itemBuilder: (context, index) {
                    final credit = controller.credits[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CreditCard(
                        credit: credit,
                        onTap: () => _showCreditDetails(context, credit, controller),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddEditCreditPage()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Нет кредитов',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте свой первый кредит для начала',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddEditCreditPage()),
            icon: const Icon(Icons.add),
            label: const Text('Добавить кредит'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, CreditsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context,
              'Всего',
              controller.credits.length.toString(),
              Icons.credit_card,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Активных',
              controller.getCreditsByStatus('active').length.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Просроченных',
              controller.getCreditsByStatus('overdue').length.toString(),
              Icons.warning,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, CreditsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Фильтры'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Type filter
            ListTile(
              title: const Text('Тип кредита'),
              subtitle: Text(controller.getTypeFilterDisplayName()),
              onTap: () => _showTypeFilterDialog(context, controller),
            ),
            
            // Status filter
            ListTile(
              title: const Text('Статус'),
              subtitle: Text(controller.getStatusFilterDisplayName()),
              onTap: () => _showStatusFilterDialog(context, controller),
            ),
            
            // Organization filter
            ListTile(
              title: const Text('Организация'),
              subtitle: Text(controller.getOrgFilterDisplayName()),
              onTap: () => _showOrgFilterDialog(context, controller),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearFilters();
              Navigator.of(context).pop();
            },
            child: const Text('Сбросить'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showTypeFilterDialog(BuildContext context, CreditsController controller) {
    final types = ['all', 'consumer', 'mortgage', 'micro', 'card'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тип кредита'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: types.map((type) => RadioListTile<String>(
            title: Text(controller.getCreditTypeDisplayName(type)),
            value: type,
            groupValue: controller.selectedType.value,
            onChanged: (value) {
              controller.setTypeFilter(value!);
              Navigator.of(context).pop();
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showStatusFilterDialog(BuildContext context, CreditsController controller) {
    final statuses = ['all', 'active', 'closed', 'overdue'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Статус'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) => RadioListTile<String>(
            title: Text(controller.getCreditStatusDisplayName(status)),
            value: status,
            groupValue: controller.selectedStatus.value,
            onChanged: (value) {
              controller.setStatusFilter(value!);
              Navigator.of(context).pop();
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showOrgFilterDialog(BuildContext context, CreditsController controller) {
    final OrgPickerController orgController = Get.find<OrgPickerController>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Организация'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Obx(() {
            if (orgController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return ListView(
              children: [
                RadioListTile<String>(
                  title: const Text('Все организации'),
                  value: 'all',
                  groupValue: controller.selectedOrg.value,
                  onChanged: (value) {
                    controller.setOrgFilter(value!);
                    Navigator.of(context).pop();
                  },
                ),
                ...orgController.organizations.map((org) => RadioListTile<String>(
                  title: Text(org.displayName),
                  subtitle: Text(org.type == 'bank' ? 'Банк' : 'МФО'),
                  value: org.key!,
                  groupValue: controller.selectedOrg.value,
                  onChanged: (value) {
                    controller.setOrgFilter(value!);
                    Navigator.of(context).pop();
                  },
                )),
              ],
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, CreditsController controller) {
    final searchController = TextEditingController(text: controller.searchQuery.value);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поиск кредитов'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Введите название кредита...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => controller.setSearchQuery(value),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.setSearchQuery('');
              Navigator.of(context).pop();
            },
            child: const Text('Очистить'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showCreditDetails(BuildContext context, credit, CreditsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Credit info
            Text(
              credit.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${credit.currentBalance.toStringAsFixed(0)} ₽',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Edit credit
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Редактировать'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: View payments
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Платежи'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Delete button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showDeleteConfirmation(context, credit, controller),
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Удалить', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, credit, CreditsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить кредит'),
        content: Text('Вы уверены, что хотите удалить кредит "${credit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close bottom sheet
              
              final success = await controller.deleteCredit(credit.key!);
              if (success) {
                Get.snackbar(
                  'Успешно',
                  'Кредит удален',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                Get.snackbar(
                  'Ошибка',
                  'Не удалось удалить кредит',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
