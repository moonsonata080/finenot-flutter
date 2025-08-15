import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/models/payment.dart';

class PaymentsController extends GetxController {
  final PaymentRepository _paymentRepository = PaymentRepository();

  // Observable variables
  final RxList<Payment> payments = <Payment>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  // Computed properties
  RxList<Payment> get upcomingPayments => <Payment>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPayments();
  }

  Future<void> loadPayments() async {
    try {
      loading.value = true;
      error.value = '';

      final allPayments = await _paymentRepository.getAllPayments();
      payments.value = allPayments;

      // Update computed properties
      await _updateComputedProperties();
    } catch (e) {
      error.value = 'Ошибка загрузки платежей: $e';
      print('Error loading payments: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> _updateComputedProperties() async {
    upcomingPayments.value = await _paymentRepository.getUpcomingPayments();
  }

  Future<void> addPayment(Payment payment) async {
    try {
      loading.value = true;
      error.value = '';

      await _paymentRepository.addPayment(payment);
      await loadPayments();

      Get.snackbar(
        'Успешно',
        'Платеж добавлен',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка добавления платежа: $e';
      print('Error adding payment: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> updatePayment(Payment payment) async {
    try {
      loading.value = true;
      error.value = '';

      await _paymentRepository.updatePayment(payment);
      await loadPayments();

      Get.snackbar(
        'Успешно',
        'Платеж обновлен',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка обновления платежа: $e';
      print('Error updating payment: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> deletePayment(int id) async {
    try {
      loading.value = true;
      error.value = '';

      await _paymentRepository.deletePayment(id);
      await loadPayments();

      Get.snackbar(
        'Успешно',
        'Платеж удален',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка удаления платежа: $e';
      print('Error deleting payment: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> markPaymentAsPaid(int paymentId, double amount) async {
    try {
      loading.value = true;
      error.value = '';

      await _paymentRepository.markPaymentAsPaid(paymentId);
      await loadPayments();

      Get.snackbar(
        'Успешно',
        'Платеж отмечен как оплаченный',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка отметки платежа: $e';
      print('Error marking payment as paid: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> markPaymentAsPartial(int paymentId, double partialAmount) async {
    try {
      loading.value = true;
      error.value = '';

      await _paymentRepository.markPaymentAsPartial(paymentId, partialAmount);
      await loadPayments();

      Get.snackbar(
        'Успешно',
        'Платеж отмечен как частично оплаченный',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка отметки частичного платежа: $e';
      print('Error marking payment as partial: $e');
    } finally {
      loading.value = false;
    }
  }

  // Helper methods
  String getPaymentStatusName(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Ожидает оплаты';
      case PaymentStatus.paid:
        return 'Оплачен';
      case PaymentStatus.partial:
        return 'Частично оплачен';
      case PaymentStatus.overdue:
        return 'Просрочен';
      default:
        return 'Неизвестно';
    }
  }

  String getPaymentTypeName(PaymentType type) {
    switch (type) {
      case PaymentType.regular:
        return 'Обычный';
      case PaymentType.partial:
        return 'Частичный';
      case PaymentType.extra:
        return 'Дополнительный';
      default:
        return 'Неизвестно';
    }
  }

  Color getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return const Color(0xFFFF9800);
      case PaymentStatus.paid:
        return const Color(0xFF4CAF50);
      case PaymentStatus.partial:
        return const Color(0xFF2196F3);
      case PaymentStatus.overdue:
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Color getPaymentUrgencyColor(Payment payment) {
    final now = DateTime.now();
    final daysUntilDue = payment.dueDate.difference(now).inDays;

    if (payment.status == PaymentStatus.paid) {
      return const Color(0xFF4CAF50);
    } else if (payment.status == PaymentStatus.overdue) {
      return const Color(0xFFF44336);
    } else if (daysUntilDue <= 3) {
      return const Color(0xFFF44336);
    } else if (daysUntilDue <= 7) {
      return const Color(0xFFFF9800);
    } else {
      return const Color(0xFF4CAF50);
    }
  }

  // Filter methods
  List<Payment> getPaymentsByCreditId(int creditId) {
    return payments.where((payment) => payment.creditId == creditId).toList();
  }

  List<Payment> getPendingPayments() {
    return payments.where((payment) => payment.status == PaymentStatus.pending).toList();
  }

  List<Payment> getOverduePayments() {
    return payments.where((payment) => payment.status == PaymentStatus.overdue).toList();
  }

  List<Payment> get overduePayments {
    return payments.where((payment) => payment.status == PaymentStatus.overdue).toList();
  }

  List<Payment> getPaidPayments() {
    return payments.where((payment) => payment.status == PaymentStatus.paid).toList();
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

  // Format currency
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} ₽';
  }

  // Format date
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  // Additional helper methods
  bool isPaymentOverdue(Payment payment) {
    return payment.dueDate.isBefore(DateTime.now()) && 
           payment.status == PaymentStatus.pending;
  }

  String getPaymentUrgencyText(Payment payment) {
    final now = DateTime.now();
    final daysUntilDue = payment.dueDate.difference(now).inDays;
    
    if (payment.status == PaymentStatus.paid) {
      return 'Оплачен';
    } else if (payment.status == PaymentStatus.overdue) {
      return 'Просрочен';
    } else if (daysUntilDue < 0) {
      return 'Просрочен на ${daysUntilDue.abs()} дн.';
    } else if (daysUntilDue == 0) {
      return 'Сегодня';
    } else if (daysUntilDue == 1) {
      return 'Завтра';
    } else if (daysUntilDue <= 7) {
      return 'Через $daysUntilDue дн.';
    } else {
      return 'Через $daysUntilDue дн.';
    }
  }

  Future<bool> markPaymentPaid(int paymentId, double amount) async {
    try {
      await markPaymentAsPaid(paymentId, amount);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> markPaymentAsMissed(int paymentId) async {
    try {
      loading.value = true;
      error.value = '';

      await _paymentRepository.markPaymentAsMissed(paymentId);
      await loadPayments();

      Get.snackbar(
        'Успешно',
        'Платеж отмечен как пропущенный',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка отметки платежа: $e';
      print('Error marking payment as missed: $e');
    } finally {
      loading.value = false;
    }
  }
}
