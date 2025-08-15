import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/credit_repository.dart';
import '../../data/models/credit.dart';

class CreditsController extends GetxController {
  final CreditRepository _creditRepository = CreditRepository();

  // Observable variables
  final RxList<Credit> credits = <Credit>[].obs;
  final RxList<Credit> activeCredits = <Credit>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCredits();
  }

  Future<void> loadCredits() async {
    try {
      isLoading.value = true;
      error.value = '';

      final allCredits = await _creditRepository.getAllCredits();
      credits.value = allCredits;
      
      final active = await _creditRepository.getActiveCredits();
      activeCredits.value = active;
    } catch (e) {
      error.value = 'Ошибка загрузки кредитов: $e';
      print('Error loading credits: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCredit(Credit credit) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Create credit with first payment
      await _creditRepository.createCreditWithFirstPayment(credit);
      
      // Reload credits
      await loadCredits();
      
      Get.back(); // Close add credit page
      Get.snackbar(
        'Успешно',
        'Кредит добавлен',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка добавления кредита: $e';
      print('Error adding credit: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCredit(Credit credit) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _creditRepository.updateCredit(credit);
      
      // Reload credits
      await loadCredits();
      
      Get.back(); // Close edit credit page
      Get.snackbar(
        'Успешно',
        'Кредит обновлен',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка обновления кредита: $e';
      print('Error updating credit: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCredit(int creditId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _creditRepository.deleteCredit(creditId);
      
      // Reload credits
      await loadCredits();
      
      Get.snackbar(
        'Успешно',
        'Кредит удален',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка удаления кредита: $e';
      print('Error deleting credit: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> closeCredit(int creditId) async {
    try {
      final credit = await _creditRepository.getCreditById(creditId);
      if (credit != null) {
        credit.status = CreditStatus.closed;
        await _creditRepository.updateCredit(credit);
        await loadCredits();
        
        Get.snackbar(
          'Успешно',
          'Кредит закрыт',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      error.value = 'Ошибка закрытия кредита: $e';
      print('Error closing credit: $e');
    }
  }

  // Get credit by ID
  Credit? getCreditById(int id) {
    try {
      return credits.firstWhere((credit) => credit.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get credits by status
  List<Credit> getCreditsByStatus(CreditStatus status) {
    return credits.where((credit) => credit.status == status).toList();
  }

  // Get credits by type
  List<Credit> getCreditsByType(CreditType type) {
    return credits.where((credit) => credit.type == type).toList();
  }

  // Format currency
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} ₽';
  }

  // Get credit type display name
  String getCreditTypeName(CreditType type) {
    switch (type) {
      case CreditType.consumer:
        return 'Потребительский';
      case CreditType.mortgage:
        return 'Ипотека';
      case CreditType.micro:
        return 'Микрозайм';
      default:
        return 'Неизвестно';
    }
  }

  // Get credit status display name
  String getCreditStatusName(CreditStatus status) {
    switch (status) {
      case CreditStatus.active:
        return 'Активный';
      case CreditStatus.closed:
        return 'Закрыт';
      case CreditStatus.overdue:
        return 'Просрочен';
      default:
        return 'Неизвестно';
    }
  }

  // Get credit status color
  Color getCreditStatusColor(CreditStatus status) {
    switch (status) {
      case CreditStatus.active:
        return const Color(0xFF4CAF50); // Green
      case CreditStatus.closed:
        return const Color(0xFF9E9E9E); // Gray
      case CreditStatus.overdue:
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // Calculate debt progress
  double getDebtProgress(Credit credit) {
    if (credit.initialAmount == 0) return 0.0;
    final paid = credit.initialAmount - credit.currentBalance;
    return (paid / credit.initialAmount).clamp(0.0, 1.0);
  }

  // Get total debt
  double getTotalDebt() {
    return activeCredits.fold(0.0, (sum, credit) => sum + credit.currentBalance);
  }

  // Get total monthly payment
  double getTotalMonthlyPayment() {
    return activeCredits.fold(0.0, (sum, credit) => sum + credit.monthlyPayment);
  }

  // Refresh credits
  Future<void> refresh() async {
    await loadCredits();
  }

  // Search credits by name
  List<Credit> searchCredits(String query) {
    if (query.isEmpty) return credits;
    
    return credits.where((credit) {
      return credit.name.toLowerCase().contains(query.toLowerCase()) ||
             (credit.bankName?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }
}
