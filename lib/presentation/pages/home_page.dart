import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/kpi_tile.dart';
import '../widgets/credit_card.dart';
import 'credits_page.dart';
import 'payments_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController = Get.find<DashboardController>();
    final SettingsController settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinEnot'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const SettingsPage()),
          ),
        ],
      ),
      body: Obx(() {
        if (dashboardController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (dashboardController.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки данных',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  dashboardController.error,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => dashboardController.loadDashboardData(),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => dashboardController.loadDashboardData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                _buildWelcomeSection(context, settingsController),
                
                const SizedBox(height: 24),
                
                // KPI Cards
                _buildKPISection(context, dashboardController),
                
                const SizedBox(height: 24),
                
                // DSR Section
                _buildDSRSection(context, dashboardController),
                
                const SizedBox(height: 24),
                
                // Recent Credits
                _buildRecentCreditsSection(context, dashboardController),
                
                const SizedBox(height: 24),
                
                // Upcoming Payments
                _buildUpcomingPaymentsSection(context, dashboardController),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Get.to(() => const CreditsPage());
              break;
            case 2:
              Get.to(() => const PaymentsPage());
              break;
            case 3:
              Get.to(() => const SettingsPage());
              break;
          }
        },
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
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, SettingsController settingsController) {
    return Obx(() {
      final settings = settingsController.currentSettings;
      final timeOfDay = DateTime.now().hour;
      
      String greeting;
      if (timeOfDay < 12) {
        greeting = 'Доброе утро';
      } else if (timeOfDay < 18) {
        greeting = 'Добрый день';
      } else {
        greeting = 'Добрый вечер';
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Управляйте своими кредитами эффективно',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildKPISection(BuildContext context, DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Обзор',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // KPI Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            KpiTile(
              title: 'Общий долг',
              value: '${controller.totalDebt.value.toStringAsFixed(0)} ₽',
              icon: Icons.account_balance_wallet,
              color: Colors.red,
              onTap: () => Get.to(() => const CreditsPage()),
            ),
            KpiTile(
              title: 'Ежемесячный платеж',
              value: '${controller.totalMonthlyPayments.value.toStringAsFixed(0)} ₽',
              icon: Icons.payment,
              color: Colors.orange,
              onTap: () => Get.to(() => const PaymentsPage()),
            ),
            KpiTile(
              title: 'Активных кредитов',
              value: controller.activeCreditsCount.value.toString(),
              icon: Icons.credit_card,
              color: Colors.blue,
              onTap: () => Get.to(() => const CreditsPage()),
            ),
            KpiTile(
              title: 'Просроченных',
              value: controller.overdueCreditsCount.value.toString(),
              icon: Icons.warning,
              color: Colors.red,
              onTap: () => Get.to(() => const PaymentsPage()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDSRSection(BuildContext context, DashboardController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'DSR (Debt Service Ratio)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // DSR Progress
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${controller.dsr.value.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getDSRColor(controller.dsr.value),
                      ),
                    ),
                    Text(
                      _getDSRStatus(controller.dsr.value),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getDSRColor(controller.dsr.value),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: controller.dsr.value / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_getDSRColor(controller.dsr.value)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ежемесячные платежи / Доход',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCreditsSection(BuildContext context, DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Недавние кредиты',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => const CreditsPage()),
              child: const Text('Все'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (controller.credits.isEmpty)
          _buildEmptyState(
            context,
            'Нет кредитов',
            'Добавьте свой первый кредит',
            Icons.credit_card,
            () => Get.to(() => const CreditsPage()),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.credits.take(3).length,
            itemBuilder: (context, index) {
              final credit = controller.credits[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CreditCard(credit: credit),
              );
            },
          ),
      ],
    );
  }

  Widget _buildUpcomingPaymentsSection(BuildContext context, DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ближайшие платежи',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => const PaymentsPage()),
              child: const Text('Все'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (controller.upcomingPayments.isEmpty)
          _buildEmptyState(
            context,
            'Нет платежей',
            'Все платежи оплачены',
            Icons.check_circle,
            () => Get.to(() => const PaymentsPage()),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.upcomingPayments.take(3).length,
            itemBuilder: (context, index) {
              final payment = controller.upcomingPayments[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getPaymentStatusColor(payment.status),
                    child: Icon(
                      _getPaymentStatusIcon(payment.status),
                      color: Colors.white,
                    ),
                  ),
                  title: Text('${payment.amount.toStringAsFixed(0)} ₽'),
                  subtitle: Text(
                    '${payment.dueDate.day}.${payment.dueDate.month}.${payment.dueDate.year}',
                  ),
                  trailing: Text(
                    _getPaymentStatusText(payment.status),
                    style: TextStyle(
                      color: _getPaymentStatusColor(payment.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDSRColor(double dsr) {
    if (dsr < 30) return Colors.green;
    if (dsr < 50) return Colors.orange;
    return Colors.red;
  }

  String _getDSRStatus(double dsr) {
    if (dsr < 30) return 'Отлично';
    if (dsr < 50) return 'Внимание';
    return 'Критично';
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

  IconData _getPaymentStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'paid':
        return Icons.check;
      case 'partial':
        return Icons.pending;
      case 'missed':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String _getPaymentStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Ожидает';
      case 'paid':
        return 'Оплачен';
      case 'partial':
        return 'Частично';
      case 'missed':
        return 'Пропущен';
      default:
        return status;
    }
  }
}
