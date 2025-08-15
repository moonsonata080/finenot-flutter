import 'package:get/get.dart';
import '../../data/repositories/credit_repository.dart';
import '../../data/repositories/org_repository.dart';
import '../../data/models/credit.dart';
import '../../data/models/org.dart';

class CreditsController extends GetxController {
  final CreditRepository _creditRepo = CreditRepository();
  final OrgRepository _orgRepo = OrgRepository();

  // Observable variables
  final RxList<Credit> credits = <Credit>[].obs;
  final RxList<Org> organizations = <Org>[].obs;
  
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;

  // Filter and search
  final RxString searchQuery = ''.obs;
  final RxString selectedType = 'all'.obs;
  final RxString selectedStatus = 'all'.obs;
  final RxString selectedOrg = 'all'.obs;

  // Pagination
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxInt pageSize = 20.obs;
  final RxBool hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadCredits();
    loadOrganizations();
  }

  // Load all credits
  Future<void> loadCredits() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final allCredits = await _creditRepo.getAllCredits();
      credits.value = allCredits;
      
      _applyFilters();
      
    } catch (e) {
      errorMessage.value = 'Ошибка загрузки кредитов: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Load organizations
  Future<void> loadOrganizations() async {
    try {
      await _orgRepo.initialize();
      organizations.value = await _orgRepo.getAllOrgs();
    } catch (e) {
      print('Error loading organizations: $e');
    }
  }

  // Apply filters to credits
  void _applyFilters() {
    var filteredCredits = credits.where((credit) {
      // Search query filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!credit.name.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Type filter
      if (selectedType.value != 'all' && credit.type != selectedType.value) {
        return false;
      }

      // Status filter
      if (selectedStatus.value != 'all' && credit.status != selectedStatus.value) {
        return false;
      }

      // Organization filter
      if (selectedOrg.value != 'all') {
        final orgId = int.tryParse(selectedOrg.value);
        if (orgId != null && credit.orgId != orgId) {
          return false;
        }
      }

      return true;
    }).toList();

    // Apply pagination
    final startIndex = currentPage.value * pageSize.value;
    final endIndex = startIndex + pageSize.value;
    
    if (startIndex < filteredCredits.length) {
      credits.value = filteredCredits.sublist(
        startIndex,
        endIndex > filteredCredits.length ? filteredCredits.length : endIndex,
      );
      hasMoreData.value = endIndex < filteredCredits.length;
    } else {
      credits.value = [];
      hasMoreData.value = false;
    }

    totalPages.value = (filteredCredits.length / pageSize.value).ceil();
  }

  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
    currentPage.value = 0;
    _applyFilters();
  }

  // Set type filter
  void setTypeFilter(String type) {
    selectedType.value = type;
    currentPage.value = 0;
    _applyFilters();
  }

  // Set status filter
  void setStatusFilter(String status) {
    selectedStatus.value = status;
    currentPage.value = 0;
    _applyFilters();
  }

  // Set organization filter
  void setOrgFilter(String orgId) {
    selectedOrg.value = orgId;
    currentPage.value = 0;
    _applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    selectedType.value = 'all';
    selectedStatus.value = 'all';
    selectedOrg.value = 'all';
    currentPage.value = 0;
    _applyFilters();
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (!hasMoreData.value || isLoading.value) return;

    currentPage.value++;
    _applyFilters();
  }

  // Refresh credits
  Future<void> refresh() async {
    currentPage.value = 0;
    await loadCredits();
  }

  // Create new credit
  Future<bool> createCredit(Credit credit) async {
    try {
      isCreating.value = true;
      errorMessage.value = '';

      final creditId = await _creditRepo.addCredit(credit);
      
      // Reload credits to show the new one
      await loadCredits();
      
      return creditId.isNotEmpty;
    } catch (e) {
      errorMessage.value = 'Ошибка создания кредита: $e';
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  // Update credit
  Future<bool> updateCredit(String id, Credit credit) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      await _creditRepo.updateCredit(id, credit);
      
      // Reload credits to show the updated one
      await loadCredits();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка обновления кредита: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Delete credit
  Future<bool> deleteCredit(String id) async {
    try {
      isDeleting.value = true;
      errorMessage.value = '';

      await _creditRepo.deleteCredit(id);
      
      // Reload credits to remove the deleted one
      await loadCredits();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка удаления кредита: $e';
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  // Get credit by ID
  Future<Credit?> getCreditById(String id) async {
    try {
      return await _creditRepo.getCreditById(id);
    } catch (e) {
      errorMessage.value = 'Ошибка получения кредита: $e';
      return null;
    }
  }

  // Get active credits
  List<Credit> getActiveCredits() {
    return credits.where((credit) => credit.status == 'active').toList();
  }

  // Get overdue credits
  List<Credit> getOverdueCredits() {
    return credits.where((credit) => credit.status == 'overdue').toList();
  }

  // Get closed credits
  List<Credit> getClosedCredits() {
    return credits.where((credit) => credit.status == 'closed').toList();
  }

  // Get credits by type
  List<Credit> getCreditsByType(String type) {
    return credits.where((credit) => credit.type == type).toList();
  }

  // Get credits by organization
  List<Credit> getCreditsByOrg(int orgId) {
    return credits.where((credit) => credit.orgId == orgId).toList();
  }

  // Get total debt
  double getTotalDebt() {
    return credits
        .where((credit) => credit.status == 'active')
        .fold(0.0, (sum, credit) => sum + credit.currentBalance);
  }

  // Get total monthly payments
  double getTotalMonthlyPayments() {
    return credits
        .where((credit) => credit.status == 'active')
        .fold(0.0, (sum, credit) => sum + credit.monthlyPayment);
  }

  // Get credits count by status
  Map<String, int> getCreditsCountByStatus() {
    final counts = <String, int>{};
    for (final credit in credits) {
      counts[credit.status] = (counts[credit.status] ?? 0) + 1;
    }
    return counts;
  }

  // Get credits count by type
  Map<String, int> getCreditsCountByType() {
    final counts = <String, int>{};
    for (final credit in credits) {
      counts[credit.type] = (counts[credit.type] ?? 0) + 1;
    }
    return counts;
  }

  // Get organization name by ID
  String getOrgNameById(int? orgId) {
    if (orgId == null) return 'Не указано';
    
    try {
      final org = organizations.firstWhere((org) => org.key == orgId.toString());
      return org.displayName;
    } catch (e) {
      return 'Неизвестно';
    }
  }

  // Get credit type display name
  String getCreditTypeDisplayName(String type) {
    switch (type) {
      case 'consumer':
        return 'Потребительский';
      case 'mortgage':
        return 'Ипотека';
      case 'micro':
        return 'Микрозайм';
      case 'card':
        return 'Кредитная карта';
      default:
        return type;
    }
  }

  // Get credit status display name
  String getCreditStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return 'Активный';
      case 'closed':
        return 'Закрыт';
      case 'overdue':
        return 'Просрочен';
      default:
        return status;
    }
  }

  // Get credit status color
  String getCreditStatusColor(String status) {
    switch (status) {
      case 'active':
        return '#4CAF50'; // Green
      case 'closed':
        return '#9E9E9E'; // Grey
      case 'overdue':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Check if credit is overdue
  bool isCreditOverdue(Credit credit) {
    return credit.status == 'active' && 
           credit.nextPaymentDate.isBefore(DateTime.now());
  }

  // Get days until next payment
  int getDaysUntilNextPayment(Credit credit) {
    final now = DateTime.now();
    final nextPayment = credit.nextPaymentDate;
    return nextPayment.difference(now).inDays;
  }

  // Get payment progress percentage
  double getPaymentProgress(Credit credit) {
    if (credit.initialAmount <= 0) return 0.0;
    
    final paidAmount = credit.initialAmount - credit.currentBalance;
    return (paidAmount / credit.initialAmount).clamp(0.0, 1.0);
  }

  // Get credits summary
  Map<String, dynamic> getCreditsSummary() {
    final activeCredits = getActiveCredits();
    final overdueCredits = getOverdueCredits();
    final closedCredits = getClosedCredits();

    return {
      'totalCredits': credits.length,
      'activeCredits': activeCredits.length,
      'overdueCredits': overdueCredits.length,
      'closedCredits': closedCredits.length,
      'totalDebt': getTotalDebt(),
      'totalMonthlyPayments': getTotalMonthlyPayments(),
      'averageInterestRate': activeCredits.isNotEmpty 
          ? activeCredits.fold(0.0, (sum, credit) => sum + credit.interestRate) / activeCredits.length 
          : 0.0,
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
}
