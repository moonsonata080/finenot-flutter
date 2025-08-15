// Simple Credit Repository without Isar for testing
import '../models/credit.dart';

class CreditRepository {
  static final List<Credit> _credits = [];
  static int _nextId = 1;

  // Get all credits
  Future<List<Credit>> getAllCredits() async {
    return List.from(_credits);
  }

  // Get credit by ID
  Future<Credit?> getCreditById(int id) async {
    try {
      return _credits.firstWhere((credit) => credit.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new credit
  Future<void> addCredit(Credit credit) async {
    final newCredit = Credit(
      id: _nextId++,
      name: credit.name,
      bankName: credit.bankName,
      createdAt: DateTime.now(),
      initialAmount: credit.initialAmount,
      currentBalance: credit.currentBalance,
      monthlyPayment: credit.monthlyPayment,
      interestRate: credit.interestRate,
      nextPaymentDate: credit.nextPaymentDate,
      status: credit.status,
      type: credit.type,
    );
    _credits.add(newCredit);
  }

  // Update credit
  Future<void> updateCredit(Credit credit) async {
    final index = _credits.indexWhere((c) => c.id == credit.id);
    if (index != -1) {
      _credits[index] = credit;
    }
  }

  // Delete credit
  Future<void> deleteCredit(int id) async {
    _credits.removeWhere((credit) => credit.id == id);
  }

  // Update credit balance
  Future<void> updateCreditBalance(int creditId, double newBalance) async {
    final credit = await getCreditById(creditId);
    if (credit != null) {
      final updatedCredit = Credit(
        id: credit.id,
        name: credit.name,
        bankName: credit.bankName,
        createdAt: credit.createdAt,
        initialAmount: credit.initialAmount,
        currentBalance: newBalance,
        monthlyPayment: credit.monthlyPayment,
        interestRate: credit.interestRate,
        nextPaymentDate: credit.nextPaymentDate,
        status: newBalance <= 0 ? CreditStatus.paid : credit.status,
        type: credit.type,
      );
      await updateCredit(updatedCredit);
    }
  }

  // Update next payment date
  Future<void> updateNextPaymentDate(int creditId, DateTime newDate) async {
    final credit = await getCreditById(creditId);
    if (credit != null) {
      final updatedCredit = Credit(
        id: credit.id,
        name: credit.name,
        bankName: credit.bankName,
        createdAt: credit.createdAt,
        initialAmount: credit.initialAmount,
        currentBalance: credit.currentBalance,
        monthlyPayment: credit.monthlyPayment,
        interestRate: credit.interestRate,
        nextPaymentDate: newDate,
        status: credit.status,
        type: credit.type,
      );
      await updateCredit(updatedCredit);
    }
  }

  // Get active credits
  Future<List<Credit>> getActiveCredits() async {
    return _credits.where((credit) => credit.status == CreditStatus.active).toList();
  }

  // Get overdue credits
  Future<List<Credit>> getOverdueCredits() async {
    final now = DateTime.now();
    return _credits.where((credit) => 
      credit.status == CreditStatus.active && 
      credit.nextPaymentDate.isBefore(now)
    ).toList();
  }

  // Calculate total debt
  Future<double> getTotalDebt() async {
    final activeCredits = await getActiveCredits();
    return activeCredits.fold(0.0, (sum, credit) => sum + credit.currentBalance);
  }

  // Calculate total monthly payment
  Future<double> getTotalMonthlyPayment() async {
    final activeCredits = await getActiveCredits();
    return activeCredits.fold(0.0, (sum, credit) => sum + credit.monthlyPayment);
  }
}
