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
  final RxList<Credit> credits = <Credit>[].obs;
  final RxList<Payment> payments = <Payment>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  // Computed properties
  RxDouble get totalDebt => 0.0.obs;
  RxDouble get totalMonthlyPayment => 0.0.obs;
  RxDouble get debtProgress => 0.0.obs;
  RxList<Credit> get overdueCredits => <Credit>[].obs;
  RxList<Payment> get upcomingPayments => <Payment>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      loading.value = true;
      error.value = '';

      // Load credits and payments
      final allCredits = await _creditRepository.getAllCredits();
      final allPayments = await _paymentRepository.getAllPayments();
      
      credits.value = allCredits;
      payments.value = allPayments;

      // Update computed properties
      await _updateComputedProperties();
    } catch (e) {
      error.value = 'Ошибка загрузки данных: $e';
      print('Error loading dashboard data: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> _updateComputedProperties() async {
    // Calculate total debt and monthly payment
    totalDebt.value = await _creditRepository.getTotalDebt();
    totalMonthlyPayment.value = await _creditRepository.getTotalMonthlyPayment();
    
    // Get overdue credits
    overdueCredits.value = await _creditRepository.getOverdueCredits();
    
    // Get upcoming payments
    upcomingPayments.value = await _paymentRepository.getUpcomingPayments();
    
    // Calculate debt progress
    final totalInitialAmount = credits.fold(0.0, (sum, credit) => sum + credit.initialAmount);
    if (totalInitialAmount > 0) {
      final totalPaid = totalInitialAmount - totalDebt.value;
      debtProgress.value = (totalPaid / totalInitialAmount).clamp(0.0, 1.0);
    }
  }

  // Helper methods
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} ₽';
  }

  Color getFinancialStatusColor() {
    if (overdueCredits.isNotEmpty) {
      return const Color(0xFFF44336); // Red for overdue
    } else if (upcomingPayments.length > 3) {
      return const Color(0xFFFF9800); // Orange for many upcoming payments
    } else {
      return const Color(0xFF4CAF50); // Green for good status
    }
  }

  String getFinancialStatusText() {
    if (overdueCredits.isNotEmpty) {
      return 'Есть просроченные кредиты';
    } else if (upcomingPayments.length > 3) {
      return 'Много предстоящих платежей';
    } else {
      return 'Финансовое состояние в порядке';
    }
  }

  // Get credits by status
  List<Credit> getActiveCredits() {
    return credits.where((credit) => credit.status == CreditStatus.active).toList();
  }

  List<Credit> getOverdueCreditsList() {
    return credits.where((credit) => credit.status == CreditStatus.overdue).toList();
  }

  // Get payments for today
  List<Payment> getPaymentsForToday() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return payments.where((payment) => 
      payment.dueDate.isAfter(startOfDay) && 
      payment.dueDate.isBefore(endOfDay)
    ).toList();
  }

  // Get payments for this week
  List<Payment> getPaymentsForWeek() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return payments.where((payment) => 
      payment.dueDate.isAfter(startOfWeek) && 
      payment.dueDate.isBefore(endOfWeek)
    ).toList();
  }

  // Refresh dashboard
  Future<void> refresh() async {
    await loadDashboardData();
  }
}
