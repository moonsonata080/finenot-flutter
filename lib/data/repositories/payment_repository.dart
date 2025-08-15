import 'package:isar/isar.dart';
import '../db/isar_provider.dart';
import '../models/payment.dart';
import '../models/credit.dart';

class PaymentRepository {
  final Isar _isar = IsarProvider.instance;

  // CRUD operations
  Future<List<Payment>> getAllPayments() async {
    return await _isar.payments.where().findAll();
  }

  Future<Payment?> getPaymentById(Id id) async {
    return await _isar.payments.get(id);
  }

  Future<List<Payment>> getPaymentsByCreditId(Id creditId) async {
    return await _isar.payments
        .filter()
        .credit((q) => q.idEqualTo(creditId))
        .findAll();
  }

  Future<Payment> createPayment(Payment payment) async {
    await _isar.writeTxn(() async {
      await _isar.payments.put(payment);
    });
    return payment;
  }

  Future<void> updatePayment(Payment payment) async {
    await _isar.writeTxn(() async {
      await _isar.payments.put(payment);
    });
  }

  Future<void> deletePayment(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.payments.delete(id);
    });
  }

  // Business logic queries
  Future<List<Payment>> getPaymentsForToday() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return await _isar.payments
        .filter()
        .dueDateBetween(startOfDay, endOfDay)
        .findAll();
  }

  Future<List<Payment>> getPaymentsForWeek() async {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    return await _isar.payments
        .filter()
        .dueDateBetween(startOfWeek, endOfWeek)
        .findAll();
  }

  Future<List<Payment>> getPaymentsForMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1);
    
    return await _isar.payments
        .filter()
        .dueDateBetween(startOfMonth, endOfMonth)
        .findAll();
  }

  Future<List<Payment>> getPendingPayments() async {
    return await _isar.payments
        .filter()
        .statusEqualTo(PaymentStatus.pending)
        .findAll();
  }

  Future<List<Payment>> getOverduePayments() async {
    final now = DateTime.now();
    return await _isar.payments
        .filter()
        .dueDateLessThan(now)
        .and()
        .statusEqualTo(PaymentStatus.pending)
        .findAll();
  }

  Future<List<Payment>> getUpcomingPayments(int days) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    
    return await _isar.payments
        .filter()
        .dueDateBetween(now, endDate)
        .and()
        .statusEqualTo(PaymentStatus.pending)
        .findAll();
  }

  // Payment processing
  Future<void> markPaymentAsPaid(Id paymentId) async {
    final payment = await getPaymentById(paymentId);
    if (payment != null) {
      payment.status = PaymentStatus.paid;
      payment.paidDate = DateTime.now();
      
      await updatePayment(payment);
      
      // Update credit balance
      final credit = payment.credit.value;
      if (credit != null) {
        final newBalance = credit.currentBalance - payment.amount;
        await _updateCreditBalanceAndScheduleNext(credit, newBalance);
      }
    }
  }

  Future<void> markPaymentAsPartial(Id paymentId, double partialAmount) async {
    final payment = await getPaymentById(paymentId);
    if (payment != null) {
      payment.status = PaymentStatus.partial;
      payment.amount = partialAmount;
      payment.paidDate = DateTime.now();
      
      await updatePayment(payment);
      
      // Update credit balance
      final credit = payment.credit.value;
      if (credit != null) {
        final newBalance = credit.currentBalance - partialAmount;
        await _updateCreditBalanceAndScheduleNext(credit, newBalance);
      }
    }
  }

  Future<void> markPaymentAsMissed(Id paymentId) async {
    final payment = await getPaymentById(paymentId);
    if (payment != null) {
      payment.status = PaymentStatus.missed;
      await updatePayment(payment);
      
      // Mark credit as overdue if needed
      final credit = payment.credit.value;
      if (credit != null && credit.status == CreditStatus.active) {
        credit.status = CreditStatus.overdue;
        await _isar.writeTxn(() async {
          await _isar.credits.put(credit);
        });
      }
    }
  }

  Future<void> createNextPayment(Credit credit) async {
    final nextPaymentDate = DateTime(
      credit.nextPaymentDate.year,
      credit.nextPaymentDate.month + 1,
      credit.nextPaymentDate.day,
    );
    
    final nextPayment = Payment(
      amount: credit.monthlyPayment,
      dueDate: nextPaymentDate,
      status: PaymentStatus.pending,
      type: PaymentType.regular,
    );
    
    await _isar.writeTxn(() async {
      await _isar.payments.put(nextPayment);
      nextPayment.credit.value = credit;
      await nextPayment.credit.save();
      
      // Update credit's next payment date
      credit.nextPaymentDate = nextPaymentDate;
      await _isar.credits.put(credit);
    });
  }

  // Private helper methods
  Future<void> _updateCreditBalanceAndScheduleNext(Credit credit, double newBalance) async {
    await _isar.writeTxn(() async {
      credit.currentBalance = newBalance;
      if (newBalance <= 0) {
        credit.status = CreditStatus.closed;
      }
      await _isar.credits.put(credit);
      
      // Create next payment if credit is still active
      if (credit.status == CreditStatus.active) {
        await createNextPayment(credit);
      }
    });
  }

  // Analytics
  Future<double> getTotalPaidThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    
    final payments = await _isar.payments
        .filter()
        .paidDateBetween(startOfMonth, endOfMonth)
        .and()
        .statusEqualTo(PaymentStatus.paid)
        .findAll();
    
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  Future<int> getPendingPaymentsCount() async {
    return await _isar.payments
        .filter()
        .statusEqualTo(PaymentStatus.pending)
        .count();
  }

  Future<int> getOverduePaymentsCount() async {
    final now = DateTime.now();
    return await _isar.payments
        .filter()
        .dueDateLessThan(now)
        .and()
        .statusEqualTo(PaymentStatus.pending)
        .count();
  }
}
