import 'package:hive_flutter/hive_flutter.dart';
import '../models/payment.dart';
import '../models/credit.dart';
import '../../core/services/hive_provider.dart';

class PaymentRepository {
  final Box<Payment> _paymentsBox = HiveProvider.paymentsBox;
  final Box<Credit> _creditsBox = HiveProvider.creditsBox;

  // Get all payments
  Future<List<Payment>> getAllPayments() async {
    return _paymentsBox.values.toList();
  }

  // Get payments by credit ID
  Future<List<Payment>> getPaymentsByCreditId(String creditId) async {
    return _paymentsBox.values.where((payment) => payment.creditId == creditId).toList();
  }

  // Get payments by status
  Future<List<Payment>> getPaymentsByStatus(String status) async {
    return _paymentsBox.values.where((payment) => payment.status == status).toList();
  }

  // Get payments by date range
  Future<List<Payment>> getPaymentsByDateRange(DateTime startDate, DateTime endDate) async {
    return _paymentsBox.values
        .where((payment) => payment.dueDate.isAfter(startDate) && payment.dueDate.isBefore(endDate))
        .toList();
  }

  // Get overdue payments
  Future<List<Payment>> getOverduePayments() async {
    final now = DateTime.now();
    return _paymentsBox.values
        .where((payment) => payment.status == 'pending' && payment.dueDate.isBefore(now))
        .toList();
  }

  // Get upcoming payments (next 30 days)
  Future<List<Payment>> getUpcomingPayments() async {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    return _paymentsBox.values
        .where((payment) => 
            payment.status == 'pending' && 
            payment.dueDate.isAfter(now) && 
            payment.dueDate.isBefore(thirtyDaysFromNow))
        .toList();
  }

  // Get payment by ID
  Future<Payment?> getPaymentById(String id) async {
    return _paymentsBox.get(id);
  }

  // Add new payment
  Future<String> addPayment(Payment payment) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _paymentsBox.put(id, payment);
    return id;
  }

  // Update payment
  Future<void> updatePayment(String id, Payment payment) async {
    await _paymentsBox.put(id, payment);
  }

  // Delete payment
  Future<void> deletePayment(String id) async {
    await _paymentsBox.delete(id);
  }

  // Mark payment as paid
  Future<void> markPaymentAsPaid(String paymentId, double amount) async {
    final payment = await getPaymentById(paymentId);
    if (payment != null) {
      final updatedPayment = payment.copyWith(
        status: amount >= payment.amount ? 'paid' : 'partial',
        paidDate: DateTime.now(),
      );
      
      await updatePayment(paymentId, updatedPayment);

      // Update credit balance
      await _updateCreditBalance(payment.creditId, amount);
    }
  }

  // Mark payment as missed
  Future<void> markPaymentAsMissed(String paymentId) async {
    final payment = await getPaymentById(paymentId);
    if (payment != null) {
      final updatedPayment = payment.copyWith(status: 'missed');
      await updatePayment(paymentId, updatedPayment);
    }
  }

  // Get total paid amount for credit
  Future<double> getTotalPaidForCredit(String creditId) async {
    final payments = await getPaymentsByCreditId(creditId);
    return payments
        .where((payment) => payment.status == 'paid' || payment.status == 'partial')
        .fold<double>(0.0, (sum, payment) => sum + payment.amount);
  }

  // Get total pending amount for credit
  Future<double> getTotalPendingForCredit(String creditId) async {
    final payments = await getPaymentsByCreditId(creditId);
    return payments
        .where((payment) => payment.status == 'pending')
        .fold<double>(0.0, (sum, payment) => sum + payment.amount);
  }

  // Get payments statistics
  Future<Map<String, dynamic>> getPaymentStatistics() async {
    final allPayments = await getAllPayments();
    
    final totalPayments = allPayments.length;
    final paidPayments = allPayments.where((p) => p.status == 'paid').length;
    final pendingPayments = allPayments.where((p) => p.status == 'pending').length;
    final missedPayments = allPayments.where((p) => p.status == 'missed').length;
    final partialPayments = allPayments.where((p) => p.status == 'partial').length;

    final totalAmount = allPayments.fold(0.0, (sum, p) => sum + p.amount);
    final paidAmount = allPayments
        .where((p) => p.status == 'paid')
        .fold(0.0, (sum, p) => sum + p.amount);

    return {
      'totalPayments': totalPayments,
      'paidPayments': paidPayments,
      'pendingPayments': pendingPayments,
      'missedPayments': missedPayments,
      'partialPayments': partialPayments,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'paymentRate': totalPayments > 0 ? (paidPayments / totalPayments) * 100 : 0.0,
    };
  }

  // Update credit balance after payment
  Future<void> _updateCreditBalance(String creditId, double paymentAmount) async {
    // Find credit by creditId
    final credit = await _creditsBox.get(creditId);
    
    if (credit != null) {
      final newBalance = credit.currentBalance - paymentAmount;
      final updatedCredit = credit.copyWith(
        currentBalance: newBalance > 0 ? newBalance : 0,
        status: newBalance <= 0 ? 'closed' : credit.status,
      );
      
      await _creditsBox.put(creditId, updatedCredit);
    }
  }

  // Get payments for today
  Future<List<Payment>> getPaymentsForToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _paymentsBox.values
        .where((payment) => 
            payment.dueDate.isAfter(today) && 
            payment.dueDate.isBefore(tomorrow))
        .toList();
  }

  // Get payments for this week
  Future<List<Payment>> getPaymentsForThisWeek() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    return _paymentsBox.values
        .where((payment) => 
            payment.dueDate.isAfter(startOfWeek) && 
            payment.dueDate.isBefore(endOfWeek))
        .toList();
  }

  // Get payments for this month
  Future<List<Payment>> getPaymentsForThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    
    return _paymentsBox.values
        .where((payment) => 
            payment.dueDate.isAfter(startOfMonth) && 
            payment.dueDate.isBefore(endOfMonth))
        .toList();
  }
}
