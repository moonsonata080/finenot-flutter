import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/credits_controller.dart';
import '../widgets/credit_card.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreditsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои кредиты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadCredits(),
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
                  onPressed: () => controller.loadCredits(),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (controller.credits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.credit_card_off,
                  size: 64,
                  color: AppColors.textPrimary.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Нет кредитов',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 8),
                Text(
                  'Добавьте свой первый кредит',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/add-credit'),
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить кредит'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadCredits(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Общая статистика
              _buildSummaryCard(controller),
              const SizedBox(height: 16),
              
              // Список кредитов
              ...controller.credits.map((credit) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CreditCard(credit: credit),
              )),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/add_credit'),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSummaryCard(CreditsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Общая статистика',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Общий долг',
                    '${controller.totalDebt.toStringAsFixed(0)} ₽',
                    Icons.account_balance,
                    AppColors.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Ежемесячный платеж',
                    '${controller.totalMonthlyPayment.toStringAsFixed(0)} ₽',
                    Icons.payment,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Активных кредитов',
                    '${controller.activeCredits.length}',
                    Icons.credit_card,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Просроченных',
                    '${controller.overdueCredits.length}',
                    Icons.warning,
                    AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary.withOpacity(0.7),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
