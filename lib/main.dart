import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/hive_provider.dart';
import 'data/repositories/credit_repository.dart';
import 'data/repositories/payment_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/org_repository.dart';
import 'presentation/controllers/dashboard_controller.dart';
import 'presentation/controllers/credits_controller.dart';
import 'data/models/credit.dart';
import 'data/models/payment.dart';
import 'data/models/settings.dart';
import 'data/models/org.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveProvider.initialize();
  
  // Initialize controllers
  Get.put(DashboardController());
  Get.put(CreditsController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FinEnot - Тестирование Hive',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TestPage(),
    );
  }
}

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
  
  final DashboardController _dashboardController = Get.find<DashboardController>();
  final CreditsController _creditsController = Get.find<CreditsController>();
  
  List<Credit> credits = [];
  List<Payment> payments = [];
  Settings? settings;
  List<Org> organizations = [];
  
  String statusMessage = 'Готов к тестированию';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
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
    }
  }

  Future<void> _loadCredits() async {
    credits = await _creditRepo.getAllCredits();
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
      statusMessage = 'Создание тестового кредита...';
    });

    try {
      final credit = Credit(
        name: 'Тестовый кредит ${DateTime.now().millisecondsSinceEpoch}',
        type: 'consumer',
        orgId: organizations.isNotEmpty ? int.parse(organizations.first.key!) : null,
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
    }
  }

  Future<void> _testCreatePayment() async {
    if (credits.isEmpty) {
      setState(() {
        statusMessage = 'Сначала создайте кредит!';
      });
      return;
    }

    setState(() {
      statusMessage = 'Создание тестового платежа...';
    });

    try {
      final payment = Payment(
        creditId: int.parse(credits.first.key!),
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
    }
  }

  Future<void> _testUpdateSettings() async {
    setState(() {
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
    }
  }

  Future<void> _testDashboardController() async {
    setState(() {
      statusMessage = 'Тестирование DashboardController...';
    });

    try {
      await _dashboardController.loadDashboardData();
      
      final summary = _dashboardController.getDashboardSummary();
      
      setState(() {
        statusMessage = 'DashboardController работает! DSR: ${summary['dsr']?.toStringAsFixed(1)}%';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Ошибка DashboardController: $e';
      });
    }
  }

  Future<void> _testCreditsController() async {
    setState(() {
      statusMessage = 'Тестирование CreditsController...';
    });

    try {
      await _creditsController.loadCredits();
      
      final summary = _creditsController.getCreditsSummary();
      
      setState(() {
        statusMessage = 'CreditsController работает! Кредитов: ${summary['totalCredits']}';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Ошибка CreditsController: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FinEnot - Тестирование Hive'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Статус: $statusMessage',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Кредитов: ${credits.length}'),
                    Text('Платежей: ${payments.length}'),
                    Text('Организаций: ${organizations.length}'),
                    if (settings != null) Text('Тема: ${settings!.themeMode}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Тестирование репозиториев',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    // Repository tests
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: _testCreateCredit,
                          child: const Text('Создать кредит'),
                        ),
                        ElevatedButton(
                          onPressed: _testCreatePayment,
                          child: const Text('Создать платеж'),
                        ),
                        ElevatedButton(
                          onPressed: _testUpdateSettings,
                          child: const Text('Обновить настройки'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Controller tests
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Тестирование контроллеров',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: _testDashboardController,
                          child: const Text('DashboardController'),
                        ),
                        ElevatedButton(
                          onPressed: _testCreditsController,
                          child: const Text('CreditsController'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Data display
            if (credits.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Кредиты (${credits.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...credits.take(3).map((credit) => ListTile(
                        title: Text(credit.name),
                        subtitle: Text('${credit.currentBalance.toStringAsFixed(0)} ₽'),
                        trailing: Text(credit.status),
                      )),
                      if (credits.length > 3)
                        Text('... и еще ${credits.length - 3} кредитов'),
                    ],
                  ),
                ),
              ),
            ],
            
            if (payments.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Платежи (${payments.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...payments.take(3).map((payment) => ListTile(
                        title: Text('${payment.amount.toStringAsFixed(0)} ₽'),
                        subtitle: Text(payment.status),
                        trailing: Text(payment.dueDate.toString().substring(0, 10)),
                      )),
                      if (payments.length > 3)
                        Text('... и еще ${payments.length - 3} платежей'),
                    ],
                  ),
                ),
              ),
            ],
            
            if (organizations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Организации (${organizations.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...organizations.take(3).map((org) => ListTile(
                        title: Text(org.displayName),
                        subtitle: Text(org.type),
                        trailing: Text(org.bic ?? ''),
                      )),
                      if (organizations.length > 3)
                        Text('... и еще ${organizations.length - 3} организаций'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadAllData,
        tooltip: 'Обновить данные',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
