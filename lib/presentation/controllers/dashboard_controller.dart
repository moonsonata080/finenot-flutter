import 'package:get/get.dart';
import '../../data/repositories/credit_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/models/credit.dart';
import '../../data/models/payment.dart';

class DashboardController extends GetxController {
  final CreditRepository _creditRepo = CreditRepository();
  final PaymentRepository _paymentRepo = PaymentRepository();
  final SettingsRepository _settingsRepo = SettingsRepository();

  // Observable variables
  final RxList<Credit> credits = <Credit>[].obs;
  final RxList<Payment> upcomingPayments = <Payment>[].obs;
  final RxList<Payment> overduePayments = <Payment>[].obs;
  
  final RxDouble totalDebt = 0.0.obs;
  final RxDouble totalMonthlyPayments = 0.0.obs;
  final RxDouble monthlyIncome = 0.0.obs;
  final RxDouble dsr = 0.0.obs; // Debt Service Ratio
  
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Statistics
  final RxInt activeCreditsCount = 0.obs;
  final RxInt overdueCreditsCount = 0.obs;
  final RxInt totalPaymentsCount = 0.obs;
  final RxDouble paymentRate = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // Load all dashboard data
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Load data in parallel
      await Future.wait([
        _loadCredits(),
        _loadPayments(),
        _loadSettings(),
        _loadStatistics(),
      ]);

      // Calculate derived values
      _calculateDSR();
      
    } catch (e) {
      errorMessage.value = 'Ошибка загрузки данных: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Load credits data
  Future<void> _loadCredits() async {
    try {
      credits.value = await _creditRepo.getAllCredits();
      
      // Calculate totals
      totalDebt.value = await _creditRepo.getTotalDebt();
      totalMonthlyPayments.value = await _creditRepo.getTotalMonthlyPayments();
      
      // Count active and overdue credits
      activeCreditsCount.value = credits.where((c) => c.status == 'active').length;
      overdueCreditsCount.value = credits.where((c) => c.status == 'overdue').length;
      
    } catch (e) {
      print('Error loading credits: $e');
    }
  }

  // Load payments data
  Future<void> _loadPayments() async {
    try {
      upcomingPayments.value = await _paymentRepo.getUpcomingPayments();
      overduePayments.value = await _paymentRepo.getOverduePayments();
      
    } catch (e) {
      print('Error loading payments: $e');
    }
  }

  // Load settings data
  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsRepo.getSettings();
      monthlyIncome.value = settings.monthlyIncome ?? 0.0;
      
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // Load statistics
  Future<void> _loadStatistics() async {
    try {
      final paymentStats = await _paymentRepo.getPaymentStatistics();
      totalPaymentsCount.value = paymentStats['totalPayments'] ?? 0;
      paymentRate.value = paymentStats['paymentRate'] ?? 0.0;
      
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  // Calculate Debt Service Ratio
  void _calculateDSR() {
    if (monthlyIncome.value > 0) {
      dsr.value = (totalMonthlyPayments.value / monthlyIncome.value) * 100;
    } else {
      dsr.value = 0.0;
    }
  }

  // Get DSR status (green/yellow/red)
  String getDsrStatus() {
    if (dsr.value < 30) return 'good';
    if (dsr.value < 50) return 'warning';
    return 'danger';
  }

  // Get DSR status color
  String getDsrStatusColor() {
    switch (getDsrStatus()) {
      case 'good':
        return '#4CAF50'; // Green
      case 'warning':
        return '#FF9800'; // Orange
      case 'danger':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Get DSR status text
  String getDsrStatusText() {
    switch (getDsrStatus()) {
      case 'good':
        return 'Отличное';
      case 'warning':
        return 'Внимание';
      case 'danger':
        return 'Критично';
      default:
        return 'Неизвестно';
    }
  }

  // Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboardData();
  }

  // Get credits by status
  List<Credit> getCreditsByStatus(String status) {
    return credits.where((credit) => credit.status == status).toList();
  }

  // Get credits by type
  List<Credit> getCreditsByType(String type) {
    return credits.where((credit) => credit.type == type).toList();
  }

  // Get total debt by type
  double getTotalDebtByType(String type) {
    return credits
        .where((credit) => credit.type == type && credit.status == 'active')
        .fold(0.0, (sum, credit) => sum + credit.currentBalance);
  }

  // Get total monthly payments by type
  double getTotalMonthlyPaymentsByType(String type) {
    return credits
        .where((credit) => credit.type == type && credit.status == 'active')
        .fold(0.0, (sum, credit) => sum + credit.monthlyPayment);
  }

  // Get credits count by type
  Map<String, int> getCreditsCountByType() {
    final counts = <String, int>{};
    for (final credit in credits) {
      counts[credit.type] = (counts[credit.type] ?? 0) + 1;
    }
    return counts;
  }

  // Get debt distribution by type
  Map<String, double> getDebtDistributionByType() {
    final distribution = <String, double>{};
    for (final credit in credits.where((c) => c.status == 'active')) {
      distribution[credit.type] = (distribution[credit.type] ?? 0) + credit.currentBalance;
    }
    return distribution;
  }

  // Get monthly payments distribution by type
  Map<String, double> getMonthlyPaymentsDistributionByType() {
    final distribution = <String, double>{};
    for (final credit in credits.where((c) => c.status == 'active')) {
      distribution[credit.type] = (distribution[credit.type] ?? 0) + credit.monthlyPayment;
    }
    return distribution;
  }

  // Get upcoming payments for next N days
  List<Payment> getUpcomingPaymentsForDays(int days) {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    
    return upcomingPayments
        .where((payment) => payment.dueDate.isBefore(endDate))
        .toList();
  }

  // Get total amount for upcoming payments
  double getTotalUpcomingPaymentsAmount() {
    return upcomingPayments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  // Get total amount for overdue payments
  double getTotalOverduePaymentsAmount() {
    return overduePayments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  // Get dashboard summary
  Map<String, dynamic> getDashboardSummary() {
    return {
      'totalDebt': totalDebt.value,
      'totalMonthlyPayments': totalMonthlyPayments.value,
      'monthlyIncome': monthlyIncome.value,
      'dsr': dsr.value,
      'dsrStatus': getDsrStatus(),
      'activeCreditsCount': activeCreditsCount.value,
      'overdueCreditsCount': overdueCreditsCount.value,
      'totalPaymentsCount': totalPaymentsCount.value,
      'paymentRate': paymentRate.value,
      'upcomingPaymentsCount': upcomingPayments.length,
      'overduePaymentsCount': overduePayments.length,
      'totalUpcomingAmount': getTotalUpcomingPaymentsAmount(),
      'totalOverdueAmount': getTotalOverduePaymentsAmount(),
    };
  }

  // Check if data is loaded
  bool get isDataLoaded => !isLoading.value && errorMessage.value.isEmpty;

  // Get error message
  String get error => errorMessage.value;

  // Check if there are any errors
  bool get hasError => errorMessage.value.isNotEmpty;
}
