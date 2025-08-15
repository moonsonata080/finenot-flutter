import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/credit_repository.dart';
import '../../data/models/credit.dart';

class CreditsController extends GetxController {
  final CreditRepository _creditRepository = CreditRepository();

  // Observable variables
  final RxList<Credit> credits = <Credit>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  // Computed properties
  RxDouble get totalDebt => 0.0.obs;
  RxDouble get totalMonthlyPayment => 0.0.obs;
  RxList<Credit> get overdueCredits => <Credit>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCredits();
  }

  Future<void> loadCredits() async {
    try {
      loading.value = true;
      error.value = '';

      final allCredits = await _creditRepository.getAllCredits();
      credits.value = allCredits;

      // Update computed properties
      await _updateComputedProperties();
    } catch (e) {
      error.value = 'Ошибка загрузки кредитов: $e';
      print('Error loading credits: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> _updateComputedProperties() async {
    totalDebt.value = await _creditRepository.getTotalDebt();
    totalMonthlyPayment.value = await _creditRepository.getTotalMonthlyPayment();
    overdueCredits.value = await _creditRepository.getOverdueCredits();
  }

  Future<void> addCredit(Credit credit) async {
    try {
      loading.value = true;
      error.value = '';

      await _creditRepository.addCredit(credit);
      await loadCredits();

      Get.snackbar(
        'Успешно',
        'Кредит добавлен',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка добавления кредита: $e';
      print('Error adding credit: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> updateCredit(Credit credit) async {
    try {
      loading.value = true;
      error.value = '';

      await _creditRepository.updateCredit(credit);
      await loadCredits();

      Get.snackbar(
        'Успешно',
        'Кредит обновлен',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка обновления кредита: $e';
      print('Error updating credit: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> deleteCredit(int id) async {
    try {
      loading.value = true;
      error.value = '';

      await _creditRepository.deleteCredit(id);
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
      loading.value = false;
    }
  }

  Future<void> markCreditAsPaid(int id) async {
    try {
      loading.value = true;
      error.value = '';

      await _creditRepository.updateCreditBalance(id, 0.0);
      await loadCredits();

      Get.snackbar(
        'Успешно',
        'Кредит погашен',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка погашения кредита: $e';
      print('Error marking credit as paid: $e');
    } finally {
      loading.value = false;
    }
  }

  // Helper methods
  String getCreditTypeName(CreditType type) {
    switch (type) {
      case CreditType.consumer:
        return 'Потребительский';
      case CreditType.mortgage:
        return 'Ипотека';
      case CreditType.microloan:
        return 'Микрозайм';
      default:
        return 'Неизвестно';
    }
  }

  String getCreditStatusName(CreditStatus status) {
    switch (status) {
      case CreditStatus.active:
        return 'Активный';
      case CreditStatus.paid:
        return 'Погашен';
      case CreditStatus.overdue:
        return 'Просрочен';
      case CreditStatus.defaulted:
        return 'Дефолт';
      default:
        return 'Неизвестно';
    }
  }

  Color getCreditStatusColor(CreditStatus status) {
    switch (status) {
      case CreditStatus.active:
        return const Color(0xFF4CAF50);
      case CreditStatus.paid:
        return const Color(0xFF2196F3);
      case CreditStatus.overdue:
        return const Color(0xFFFF9800);
      case CreditStatus.defaulted:
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Color getCreditTypeColor(CreditType type) {
    switch (type) {
      case CreditType.consumer:
        return const Color(0xFF4CAF50);
      case CreditType.mortgage:
        return const Color(0xFF2196F3);
      case CreditType.microloan:
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // Filter methods
  List<Credit> getActiveCredits() {
    return credits.where((credit) => credit.status == CreditStatus.active).toList();
  }

  List<Credit> get activeCredits {
    return credits.where((credit) => credit.status == CreditStatus.active).toList();
  }

  List<Credit> getOverdueCreditsList() {
    return credits.where((credit) => credit.status == CreditStatus.overdue).toList();
  }

  List<Credit> getPaidCredits() {
    return credits.where((credit) => credit.status == CreditStatus.paid).toList();
  }

  bool get isLoading => loading.value;

  // Add test data for development
  Future<void> addTestData() async {
    try {
      loading.value = true;
      error.value = '';

      // Add test credits
      final testCredits = [
        Credit(
          id: 1,
          name: 'Ипотека на квартиру',
          bankName: 'Сбербанк',
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          initialAmount: 5000000,
          currentBalance: 4500000,
          monthlyPayment: 45000,
          interestRate: 7.5,
          nextPaymentDate: DateTime.now().add(const Duration(days: 15)),
          status: CreditStatus.active,
          type: CreditType.mortgage,
        ),
        Credit(
          id: 2,
          name: 'Потребительский кредит',
          bankName: 'Тинькофф',
          createdAt: DateTime.now().subtract(const Duration(days: 180)),
          initialAmount: 300000,
          currentBalance: 150000,
          monthlyPayment: 15000,
          interestRate: 12.9,
          nextPaymentDate: DateTime.now().add(const Duration(days: 5)),
          status: CreditStatus.active,
          type: CreditType.consumer,
        ),
        Credit(
          id: 3,
          name: 'Микрозайм',
          bankName: 'Займер',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          initialAmount: 50000,
          currentBalance: 50000,
          monthlyPayment: 5000,
          interestRate: 1.5,
          nextPaymentDate: DateTime.now().add(const Duration(days: 2)),
          status: CreditStatus.active,
          type: CreditType.microloan,
        ),
      ];

      for (final credit in testCredits) {
        await _creditRepository.addCredit(credit);
      }

      await loadCredits();

      Get.snackbar(
        'Успешно',
        'Добавлены тестовые данные',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Ошибка добавления тестовых данных: $e';
      print('Error adding test data: $e');
    } finally {
      loading.value = false;
    }
  }
}
