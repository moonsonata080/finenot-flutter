import 'package:get/get.dart';
import '../../data/repositories/org_repository.dart';
import '../../data/models/org.dart';

class OrgPickerController extends GetxController {
  final OrgRepository _orgRepo = OrgRepository();

  // Observable variables
  final RxList<Org> organizations = <Org>[].obs;
  final RxList<Org> filteredOrgs = <Org>[].obs;
  
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSearching = false.obs;
  final RxBool isUpdating = false.obs;

  // Filter and search
  final RxString searchQuery = ''.obs;
  final RxString selectedType = 'all'.obs;
  final RxString selectedSort = 'name'.obs;

  // Pagination
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxInt pageSize = 20.obs;
  final RxBool hasMoreData = true.obs;

  // Statistics
  final RxInt totalOrgs = 0.obs;
  final RxInt banksCount = 0.obs;
  final RxInt mfosCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrganizations();
  }

  // Load all organizations
  Future<void> loadOrganizations() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _orgRepo.initialize();
      final allOrgs = await _orgRepo.getAllOrgs();
      organizations.value = allOrgs;
      
      _applyFilters();
      await _loadStatistics();
      
    } catch (e) {
      errorMessage.value = 'Ошибка загрузки организаций: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Apply filters to organizations
  void _applyFilters() {
    var filteredOrgsList = organizations.where((org) {
      // Type filter
      if (selectedType.value != 'all' && org.type != selectedType.value) {
        return false;
      }

      // Search query filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!org.name.toLowerCase().contains(query) &&
            !(org.brand != null && org.brand!.toLowerCase().contains(query)) &&
            !(org.bic != null && org.bic!.contains(query)) &&
            !(org.ogrn != null && org.ogrn!.contains(query))) {
          return false;
        }
      }

      return true;
    }).toList();

    // Apply sorting
    _sortOrganizations(filteredOrgsList);

    // Apply pagination
    final startIndex = currentPage.value * pageSize.value;
    final endIndex = startIndex + pageSize.value;
    
    if (startIndex < filteredOrgsList.length) {
      filteredOrgs.value = filteredOrgsList.sublist(
        startIndex,
        endIndex > filteredOrgsList.length ? filteredOrgsList.length : endIndex,
      );
      hasMoreData.value = endIndex < filteredOrgsList.length;
    } else {
      filteredOrgs.value = [];
      hasMoreData.value = false;
    }

    totalPages.value = (filteredOrgsList.length / pageSize.value).ceil();
  }

  // Sort organizations
  void _sortOrganizations(List<Org> orgsList) {
    switch (selectedSort.value) {
      case 'name':
        orgsList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'brand':
        orgsList.sort((a, b) {
          final brandA = a.brand ?? a.name;
          final brandB = b.brand ?? b.name;
          return brandA.compareTo(brandB);
        });
        break;
      case 'type':
        orgsList.sort((a, b) => a.type.compareTo(b.type));
        break;
      case 'popular':
        // For now, just sort by name. In a real app, you'd sort by usage count
        orgsList.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
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

  // Set sort order
  void setSortOrder(String sort) {
    selectedSort.value = sort;
    currentPage.value = 0;
    _applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    selectedType.value = 'all';
    selectedSort.value = 'name';
    currentPage.value = 0;
    _applyFilters();
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (!hasMoreData.value || isLoading.value) return;

    currentPage.value++;
    _applyFilters();
  }

  // Refresh organizations
  Future<void> refresh() async {
    currentPage.value = 0;
    await loadOrganizations();
  }

  // Search organizations
  Future<void> searchOrganizations(String query) async {
    try {
      isSearching.value = true;
      errorMessage.value = '';

      if (query.isEmpty) {
        filteredOrgs.value = organizations;
      } else {
        final searchResults = await _orgRepo.searchOrgs(query);
        filteredOrgs.value = searchResults;
      }
    } catch (e) {
      errorMessage.value = 'Ошибка поиска: $e';
    } finally {
      isSearching.value = false;
    }
  }

  // Get organization by ID
  Future<Org?> getOrgById(String id) async {
    try {
      return await _orgRepo.getOrgById(id);
    } catch (e) {
      errorMessage.value = 'Ошибка получения организации: $e';
      return null;
    }
  }

  // Get organization by BIC
  Future<Org?> getOrgByBIC(String bic) async {
    try {
      return await _orgRepo.getOrgByBIC(bic);
    } catch (e) {
      errorMessage.value = 'Ошибка поиска по БИК: $e';
      return null;
    }
  }

  // Get organization by OGRN
  Future<Org?> getOrgByOGRN(String ogrn) async {
    try {
      return await _orgRepo.getOrgByOGRN(ogrn);
    } catch (e) {
      errorMessage.value = 'Ошибка поиска по ОГРН: $e';
      return null;
    }
  }

  // Load statistics
  Future<void> _loadStatistics() async {
    try {
      final stats = await _orgRepo.getOrgStatistics();
      
      totalOrgs.value = stats['totalOrgs'] ?? 0;
      banksCount.value = stats['banks'] ?? 0;
      mfosCount.value = stats['mfos'] ?? 0;
    } catch (e) {
      print('Error loading organization statistics: $e');
    }
  }

  // Get organizations by type
  List<Org> getOrgsByType(String type) {
    return organizations.where((org) => org.type == type).toList();
  }

  // Get banks only
  List<Org> getBanks() {
    return getOrgsByType('bank');
  }

  // Get MFOs only
  List<Org> getMFOs() {
    return getOrgsByType('mfo');
  }

  // Get popular organizations
  Future<List<Org>> getPopularOrgs({int limit = 10}) async {
    try {
      return await _orgRepo.getPopularOrgs(limit: limit);
    } catch (e) {
      print('Error loading popular organizations: $e');
      return [];
    }
  }

  // Get organizations with pagination
  Future<List<Org>> getOrgsWithPagination({
    int page = 0,
    int pageSize = 20,
    String? type,
    String? searchQuery,
  }) async {
    try {
      return await _orgRepo.getOrgsWithPagination(
        page: page,
        pageSize: pageSize,
        type: type,
        searchQuery: searchQuery,
      );
    } catch (e) {
      print('Error loading organizations with pagination: $e');
      return [];
    }
  }

  // Get organization type display name
  String getOrgTypeDisplayName(String type) {
    switch (type) {
      case 'bank':
        return 'Банк';
      case 'mfo':
        return 'МФО';
      default:
        return type;
    }
  }

  // Get organization type color
  String getOrgTypeColor(String type) {
    switch (type) {
      case 'bank':
        return '#2196F3'; // Blue
      case 'mfo':
        return '#FF9800'; // Orange
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Get sort order display name
  String getSortOrderDisplayName(String sort) {
    switch (sort) {
      case 'name':
        return 'По названию';
      case 'brand':
        return 'По бренду';
      case 'type':
        return 'По типу';
      case 'popular':
        return 'По популярности';
      default:
        return sort;
    }
  }

  // Get type filter display name
  String getTypeFilterDisplayName(String type) {
    switch (type) {
      case 'all':
        return 'Все';
      case 'bank':
        return 'Банки';
      case 'mfo':
        return 'МФО';
      default:
        return type;
    }
  }

  // Check if organization has BIC
  bool hasBIC(Org org) => org.bic != null && org.bic!.isNotEmpty;

  // Check if organization has OGRN
  bool hasOGRN(Org org) => org.ogrn != null && org.ogrn!.isNotEmpty;

  // Get organization display name
  String getOrgDisplayName(Org org) {
    return org.displayName;
  }

  // Get organization details
  Map<String, String> getOrgDetails(Org org) {
    final details = <String, String>{};
    
    if (hasBIC(org)) {
      details['БИК'] = org.bic!;
    }
    
    if (hasOGRN(org)) {
      details['ОГРН'] = org.ogrn!;
    }
    
    details['Тип'] = getOrgTypeDisplayName(org.type);
    
    return details;
  }

  // Get organizations summary
  Map<String, dynamic> getOrganizationsSummary() {
    return {
      'totalOrgs': totalOrgs.value,
      'banksCount': banksCount.value,
      'mfosCount': mfosCount.value,
      'filteredCount': filteredOrgs.length,
      'currentPage': currentPage.value,
      'totalPages': totalPages.value,
      'hasMoreData': hasMoreData.value,
      'searchQuery': searchQuery.value,
      'selectedType': selectedType.value,
      'selectedSort': selectedSort.value,
    };
  }

  // Export organizations
  Future<List<Map<String, dynamic>>?> exportOrganizations() async {
    try {
      return await _orgRepo.exportOrgs();
    } catch (e) {
      errorMessage.value = 'Ошибка экспорта организаций: $e';
      return null;
    }
  }

  // Import organizations
  Future<bool> importOrganizations(List<Map<String, dynamic>> orgsData) async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      await _orgRepo.importOrgs(orgsData);
      await loadOrganizations();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка импорта организаций: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Clear all organizations
  Future<bool> clearAllOrganizations() async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      await _orgRepo.clearAllOrgs();
      await loadOrganizations();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка очистки организаций: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Reinitialize with default data
  Future<bool> reinitializeOrganizations() async {
    try {
      isUpdating.value = true;
      errorMessage.value = '';

      await _orgRepo.reinitialize();
      await loadOrganizations();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка переинициализации: $e';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Check if data is loaded
  bool get isDataLoaded => !isLoading.value && errorMessage.value.isEmpty;

  // Get error message
  String get error => errorMessage.value;

  // Check if there are any errors
  bool get hasError => errorMessage.value.isNotEmpty;

  // Check if any operation is in progress
  bool get isOperationInProgress => isLoading.value || isSearching.value || isUpdating.value;
}
