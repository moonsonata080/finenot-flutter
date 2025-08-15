import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/credit_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/org_repository.dart';
import '../../data/models/credit.dart';
import '../../data/models/payment.dart';
import '../../data/models/settings.dart';
import '../../data/models/org.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final CreditRepository _creditRepo = CreditRepository();
  final PaymentRepository _paymentRepo = PaymentRepository();
  final SettingsRepository _settingsRepo = SettingsRepository();
  final OrgRepository _orgRepo = OrgRepository();
  
  List<Map<String, dynamic>> creditsWithIds = [];
  List<Payment> payments = [];
  Settings? settings;
  List<Org> organizations = [];
  
  String statusMessage = 'Готов к тестированию';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      isLoading = true;
      statusMessage = 'Загрузка данных...';
    });

    try {
      // Load all data
      await Future.wait([
        _loadCredits(),
        _loadPayments(),
        _loadSettings(),
        _loadOrganizations(),
      ]);

      setState(() {
        statusMessage = 'Данные загружены успешно!';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Ошибка загрузки: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCredits() async {
    creditsWithIds = await _creditRepo.getAllCreditsWithIds();
  }

  Future<void> _loadPayments() async {
    payments = await _paymentRepo.getAllPayments();
  }

  Future<void> _loadSettings() async {
    settings = await _settingsRepo.getSettings();
  }

  Future<void> _loadOrganizations() async {
    await _orgRepo.initialize();
    organizations = await _orgRepo.getAllOrgs();
  }

  Future<void> _testCreateCredit() async {
    setState(() {
      isLoading = true;
      statusMessage = 'Создание тестового кредита...';
    });

    try {
      final credit = Credit(
        name: 'Тестовый кредит ${DateTime.now().millisecondsSinceEpoch}',
        type: 'consumer',
        orgId: organizations.isNotEmpty ? organizations.first.key : null,
        initialAmount: 100000,
        currentBalance: 100000,
        monthlyPayment: 10000,
        interestRate: 12.5,
        nextPaymentDate: DateTime.now().add(const Duration(days: 30)),
        status: 'active',
        createdAt: DateTime.now(),
      );

      final creditId = await _creditRepo.addCredit(credit);
      
      setState(() {
        statusMessage = 'Кредит создан с ID: $creditId';
      });

      await _loadCredits();
    } catch (e) {
      setState(() {
        statusMessage = 'Ошибка создания кредита: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _testCreatePayment() async {
    if (creditsWithIds.isEmpty) {
      setState(() {
        statusMessage = 'Сначала создайте кредит!';
      });
      return;
    }

    setState(() {
      isLoading = true;
      statusMessage = 'Создание тестового платежа...';
    });

    try {
      final creditId = creditsWithIds.first['id'] as String;
      final payment = Payment(
        creditId: creditId,
        amount: 10000,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final paymentId = await _paymentRepo.addPayment(payment);
      
      setState(() {
        statusMessage = 'Платеж создан с ID: $paymentId';
      });

      await _loadPayments();
    } catch (e) {
      setState(() {
        statusMessage = 'Ошибка создания платежа: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _testUpdateSettings() async {
    setState(() {
      isLoading = true;
      statusMessage = 'Обновление настроек...';
    });

    try {
      final updatedSettings = settings?.copyWith(
        themeMode: 'dark',
        notifyAheadHours: 48,
        lockEnabled: true,
        lockType: 'pin',
        monthlyIncome: 100000,
      );

      if (updatedSettings != null) {
        await _settingsRepo.updateSettings(updatedSettings);
        settings = updatedSettings;
        
        setState(() {
          statusMessage = 'Настройки обновлены!';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Ошибка обновления настроек: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _testMarkPaymentAsPaid() async {
    if (payments.isEmpty) {
      setState(() {
        statusMessage = 'Сначала создайте платеж!';
      });
      return;
    }

    setState(() {
      isLoading = true;
      statusMessage = 'Отметка платежа как оплаченного...';
    });

    try {
      final payment = payments.first;
      await _paymentRepo.markPaymentAsPaid(payment.key!, payment.amount);
      
      setState(() {
        statusMessage = 'Платеж отмечен как оплаченный!';
      });
      
      await _loadPayments();
    } catch (e) {
      setState(() {
        statusMessage = 'Ошибка отметки платежа: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _testDeleteCredit() async {
    if (creditsWithIds.isEmpty) {
      setState(() {
        statusMessage = 'Нет кредитов для удаления!';
      });
      return;
    }

    setState(() {
      isLoading = true;
      statusMessage = 'Удаление кредита...';
    });

    try {
      final creditId = creditsWithIds.first['id'] as String;
      await _creditRepo.deleteCredit(creditId);
      
      setState(() {
        statusMessage = 'Кредит удален!';
      });

      await _loadCredits();
      await _loadPayments(); // Reload payments as they might be deleted too
    } catch (e) {
      setState(() {
        statusMessage = 'Ошибка удаления кредита: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FinEnot - Тестирование'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isLoading ? Icons.hourglass_empty : Icons.info,
                          color: isLoading ? Colors.orange : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Статус: $statusMessage',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow('Кредитов', creditsWithIds.length, Icons.credit_card),
                    _buildStatRow('Платежей', payments.length, Icons.payment),
                    _buildStatRow('Организаций', organizations.length, Icons.account_balance),
                    if (settings != null) 
                      _buildStatRow('Тема', settings!.themeMode, Icons.palette),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test actions card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Тестирование функционала',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTestButton(
                          'Создать кредит',
                          Icons.add,
                          Colors.green,
                          _testCreateCredit,
                        ),
                        _buildTestButton(
                          'Создать платеж',
                          Icons.payment,
                          Colors.blue,
                          _testCreatePayment,
                        ),
                        _buildTestButton(
                          'Обновить настройки',
                          Icons.settings,
                          Colors.orange,
                          _testUpdateSettings,
                        ),
                        _buildTestButton(
                          'Отметить платеж',
                          Icons.check_circle,
                          Colors.green,
                          _testMarkPaymentAsPaid,
                        ),
                        _buildTestButton(
                          'Удалить кредит',
                          Icons.delete,
                          Colors.red,
                          _testDeleteCredit,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Data display sections
            if (creditsWithIds.isNotEmpty) ...[
              _buildDataSection(
                'Кредиты (${creditsWithIds.length})',
                Icons.credit_card,
                creditsWithIds.take(3).map((creditData) {
                  final credit = creditData['credit'] as Credit;
                  final id = creditData['id'] as String;
                  return _buildDataTile(
                    title: credit.name,
                    subtitle: '${credit.currentBalance.toStringAsFixed(0)} ₽',
                    trailing: credit.status,
                    leading: 'ID: $id',
                    color: _getCreditStatusColor(credit.status),
                  );
                }).toList(),
                creditsWithIds.length > 3 ? '... и еще ${creditsWithIds.length - 3} кредитов' : null,
              ),
            ],
            
            if (payments.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDataSection(
                'Платежи (${payments.length})',
                Icons.payment,
                payments.take(3).map((payment) => _buildDataTile(
                  title: '${payment.amount.toStringAsFixed(0)} ₽',
                  subtitle: payment.status,
                  trailing: '${payment.dueDate.day}.${payment.dueDate.month}.${payment.dueDate.year}',
                  leading: 'Credit: ${payment.creditId}',
                  color: _getPaymentStatusColor(payment.status),
                )).toList(),
                payments.length > 3 ? '... и еще ${payments.length - 3} платежей' : null,
              ),
            ],
            
            if (organizations.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDataSection(
                'Организации (${organizations.length})',
                Icons.account_balance,
                organizations.take(3).map((org) => _buildDataTile(
                  title: org.displayName,
                  subtitle: org.type,
                  trailing: org.bic ?? '',
                  leading: 'ID: ${org.key}',
                  color: org.type == 'bank' ? Colors.blue : Colors.orange,
                )).toList(),
                organizations.length > 3 ? '... и еще ${organizations.length - 3} организаций' : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, dynamic value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: $value'),
        ],
      ),
    );
  }

  Widget _buildTestButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildDataSection(String title, IconData icon, List<Widget> children, String? footer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
            if (footer != null) ...[
              const SizedBox(height: 8),
              Text(
                footer,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataTile({
    required String title,
    required String subtitle,
    required String trailing,
    required String leading,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            leading,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCreditStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
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
