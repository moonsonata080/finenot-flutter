import 'package:get/get.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/credit_repository.dart';
import '../../data/models/payment.dart';
import '../../data/models/credit.dart';
import '../../core/services/notification_service.dart';
import 'package:flutter/material.dart';

class PaymentsController extends GetxController {
  final PaymentRepository _paymentRepository = PaymentRepository();
  final CreditRepository _creditRepository = CreditRepository();

  // Observable variables
  final RxList<Payment> payments = <Payment>[].obs;
  final RxList<Payment> todayPayments = <Payment>[].obs;
  final RxList<Payment> weekPayments = <Payment>[].obs;
  final RxList<Payment> pendingPayments = <Payment>[].obs;
  final RxList<Payment> overduePayments = <Payment>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Filter variables
  final RxString currentFilter = 'all'.obs;
  final RxString currentPeriod = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadPayments();
  }

  Future<void> loadPayments() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Load all payments
      final allPayments = await _paymentRepository.getAllPayments();
      payments.value = allPayments;

      // Load filtered payments
      await _loadFilteredPayments();
    } catch (e) {
      error.value = 'Ошибка загрузки платежей: $e';
      print('Error loading payments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFilteredPayments() async {
    try {
      // Load today's payments
      todayPayments.value = await _paymentRepository.getPaymentsForToday();

      // Load week's payments
      weekPayments.value = await _paymentRepository.getPaymentsForWeek();

      // Load pending payments
      pendingPayments.value = await _paymentRepository.getPendingPayments();

      // Load overdue payments
      overduePayments.value = await _paymentRepository.getOverduePayments();
    } catch (e) {
      print('Error loading filtered payments: $e');
    }
  }

  Future<void> markPaymentAsPaid(int paymentId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _paymentRepository.markPaymentAsPaid(paymentId);
      
      // Update notifications
      final payment = await _paymentRepository.getPaymentById(paymentId);
      if (payment != null) {
        await NotificationService.onPaymentStatusChanged(payment);
      }
      
      // Reload payments
      await loadPayments();
      
      Get.snackbar(
        'Успешно',
        'Платеж отмечен как оплаченный',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка обновления платежа: $e';
      print('Error marking payment as paid: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markPaymentAsPartial(int paymentId, double partialAmount) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _paymentRepository.markPaymentAsPartial(paymentId, partialAmount);
      
      // Update notifications
      final payment = await _paymentRepository.getPaymentById(paymentId);
      if (payment != null) {
        await NotificationService.onPaymentStatusChanged(payment);
      }
      
      // Reload payments
      await loadPayments();
      
      Get.snackbar(
        'Успешно',
        'Частичный платеж зарегистрирован',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка регистрации частичного платежа: $e';
      print('Error marking payment as partial: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markPaymentAsMissed(int paymentId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _paymentRepository.markPaymentAsMissed(paymentId);
      
      // Update notifications
      final payment = await _paymentRepository.getPaymentById(paymentId);
      if (payment != null) {
        await NotificationService.onPaymentStatusChanged(payment);
      }
      
      // Reload payments
      await loadPayments();
      
      Get.snackbar(
        'Успешно',
        'Платеж отмечен как пропущенный',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка обновления платежа: $e';
      print('Error marking payment as missed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get payments by filter
  List<Payment> getPaymentsByFilter(String filter) {
    switch (filter) {
      case 'today':
        return todayPayments;
      case 'week':
        return weekPayments;
      case 'pending':
        return pendingPayments;
      case 'overdue':
        return overduePayments;
      case 'all':
      default:
        return payments;
    }
  }

  // Get payments by period
  List<Payment> getPaymentsByPeriod(String period) {
    final now = DateTime.now();
    
    switch (period) {
      case 'today':
        return payments.where((payment) {
          return payment.dueDate.year == now.year &&
                 payment.dueDate.month == now.month &&
                 payment.dueDate.day == now.day;
        }).toList();
      case 'week':
        final endOfWeek = now.add(const Duration(days: 7));
        return payments.where((payment) {
          return payment.dueDate.isAfter(now) && 
                 payment.dueDate.isBefore(endOfWeek);
        }).toList();
      case 'month':
        final endOfMonth = DateTime(now.year, now.month + 1, 1);
        return payments.where((payment) {
          return payment.dueDate.isAfter(now) && 
                 payment.dueDate.isBefore(endOfMonth);
        }).toList();
      case 'all':
      default:
        return payments;
    }
  }

  // Set current filter
  void setFilter(String filter) {
    currentFilter.value = filter;
  }

  // Set current period
  void setPeriod(String period) {
    currentPeriod.value = period;
  }

  // Get current payments list
  List<Payment> get currentPayments {
    final filtered = getPaymentsByFilter(currentFilter.value);
    return getPaymentsByPeriod(currentPeriod.value);
  }

  // Get payment by ID
  Payment? getPaymentById(int id) {
    try {
      return payments.firstWhere((payment) => payment.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get payments by credit ID
  List<Payment> getPaymentsByCreditId(int creditId) {
    return payments.where((payment) {
      return payment.credit.value?.id == creditId;
    }).toList();
  }

  // Format currency
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} ₽';
  }

  // Format date
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  // Get payment status display name
  String getPaymentStatusName(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Ожидает';
      case PaymentStatus.paid:
        return 'Оплачен';
      case PaymentStatus.missed:
        return 'Пропущен';
      case PaymentStatus.partial:
        return 'Частично';
      default:
        return 'Неизвестно';
    }
  }

  // Get payment status color
  Color getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return const Color(0xFFFF9800); // Orange
      case PaymentStatus.paid:
        return const Color(0xFF4CAF50); // Green
      case PaymentStatus.missed:
        return const Color(0xFFF44336); // Red
      case PaymentStatus.partial:
        return const Color(0xFF2196F3); // Blue
      default:
        return const Color(0xFF9E9E9E); // Gray
    }
  }

  // Get payment type display name
  String getPaymentTypeName(PaymentType type) {
    switch (type) {
      case PaymentType.regular:
        return 'Обычный';
      case PaymentType.partial:
        return 'Частичный';
      case PaymentType.custom:
        return 'Дополнительный';
      default:
        return 'Неизвестно';
    }
  }

  // Check if payment is overdue
  bool isPaymentOverdue(Payment payment) {
    return payment.dueDate.isBefore(DateTime.now()) && 
           payment.status == PaymentStatus.pending;
  }

  // Get days until payment
  int getDaysUntilPayment(Payment payment) {
    final now = DateTime.now();
    final dueDate = DateTime(payment.dueDate.year, payment.dueDate.month, payment.dueDate.day);
    final today = DateTime(now.year, now.month, now.day);
    
    return dueDate.difference(today).inDays;
  }

  // Get payment urgency text
  String getPaymentUrgencyText(Payment payment) {
    final days = getDaysUntilPayment(payment);
    
    if (days < 0) {
      return 'Просрочен на ${days.abs()} дн.';
    } else if (days == 0) {
      return 'Сегодня';
    } else if (days == 1) {
      return 'Завтра';
    } else if (days <= 7) {
      return 'Через $days дн.';
    } else {
      return 'Через $days дн.';
    }
  }

  // Get payment urgency color
  Color getPaymentUrgencyColor(Payment payment) {
    final days = getDaysUntilPayment(payment);
    
    if (days < 0) {
      return const Color(0xFFF44336); // Red
    } else if (days <= 3) {
      return const Color(0xFFFF9800); // Orange
    } else if (days <= 7) {
      return const Color(0xFFFFC107); // Yellow
    } else {
      return const Color(0xFF4CAF50); // Green
    }
  }

  // Refresh payments
  Future<void> refresh() async {
    await loadPayments();
  }

  // Search payments by credit name
  List<Payment> searchPayments(String query) {
    if (query.isEmpty) return currentPayments;
    
    return currentPayments.where((payment) {
      final credit = payment.credit.value;
      if (credit == null) return false;
      
      return credit.name.toLowerCase().contains(query.toLowerCase()) ||
             (credit.bankName?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }
}
