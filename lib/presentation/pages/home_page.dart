import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/credits_controller.dart';
import '../controllers/payments_controller.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../data/models/payment.dart';
import '../../data/models/credit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Инициализируем контроллеры
    final dashboardController = Get.put(DashboardController());
    final creditsController = Get.put(CreditsController());
    final paymentsController = Get.put(PaymentsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinEnot', style: TextStyle(color: AppColors.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/settings'),
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: () => _addTestData(),
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: Obx(() {
        if (dashboardController.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await dashboardController.loadDashboardData();
            await creditsController.loadCredits();
            await paymentsController.loadPayments();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Приветствие с енотом
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                
                // Финансовый статус
                _buildFinancialStatusCard(dashboardController),
                const SizedBox(height: 16),
                
                // Основные показатели
                _buildKeyMetricsRow(dashboardController),
                const SizedBox(height: 16),
                
                // Прогресс погашения долга
                _buildDebtProgressCard(dashboardController),
                const SizedBox(height: 16),
                
                // Ближайшие платежи
                _buildUpcomingPaymentsCard(paymentsController),
                const SizedBox(height: 16),
                
                // Активные кредиты
                _buildActiveCreditsCard(creditsController),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
                      children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Привет! 👋',
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Как дела с финансами?',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialStatusCard(DashboardController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: controller.financialStatusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Финансовый статус',
                  style: AppTextStyles.heading2,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.financialStatusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.financialStatusText,
                    style: TextStyle(
                      color: controller.financialStatusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetricsRow(DashboardController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Общий долг',
            controller.formatCurrency(controller.totalDebt.value),
            Icons.account_balance,
            AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Ежемесячные платежи',
            controller.formatCurrency(controller.totalMonthlyPayment.value),
            Icons.account_balance_wallet,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtProgressCard(DashboardController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Прогресс погашения',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: controller.debtProgress.value,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${(controller.debtProgress.value * 100).toStringAsFixed(1)}% погашено',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingPaymentsCard(PaymentsController controller) {
    final upcoming = controller.upcomingPayments.value.take(3).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ближайшие платежи',
                  style: AppTextStyles.heading2,
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/payments'),
                  child: const Text('Все'),
                ),
              ],
            ),
            if (upcoming.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Нет предстоящих платежей'),
              )
            else
              ...upcoming.map((payment) => _buildPaymentItem(payment)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem(Payment payment) {
    final dueDate = payment.dueDate;
    final amount = payment.amount;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${amount.toStringAsFixed(0)} ₽',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${dueDate.day}.${dueDate.month}.${dueDate.year}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCreditsCard(CreditsController controller) {
    final activeCredits = controller.activeCredits.take(2).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Активные кредиты',
                  style: AppTextStyles.heading2,
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/credits'),
                  child: const Text('Все'),
                ),
              ],
            ),
            if (activeCredits.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Нет активных кредитов'),
              )
            else
              ...activeCredits.map((credit) => _buildCreditItem(credit)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed('/add-credit'),
                icon: const Icon(Icons.add),
                label: const Text('Добавить кредит'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditItem(Credit credit) {
    final progress = credit.currentBalance / credit.initialAmount;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  credit.name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${credit.currentBalance.toStringAsFixed(0)} ₽',
                style: AppTextStyles.body,
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textPrimary.withOpacity(0.6),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.credit_card),
          label: 'Кредиты',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          label: 'Платежи',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 1:
            Get.toNamed('/credits');
            break;
          case 2:
            Get.toNamed('/payments');
            break;
        }
      },
    );
  }

  void _addTestData() {
    final creditsController = Get.find<CreditsController>();
    creditsController.addTestData();
  }
}
