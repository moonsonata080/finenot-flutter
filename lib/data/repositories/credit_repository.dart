import 'package:isar/isar.dart';
import '../db/isar_provider.dart';
import '../models/credit.dart';
import '../models/payment.dart';

class CreditRepository {
  final Isar _isar = IsarProvider.instance;

  // CRUD operations
  Future<List<Credit>> getAllCredits() async {
    return await _isar.credits.where().findAll();
  }

  Future<Credit?> getCreditById(Id id) async {
    return await _isar.credits.get(id);
  }

  Future<List<Credit>> getActiveCredits() async {
    return await _isar.credits
        .filter()
        .statusEqualTo(CreditStatus.active)
        .findAll();
  }

  Future<Credit> createCredit(Credit credit) async {
    await _isar.writeTxn(() async {
      await _isar.credits.put(credit);
    });
    return credit;
  }

  Future<void> updateCredit(Credit credit) async {
    await _isar.writeTxn(() async {
      await _isar.credits.put(credit);
    });
  }

  Future<void> deleteCredit(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.credits.delete(id);
    });
  }

  // Business logic
  Future<Credit> createCreditWithFirstPayment(Credit credit) async {
    await _isar.writeTxn(() async {
      // Save credit
      await _isar.credits.put(credit);
      
      // Create first payment
      final firstPayment = Payment(
        amount: credit.monthlyPayment,
        dueDate: credit.nextPaymentDate,
        status: PaymentStatus.pending,
        type: PaymentType.regular,
      );
      
      await _isar.payments.put(firstPayment);
      
      // Link payment to credit
      firstPayment.credit.value = credit;
      await firstPayment.credit.save();
    });
    
    return credit;
  }

  Future<void> updateCreditBalance(Id creditId, double newBalance) async {
    final credit = await getCreditById(creditId);
    if (credit != null) {
      credit.currentBalance = newBalance;
      if (newBalance <= 0) {
        credit.status = CreditStatus.closed;
      }
      await updateCredit(credit);
    }
  }

  Future<void> updateNextPaymentDate(Id creditId, DateTime newDate) async {
    final credit = await getCreditById(creditId);
    if (credit != null) {
      credit.nextPaymentDate = newDate;
      await updateCredit(credit);
    }
  }

  // Analytics
  Future<double> getTotalDebt() async {
    final activeCredits = await getActiveCredits();
    return activeCredits.fold(0.0, (sum, credit) => sum + credit.currentBalance);
  }

  Future<double> getTotalMonthlyPayment() async {
    final activeCredits = await getActiveCredits();
    return activeCredits.fold(0.0, (sum, credit) => sum + credit.monthlyPayment);
  }

  Future<int> getActiveCreditsCount() async {
    return await _isar.credits
        .filter()
        .statusEqualTo(CreditStatus.active)
        .count();
  }

  Future<int> getOverdueCreditsCount() async {
    return await _isar.credits
        .filter()
        .statusEqualTo(CreditStatus.overdue)
        .count();
  }
}
