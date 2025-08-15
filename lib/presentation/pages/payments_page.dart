import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payments_controller.dart';
import '../widgets/payment_tile.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PaymentsController controller = Get.find<PaymentsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Платежи'),
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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Загрузка платежей...'),
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
                  'Ошибка загрузки платежей',
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
                  onPressed: () => controller.loadPayments(),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (controller.payments.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadPayments(),
          child: Column(
            children: [
              // Summary cards
              _buildSummaryCards(context, controller),
              
              // Payments list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.payments.length,
                  itemBuilder: (context, index) {
                    final payment = controller.payments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PaymentTile(
                        payment: payment,
                        onTap: () => _showPaymentDetails(context, payment, controller),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payment,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Нет платежей',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Платежи появятся после создания кредитов',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, PaymentsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context,
              'Всего',
              controller.totalPayments.value.toString(),
              Icons.payment,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Оплаченных',
              controller.paidPayments.value.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Ожидающих',
              controller.pendingPayments.value.toString(),
              Icons.schedule,
              Colors.orange,
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
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
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

  void _showFilterDialog(BuildContext context, PaymentsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Фильтры'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Статус'),
              subtitle: Text(controller.getPaymentStatusDisplayName(controller.selectedStatus.value)),
              onTap: () => _showStatusFilterDialog(context, controller),
            ),
            ListTile(
              title: const Text('Период'),
              subtitle: Text(_getDateRangeDisplayName(controller.selectedDateRange.value)),
              onTap: () => _showDateRangeFilterDialog(context, controller),
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

  void _showStatusFilterDialog(BuildContext context, PaymentsController controller) {
    final statuses = ['all', 'pending', 'paid', 'partial', 'missed'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Статус платежа'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) => RadioListTile<String>(
            title: Text(controller.getPaymentStatusDisplayName(status)),
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

  void _showDateRangeFilterDialog(BuildContext context, PaymentsController controller) {
    final ranges = [
      {'value': 'all', 'name': 'Все'},
      {'value': 'today', 'name': 'Сегодня'},
      {'value': 'week', 'name': 'Неделя'},
      {'value': 'month', 'name': 'Месяц'},
      {'value': 'overdue', 'name': 'Просроченные'},
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Период'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ranges.map((range) => RadioListTile<String>(
            title: Text(range['name']!),
            value: range['value']!,
            groupValue: controller.selectedDateRange.value,
            onChanged: (value) {
              controller.setDateRangeFilter(value!);
              Navigator.of(context).pop();
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, PaymentsController controller) {
    final searchController = TextEditingController(text: controller.searchQuery.value);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поиск платежей'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Введите сумму или дату...',
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

  void _showPaymentDetails(BuildContext context, payment, PaymentsController controller) {
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
            
            // Payment info
            Text(
              '${payment.amount.toStringAsFixed(0)} ₽',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getPaymentStatusColor(payment.status),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.getPaymentStatusDisplayName(payment.status),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _getPaymentStatusColor(payment.status),
              ),
            ),
            const SizedBox(height: 20),
            
            // Payment details
            _buildDetailRow('Дата платежа', '${payment.dueDate.day}.${payment.dueDate.month}.${payment.dueDate.year}'),
            if (payment.paidDate != null)
              _buildDetailRow('Дата оплаты', '${payment.paidDate!.day}.${payment.paidDate!.month}.${payment.paidDate!.year}'),
            _buildDetailRow('Статус', controller.getPaymentStatusDisplayName(payment.status)),
            const SizedBox(height: 20),
            
            // Actions
            if (payment.status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showMarkAsPaidDialog(context, payment, controller),
                      icon: const Icon(Icons.check),
                      label: const Text('Оплачен'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showMarkAsMissedDialog(context, payment, controller),
                      icon: const Icon(Icons.close),
                      label: const Text('Пропущен'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkAsPaidDialog(BuildContext context, payment, PaymentsController controller) {
    final amountController = TextEditingController(text: payment.amount.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отметить как оплаченный'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Введите сумму оплаты:'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Сумма',
                suffixText: '₽',
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
              final amount = double.tryParse(amountController.text) ?? payment.amount;
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close bottom sheet
              
              final success = await controller.markPaymentAsPaid(payment.key!, amount);
              if (success) {
                Get.snackbar(
                  'Успешно',
                  'Платеж отмечен как оплаченный',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }

  void _showMarkAsMissedDialog(BuildContext context, payment, PaymentsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отметить как пропущенный'),
        content: const Text('Вы уверены, что хотите отметить этот платеж как пропущенный?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close bottom sheet
              
              final success = await controller.markPaymentAsMissed(payment.key!);
              if (success) {
                Get.snackbar(
                  'Успешно',
                  'Платеж отмечен как пропущенный',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }

  String _getDateRangeDisplayName(String range) {
    switch (range) {
      case 'all':
        return 'Все';
      case 'today':
        return 'Сегодня';
      case 'week':
        return 'Неделя';
      case 'month':
        return 'Месяц';
      case 'overdue':
        return 'Просроченные';
      default:
        return range;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.blue;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
