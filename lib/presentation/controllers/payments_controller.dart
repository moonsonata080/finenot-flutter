import 'package:get/get.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/credit_repository.dart';
import '../../data/models/payment.dart';
import '../../data/models/credit.dart';

class PaymentsController extends GetxController {
  final PaymentRepository _paymentRepo = PaymentRepository();
  final CreditRepository _creditRepo = CreditRepository();

  // Observable variables
  final RxList<Payment> payments = <Payment>[].obs;
  final RxList<Credit> credits = <Credit>[].obs;
  
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;

  // Filter and search
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'all'.obs;
  final RxString selectedCredit = 'all'.obs;
  final RxString selectedDateRange = 'all'.obs;

  // Pagination
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxInt pageSize = 20.obs;
  final RxBool hasMoreData = true.obs;

  // Statistics
  final RxInt totalPayments = 0.obs;
  final RxInt paidPayments = 0.obs;
  final RxInt pendingPayments = 0.obs;
  final RxInt missedPayments = 0.obs;
  final RxInt partialPayments = 0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxDouble paidAmount = 0.0.obs;
  final RxDouble paymentRate = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPayments();
    loadCredits();
  }

  // Load all payments
  Future<void> loadPayments() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final allPayments = await _paymentRepo.getAllPayments();
      payments.value = allPayments;
      
      _applyFilters();
      await _loadStatistics();
      
    } catch (e) {
      errorMessage.value = 'Ошибка загрузки платежей: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Load credits for reference
  Future<void> loadCredits() async {
    try {
      credits.value = await _creditRepo.getAllCredits();
    } catch (e) {
      print('Error loading credits: $e');
    }
  }

  // Apply filters to payments
  void _applyFilters() {
    var filteredPayments = payments.where((payment) {
      // Status filter
      if (selectedStatus.value != 'all' && payment.status != selectedStatus.value) {
        return false;
      }

      // Credit filter
      if (selectedCredit.value != 'all') {
        final creditId = int.tryParse(selectedCredit.value);
        if (creditId != null && payment.creditId != creditId) {
          return false;
        }
      }

      // Date range filter
      if (selectedDateRange.value != 'all') {
        final now = DateTime.now();
        switch (selectedDateRange.value) {
          case 'today':
            final today = DateTime(now.year, now.month, now.day);
            final tomorrow = today.add(const Duration(days: 1));
            if (payment.dueDate.isBefore(today) || payment.dueDate.isAfter(tomorrow)) {
              return false;
            }
            break;
          case 'week':
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            final endOfWeek = startOfWeek.add(const Duration(days: 7));
            if (payment.dueDate.isBefore(startOfWeek) || payment.dueDate.isAfter(endOfWeek)) {
              return false;
            }
            break;
          case 'month':
            final startOfMonth = DateTime(now.year, now.month, 1);
            final endOfMonth = DateTime(now.year, now.month + 1, 1);
            if (payment.dueDate.isBefore(startOfMonth) || payment.dueDate.isAfter(endOfMonth)) {
              return false;
            }
            break;
          case 'overdue':
            if (payment.status != 'pending' || payment.dueDate.isAfter(now)) {
              return false;
            }
            break;
        }
      }

      return true;
    }).toList();

    // Apply pagination
    final startIndex = currentPage.value * pageSize.value;
    final endIndex = startIndex + pageSize.value;
    
    if (startIndex < filteredPayments.length) {
      payments.value = filteredPayments.sublist(
        startIndex,
        endIndex > filteredPayments.length ? filteredPayments.length : endIndex,
      );
      hasMoreData.value = endIndex < filteredPayments.length;
    } else {
      payments.value = [];
      hasMoreData.value = false;
    }

    totalPages.value = (filteredPayments.length / pageSize.value).ceil();
  }

  // Set status filter
  void setStatusFilter(String status) {
    selectedStatus.value = status;
    currentPage.value = 0;
    _applyFilters();
  }

  // Set credit filter
  void setCreditFilter(String creditId) {
    selectedCredit.value = creditId;
    currentPage.value = 0;
    _applyFilters();
  }

  // Set date range filter
  void setDateRangeFilter(String range) {
    selectedDateRange.value = range;
    currentPage.value = 0;
    _applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    selectedStatus.value = 'all';
    selectedCredit.value = 'all';
    selectedDateRange.value = 'all';
    currentPage.value = 0;
    _applyFilters();
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (!hasMoreData.value || isLoading.value) return;

    currentPage.value++;
    _applyFilters();
  }

  // Refresh payments
  Future<void> refresh() async {
    currentPage.value = 0;
    await loadPayments();
  }

  // Create new payment
  Future<bool> createPayment(Payment payment) async {
    try {
      isCreating.value = true;
      errorMessage.value = '';

      final paymentId = await _paymentRepo.addPayment(payment);
      
      // Reload payments to show the new one
      await loadPayments();
      
      return paymentId.isNotEmpty;
    } catch (e) {
      errorMessage.value = 'Ошибка создания платежа: $e';
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  // Update payment
  Future<bool> updatePayment(String id, Payment payment) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      await _paymentRepo.updatePayment(id, payment);
      
      // Reload payments to show the updated one
      await loadPayments();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка обновления платежа: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Delete payment
  Future<bool> deletePayment(String id) async {
    try {
      isDeleting.value = true;
      errorMessage.value = '';

      await _paymentRepo.deletePayment(id);
      
      // Reload payments to remove the deleted one
      await loadPayments();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка удаления платежа: $e';
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  // Mark payment as paid
  Future<bool> markPaymentAsPaid(String paymentId, double amount) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      await _paymentRepo.markPaymentAsPaid(paymentId, amount);
      
      // Reload payments and credits
      await Future.wait([loadPayments(), loadCredits()]);
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка отметки платежа: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Mark payment as missed
  Future<bool> markPaymentAsMissed(String paymentId) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      await _paymentRepo.markPaymentAsMissed(paymentId);
      
      // Reload payments
      await loadPayments();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка отметки платежа: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Get payment by ID
  Future<Payment?> getPaymentById(String id) async {
    try {
      return await _paymentRepo.getPaymentById(id);
    } catch (e) {
      errorMessage.value = 'Ошибка получения платежа: $e';
      return null;
    }
  }

  // Load statistics
  Future<void> _loadStatistics() async {
    try {
      final stats = await _paymentRepo.getPaymentStatistics();
      
      totalPayments.value = stats['totalPayments'] ?? 0;
      paidPayments.value = stats['paidPayments'] ?? 0;
      pendingPayments.value = stats['pendingPayments'] ?? 0;
      missedPayments.value = stats['missedPayments'] ?? 0;
      partialPayments.value = stats['partialPayments'] ?? 0;
      totalAmount.value = stats['totalAmount'] ?? 0.0;
      paidAmount.value = stats['paidAmount'] ?? 0.0;
      paymentRate.value = stats['paymentRate'] ?? 0.0;
    } catch (e) {
      print('Error loading payment statistics: $e');
    }
  }

  // Get payments by status
  List<Payment> getPaymentsByStatus(String status) {
    return payments.where((payment) => payment.status == status).toList();
  }

  // Get payments by credit
  List<Payment> getPaymentsByCredit(int creditId) {
    return payments.where((payment) => payment.creditId == creditId).toList();
  }

  // Get overdue payments
  List<Payment> getOverduePayments() {
    final now = DateTime.now();
    return payments
        .where((payment) => payment.status == 'pending' && payment.dueDate.isBefore(now))
        .toList();
  }

  // Get upcoming payments
  List<Payment> getUpcomingPayments() {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    return payments
        .where((payment) => 
            payment.status == 'pending' && 
            payment.dueDate.isAfter(now) && 
            payment.dueDate.isBefore(thirtyDaysFromNow))
        .toList();
  }

  // Get payments for today
  List<Payment> getPaymentsForToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return payments
        .where((payment) => 
            payment.dueDate.isAfter(today) && 
            payment.dueDate.isBefore(tomorrow))
        .toList();
  }

  // Get payments for this week
  List<Payment> getPaymentsForThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    return payments
        .where((payment) => 
            payment.dueDate.isAfter(startOfWeek) && 
            payment.dueDate.isBefore(endOfWeek))
        .toList();
  }

  // Get payments for this month
  List<Payment> getPaymentsForThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    
    return payments
        .where((payment) => 
            payment.dueDate.isAfter(startOfMonth) && 
            payment.dueDate.isBefore(endOfMonth))
        .toList();
  }

  // Get credit name by ID
  String getCreditNameById(int creditId) {
    try {
      final credit = credits.firstWhere((credit) => credit.key == creditId.toString());
      return credit.name;
    } catch (e) {
      return 'Неизвестный кредит';
    }
  }

  // Get payment status display name
  String getPaymentStatusDisplayName(String status) {
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

  // Get payment status color
  String getPaymentStatusColor(String status) {
    switch (status) {
      case 'pending':
        return '#FF9800'; // Orange
      case 'paid':
        return '#4CAF50'; // Green
      case 'partial':
        return '#2196F3'; // Blue
      case 'missed':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Check if payment is overdue
  bool isPaymentOverdue(Payment payment) {
    return payment.status == 'pending' && payment.dueDate.isBefore(DateTime.now());
  }

  // Get days until payment
  int getDaysUntilPayment(Payment payment) {
    final now = DateTime.now();
    return payment.dueDate.difference(now).inDays;
  }

  // Get total amount for payments
  double getTotalAmountForPayments(List<Payment> paymentList) {
    return paymentList.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  // Get payments summary
  Map<String, dynamic> getPaymentsSummary() {
    return {
      'totalPayments': totalPayments.value,
      'paidPayments': paidPayments.value,
      'pendingPayments': pendingPayments.value,
      'missedPayments': missedPayments.value,
      'partialPayments': partialPayments.value,
      'totalAmount': totalAmount.value,
      'paidAmount': paidAmount.value,
      'paymentRate': paymentRate.value,
      'overduePayments': getOverduePayments().length,
      'upcomingPayments': getUpcomingPayments().length,
      'todayPayments': getPaymentsForToday().length,
      'weekPayments': getPaymentsForThisWeek().length,
      'monthPayments': getPaymentsForThisMonth().length,
    };
  }

  // Check if data is loaded
  bool get isDataLoaded => !isLoading.value && errorMessage.value.isEmpty;

  // Get error message
  String get error => errorMessage.value;

  // Check if there are any errors
  bool get hasError => errorMessage.value.isNotEmpty;

  // Check if any operation is in progress
  bool get isOperationInProgress => isCreating.value || isUpdating.value || isDeleting.value;

  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }
}
