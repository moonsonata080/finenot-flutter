import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/credit_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/models/credit.dart';
import '../../data/models/payment.dart';

class DashboardController extends GetxController {
  final CreditRepository _creditRepository = CreditRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();

  // Observable variables
  final RxDouble totalDebt = 0.0.obs;
  final RxDouble totalMonthlyPayment = 0.0.obs;
  final RxDouble totalPaidThisMonth = 0.0.obs;
  final RxInt activeCreditsCount = 0.obs;
  final RxInt pendingPaymentsCount = 0.obs;
  final RxInt overduePaymentsCount = 0.obs;
  final RxList<Payment> upcomingPayments = <Payment>[].obs;
  final RxList<Credit> activeCredits = <Credit>[].obs;
  final RxBool loading = false.obs;

  // Financial status
  final RxString financialStatus = 'ok'.obs;

  // Computed properties
  double get debtProgress {
    if (totalDebt.value == 0) return 0.0;
    final totalInitial = activeCredits.fold(0.0, (sum, credit) => sum + credit.initialAmount);
    if (totalInitial == 0) return 0.0;
    final paid = totalInitial - totalDebt.value;
    return (paid / totalInitial).clamp(0.0, 1.0);
  }

  double get freeMoney => 0.0; // Placeholder for future implementation

  Color get financialStatusColor {
    switch (financialStatus.value) {
      case 'ok':
        return const Color(0xFF4CAF50); // Green
      case 'warn':
        return const Color(0xFFFF9800); // Orange
      case 'bad':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String get financialStatusText {
    switch (financialStatus.value) {
      case 'ok':
        return 'Хорошо';
      case 'warn':
        return 'Внимание';
      case 'bad':
        return 'Проблемы';
      default:
        return 'Хорошо';
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      loading.value = true;

      // Load all data in parallel
      await Future.wait([
        _loadTotalDebt(),
        _loadTotalMonthlyPayment(),
        _loadTotalPaidThisMonth(),
        _loadActiveCreditsCount(),
        _loadPendingPaymentsCount(),
        _loadOverduePaymentsCount(),
        _loadUpcomingPayments(),
        _loadActiveCredits(),
      ]);

      _calculateFinancialStatus();
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> _loadTotalDebt() async {
    totalDebt.value = await _creditRepository.getTotalDebt();
  }

  Future<void> _loadTotalMonthlyPayment() async {
    totalMonthlyPayment.value = await _creditRepository.getTotalMonthlyPayment();
  }

  Future<void> _loadTotalPaidThisMonth() async {
    totalPaidThisMonth.value = await _paymentRepository.getTotalPaidThisMonth();
  }

  Future<void> _loadActiveCreditsCount() async {
    activeCreditsCount.value = await _creditRepository.getActiveCreditsCount();
  }

  Future<void> _loadPendingPaymentsCount() async {
    pendingPaymentsCount.value = await _paymentRepository.getPendingPaymentsCount();
  }

  Future<void> _loadOverduePaymentsCount() async {
    overduePaymentsCount.value = await _paymentRepository.getOverduePaymentsCount();
  }

  Future<void> _loadUpcomingPayments() async {
    upcomingPayments.value = await _paymentRepository.getUpcomingPayments(7);
  }

  Future<void> _loadActiveCredits() async {
    activeCredits.value = await _creditRepository.getActiveCredits();
  }

  void _calculateFinancialStatus() {
    // Simple financial status calculation
    if (overduePaymentsCount.value > 0) {
      financialStatus.value = 'bad';
    } else if (totalDebt.value > 1000000 || pendingPaymentsCount.value > 5) {
      financialStatus.value = 'warn';
    } else {
      financialStatus.value = 'ok';
    }
  }

  // Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboardData();
  }

  // Format currency
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} ₽';
  }

  // Get upcoming payments for today
  List<Payment> getTodayPayments() {
    final today = DateTime.now();
    return upcomingPayments.where((payment) {
      return payment.dueDate.year == today.year &&
             payment.dueDate.month == today.month &&
             payment.dueDate.day == today.day;
    }).toList();
  }

  // Get upcoming payments for this week
  List<Payment> getThisWeekPayments() {
    final today = DateTime.now();
    final endOfWeek = today.add(const Duration(days: 7));
    return upcomingPayments.where((payment) {
      return payment.dueDate.isAfter(today) && 
             payment.dueDate.isBefore(endOfWeek);
    }).toList();
  }

  // Get credit by ID
  Credit? getCreditById(int id) {
    try {
      return activeCredits.firstWhere((credit) => credit.id == id);
    } catch (e) {
      return null;
    }
  }
}
