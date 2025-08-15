import 'package:get/get.dart';
import '../../data/repositories/tag_repository.dart';
import '../../data/models/tag.dart';

class TagsController extends GetxController {
  final TagRepository _tagRepository = TagRepository();
  
  // Observable lists
  final RxList<Tag> tags = <Tag>[].obs;
  final RxList<Tag> filteredTags = <Tag>[].obs;
  final RxList<Tag> selectedTags = <Tag>[].obs;
  
  // Observable values
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'all'.obs;
  final RxString errorMessage = ''.obs;
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt pageSize = 20.obs;
  final RxBool hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _tagRepository.initialize();
      await loadTags();
    } catch (e) {
      errorMessage.value = 'Ошибка инициализации: $e';
    }
  }

  // Load all tags
  Future<void> loadTags() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final allTags = await _tagRepository.getAllTags();
      tags.value = allTags;
      filteredTags.value = allTags;
      
      _applyFilters();
    } catch (e) {
      errorMessage.value = 'Ошибка загрузки меток: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Apply filters and search
  void _applyFilters() {
    var filtered = tags.toList();
    
    // Apply category filter
    if (selectedCategory.value != 'all') {
      filtered = filtered.where((tag) => tag.category == selectedCategory.value).toList();
    }
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((tag) => 
        tag.name.toLowerCase().contains(query) ||
        tag.category.toLowerCase().contains(query)
      ).toList();
    }
    
    filteredTags.value = filtered;
  }

  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  // Set category filter
  void setCategoryFilter(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  // Clear filters
  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = 'all';
    _applyFilters();
  }

  // Add new tag
  Future<bool> addTag(Tag tag) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _tagRepository.addTag(tag);
      await loadTags();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка добавления метки: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update tag
  Future<bool> updateTag(String id, Tag tag) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _tagRepository.updateTag(id, tag);
      await loadTags();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка обновления метки: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete tag
  Future<bool> deleteTag(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _tagRepository.deleteTag(id);
      await loadTags();
      
      return true;
    } catch (e) {
      errorMessage.value = 'Ошибка удаления метки: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get tag by name
  Future<Tag?> getTagByName(String name) async {
    try {
      return await _tagRepository.getTagByName(name);
    } catch (e) {
      errorMessage.value = 'Ошибка поиска метки: $e';
      return null;
    }
  }

  // Get tags by category
  Future<List<Tag>> getTagsByCategory(String category) async {
    try {
      return await _tagRepository.getTagsByCategory(category);
    } catch (e) {
      errorMessage.value = 'Ошибка загрузки меток по категории: $e';
      return [];
    }
  }

  // Get default tags
  Future<List<Tag>> getDefaultTags() async {
    try {
      return await _tagRepository.getDefaultTags();
    } catch (e) {
      errorMessage.value = 'Ошибка загрузки стандартных меток: $e';
      return [];
    }
  }

  // Get custom tags
  Future<List<Tag>> getCustomTags() async {
    try {
      return await _tagRepository.getCustomTags();
    } catch (e) {
      errorMessage.value = 'Ошибка загрузки пользовательских меток: $e';
      return [];
    }
  }

  // Search tags
  Future<List<Tag>> searchTags(String query) async {
    try {
      return await _tagRepository.searchTags(query);
    } catch (e) {
      errorMessage.value = 'Ошибка поиска меток: $e';
      return [];
    }
  }

  // Get tag statistics
  Future<Map<String, int>> getTagStatistics() async {
    try {
      return await _tagRepository.getTagStatistics();
    } catch (e) {
      errorMessage.value = 'Ошибка загрузки статистики меток: $e';
      return {};
    }
  }

  // Toggle tag selection
  void toggleTagSelection(Tag tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  // Clear selected tags
  void clearSelectedTags() {
    selectedTags.clear();
  }

  // Get selected tag names
  List<String> get selectedTagNames => selectedTags.map((tag) => tag.name).toList();

  // Get category display name
  String getCategoryDisplayName(String category) {
    return TagRepository.getCategoryDisplayName(category);
  }

  // Get category icon
  String getCategoryIcon(String category) {
    return TagRepository.getCategoryIcon(category);
  }

  // Get category color
  String getCategoryColor(String category) {
    return TagRepository.getCategoryColor(category);
  }

  // Get available categories
  List<String> get availableCategories => TagRepository.availableCategories;

  // Get filtered categories (with "all" option)
  List<String> get filteredCategories {
    final categories = ['all', ...availableCategories];
    return categories;
  }

  // Get category filter display name
  String getCategoryFilterDisplayName() {
    if (selectedCategory.value == 'all') {
      return 'Все категории';
    }
    return getCategoryDisplayName(selectedCategory.value);
  }

  // Refresh data
  Future<void> refresh() async {
    await loadTags();
  }

  // Load next page (for pagination)
  Future<void> loadNextPage() async {
    if (!hasMoreData.value || isLoading.value) return;
    
    currentPage.value++;
    // Implement pagination logic here if needed
  }

  // Get tag by ID
  Future<Tag?> getTagById(String id) async {
    try {
      return await _tagRepository.getTagById(id);
    } catch (e) {
      errorMessage.value = 'Ошибка загрузки метки: $e';
      return null;
    }
  }
}
