import 'package:hive_flutter/hive_flutter.dart';
import '../models/credit.dart';
import '../models/payment.dart';
import '../../core/services/hive_provider.dart';

class CreditRepository {
  final Box<Credit> _creditsBox = HiveProvider.creditsBox;
  final Box<Payment> _paymentsBox = HiveProvider.paymentsBox;

  // Get all credits
  Future<List<Credit>> getAllCredits() async {
    return _creditsBox.values.toList();
  }

  // Get active credits
  Future<List<Credit>> getActiveCredits() async {
    return _creditsBox.values.where((credit) => credit.status == 'active').toList();
  }

  // Get credit by ID
  Future<Credit?> getCreditById(String id) async {
    return _creditsBox.get(id);
  }

  // Add new credit
  Future<String> addCredit(Credit credit) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _creditsBox.put(id, credit);

    // Create first payment for the credit
    await _createFirstPayment(id, credit);

    return id;
  }

  // Update credit
  Future<void> updateCredit(String id, Credit credit) async {
    await _creditsBox.put(id, credit);
  }

  // Delete credit
  Future<void> deleteCredit(String id) async {
    // Delete associated payments first
    final payments = _paymentsBox.values.where((payment) => payment.creditId == id).toList();
    for (final payment in payments) {
      await payment.delete();
    }
    
    // Delete credit
    await _creditsBox.delete(id);
  }

  // Get credits by organization
  Future<List<Credit>> getCreditsByOrg(String orgId) async {
    return _creditsBox.values.where((credit) => credit.orgId == orgId).toList();
  }

  // Get credits by type
  Future<List<Credit>> getCreditsByType(String type) async {
    return _creditsBox.values.where((credit) => credit.type == type).toList();
  }

  // Get overdue credits
  Future<List<Credit>> getOverdueCredits() async {
    final now = DateTime.now();
    return _creditsBox.values
        .where((credit) => credit.status == 'active' && credit.nextPaymentDate.isBefore(now))
        .toList();
  }

  // Update credit balance after payment
  Future<void> updateCreditBalance(String creditId, double paymentAmount) async {
    final credit = await getCreditById(creditId);
    if (credit != null) {
      final newBalance = credit.currentBalance - paymentAmount;
      final updatedCredit = credit.copyWith(
        currentBalance: newBalance > 0 ? newBalance : 0,
        status: newBalance <= 0 ? 'closed' : credit.status,
      );
      
      await updateCredit(creditId, updatedCredit);
    }
  }

  // Create first payment for new credit
  Future<void> _createFirstPayment(String creditId, Credit credit) async {
    final payment = Payment(
      creditId: creditId,
      amount: credit.monthlyPayment,
      dueDate: credit.nextPaymentDate,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await _paymentsBox.add(payment);
  }

  // Create next payment for credit
  Future<void> createNextPayment(String creditId, Credit credit) async {
    final nextDate = DateTime(
      credit.nextPaymentDate.year,
      credit.nextPaymentDate.month + 1,
      credit.nextPaymentDate.day,
    );

    final payment = Payment(
      creditId: creditId,
      amount: credit.monthlyPayment,
      dueDate: nextDate,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await _paymentsBox.add(payment);

    // Update credit next payment date
    await updateCredit(creditId, credit.copyWith(nextPaymentDate: nextDate));
  }

  // Get total debt
  Future<double> getTotalDebt() async {
    final activeCredits = await getActiveCredits();
    return activeCredits.fold<double>(0.0, (sum, credit) => sum + credit.currentBalance);
  }

  // Get total monthly payments
  Future<double> getTotalMonthlyPayments() async {
    final activeCredits = await getActiveCredits();
    return activeCredits.fold<double>(0.0, (sum, credit) => sum + credit.monthlyPayment);
  }

  // Get credits count by status
  Future<Map<String, int>> getCreditsCountByStatus() async {
    final allCredits = await getAllCredits();
    final counts = <String, int>{};
    
    for (final credit in allCredits) {
      counts[credit.status] = (counts[credit.status] ?? 0) + 1;
    }
    
    return counts;
  }

  // Get credit with ID (helper method)
  Map<String, dynamic> getCreditWithId(String id, Credit credit) {
    return {
      'id': id,
      'credit': credit,
    };
  }

  // Get all credits with their IDs
  Future<List<Map<String, dynamic>>> getAllCreditsWithIds() async {
    final credits = <Map<String, dynamic>>[];
    final keys = _creditsBox.keys;
    
    for (final key in keys) {
      final credit = _creditsBox.get(key);
      if (credit != null) {
        credits.add({
          'id': key.toString(),
          'credit': credit,
        });
      }
    }
    
    return credits;
  }
}
