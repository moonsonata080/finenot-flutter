import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/payments_controller.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentsController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Платежи'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Предстоящие'),
              Tab(text: 'Просроченные'),
              Tab(text: 'Все'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.loadPayments(),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки',
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.error.value,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
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

          return TabBarView(
            children: [
              _buildPaymentsList(controller.upcomingPayments, 'Предстоящие платежи'),
              _buildPaymentsList(controller.overduePayments, 'Просроченные платежи'),
              _buildPaymentsList(controller.payments, 'Все платежи'),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPaymentsList(List payments, String title) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment_off,
              size: 64,
              color: AppColors.textPrimary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Нет платежей',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'Платежи появятся здесь',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => Get.find<PaymentsController>().loadPayments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return _buildPaymentCard(payment);
        },
      ),
    );
  }

  Widget _buildPaymentCard(dynamic payment) {
    final dueDate = DateTime.tryParse(payment['payment_date'] ?? '') ?? DateTime.now();
    final amount = (payment['amount'] ?? 0).toDouble();
    final status = payment['status'] ?? 'pending';
    final isOverdue = dueDate.isBefore(DateTime.now()) && status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и статус
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Платеж ${amount.toStringAsFixed(0)} ₽',
                    style: AppTextStyles.heading2,
                  ),
                ),
                _buildStatusChip(status, isOverdue),
              ],
            ),
            const SizedBox(height: 12),
            
            // Дата платежа
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textPrimary.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMMM yyyy, EEEE', 'ru_RU').format(dueDate),
                  style: AppTextStyles.body.copyWith(
                    color: isOverdue ? AppColors.error : AppColors.textPrimary,
                    fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Кредит (если есть информация)
            if (payment['credit_name'] != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.credit_card,
                    size: 16,
                    color: AppColors.textPrimary.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      payment['credit_name'],
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // Кнопки действий
            if (status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _markAsPaid(payment['id'], amount),
                      icon: const Icon(Icons.check),
                      label: const Text('Оплачен'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _markAsMissed(payment['id']),
                      icon: const Icon(Icons.close),
                      label: const Text('Пропущен'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'paid') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Оплачен',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (status == 'missed') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cancel,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Пропущен',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isOverdue) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'paid':
        color = AppColors.success;
        text = 'Оплачен';
        icon = Icons.check_circle;
        break;
      case 'missed':
        color = AppColors.error;
        text = 'Пропущен';
        icon = Icons.cancel;
        break;
      case 'pending':
        if (isOverdue) {
          color = AppColors.error;
          text = 'Просрочен';
          icon = Icons.warning;
        } else {
          color = AppColors.warning;
          text = 'Ожидает';
          icon = Icons.schedule;
        }
        break;
      default:
        color = AppColors.textPrimary.withOpacity(0.5);
        text = 'Неизвестно';
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsPaid(int paymentId, double amount) async {
    final controller = Get.find<PaymentsController>();
    final success = await controller.markPaymentPaid(paymentId, amount);
    
    if (success) {
      Get.snackbar(
        'Успех',
        'Платеж отмечен как оплаченный',
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _markAsMissed(int paymentId) async {
    // TODO: Реализовать отметку как пропущенный
    Get.snackbar(
      'Информация',
      'Функция отметки пропущенных платежей будет добавлена позже',
      backgroundColor: AppColors.warning.withOpacity(0.1),
      colorText: AppColors.warning,
      snackPosition: SnackPosition.TOP,
    );
  }
}
