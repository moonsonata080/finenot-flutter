// Simple Payment Repository without Isar for testing
import '../models/payment.dart';
import '../models/credit.dart';

class PaymentRepository {
  static final List<Payment> _payments = [];
  static int _nextId = 1;

  // Get all payments
  Future<List<Payment>> getAllPayments() async {
    return List.from(_payments);
  }

  // Get payment by ID
  Future<Payment?> getPaymentById(int id) async {
    try {
      return _payments.firstWhere((payment) => payment.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get payments by credit ID
  Future<List<Payment>> getPaymentsByCreditId(int creditId) async {
    return _payments.where((payment) => payment.creditId == creditId).toList();
  }

  // Add new payment
  Future<void> addPayment(Payment payment) async {
    final newPayment = Payment(
      id: _nextId++,
      amount: payment.amount,
      dueDate: payment.dueDate,
      paidDate: payment.paidDate,
      status: payment.status,
      type: payment.type,
      createdAt: DateTime.now(),
      creditId: payment.creditId,
    );
    _payments.add(newPayment);
  }

  // Update payment
  Future<void> updatePayment(Payment payment) async {
    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      _payments[index] = payment;
    }
  }

  // Delete payment
  Future<void> deletePayment(int id) async {
    _payments.removeWhere((payment) => payment.id == id);
  }

  // Get upcoming payments
  Future<List<Payment>> getUpcomingPayments() async {
    final now = DateTime.now();
    return _payments.where((payment) => 
      payment.status == PaymentStatus.pending && 
      payment.dueDate.isAfter(now)
    ).toList();
  }

  // Get overdue payments
  Future<List<Payment>> getOverduePayments() async {
    final now = DateTime.now();
    return _payments.where((payment) => 
      payment.status == PaymentStatus.pending && 
      payment.dueDate.isBefore(now)
    ).toList();
  }

  // Mark payment as paid
  Future<void> markPaymentAsPaid(int paymentId) async {
    final payment = await getPaymentById(paymentId);
    if (payment != null) {
      final updatedPayment = Payment(
        id: payment.id,
        amount: payment.amount,
        dueDate: payment.dueDate,
        paidDate: DateTime.now(),
        status: PaymentStatus.paid,
        type: payment.type,
        createdAt: payment.createdAt,
        creditId: payment.creditId,
      );
      await updatePayment(updatedPayment);
    }
  }

  // Mark payment as partial
  Future<void> markPaymentAsPartial(int paymentId, double partialAmount) async {
    final payment = await getPaymentById(paymentId);
    if (payment != null) {
      final updatedPayment = Payment(
        id: payment.id,
        amount: payment.amount,
        dueDate: payment.dueDate,
        paidDate: DateTime.now(),
        status: PaymentStatus.partial,
        type: PaymentType.partial,
        createdAt: payment.createdAt,
        creditId: payment.creditId,
      );
      await updatePayment(updatedPayment);
    }
  }

  // Mark payment as missed
  Future<void> markPaymentAsMissed(int paymentId) async {
    final payment = await getPaymentById(paymentId);
    if (payment != null) {
      final updatedPayment = Payment(
        id: payment.id,
        amount: payment.amount,
        dueDate: payment.dueDate,
        paidDate: payment.paidDate,
        status: PaymentStatus.overdue,
        type: payment.type,
        createdAt: payment.createdAt,
        creditId: payment.creditId,
      );
      await updatePayment(updatedPayment);
    }
  }

  // Create next payment for credit
  Future<void> createNextPayment(Credit credit) async {
    final nextPayment = Payment(
      id: _nextId++,
      amount: credit.monthlyPayment,
      dueDate: credit.nextPaymentDate,
      status: PaymentStatus.pending,
      type: PaymentType.regular,
      createdAt: DateTime.now(),
      creditId: credit.id,
    );
    _payments.add(nextPayment);
  }

  // Get payments for credit with status
  Future<List<Payment>> getPaymentsByCreditIdAndStatus(int creditId, PaymentStatus status) async {
    return _payments.where((payment) => 
      payment.creditId == creditId && 
      payment.status == status
    ).toList();
  }
}
