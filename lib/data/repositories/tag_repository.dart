import 'package:hive_flutter/hive_flutter.dart';
import '../models/tag.dart';
import '../../core/services/hive_provider.dart';

class TagRepository {
  final Box<Tag> _tagsBox = HiveProvider.tagsBox;
  static bool _initialized = false;

  // Initialize with default tags
  Future<void> initialize() async {
    if (_initialized) return;

    // Check if tags already exist
    if (_tagsBox.isEmpty) {
      await _loadDefaultTags();
    }

    _initialized = true;
  }

  // Load default tags
  Future<void> _loadDefaultTags() async {
    try {
      for (final tag in Tag.defaultTags) {
        await _tagsBox.add(tag);
      }
    } catch (e) {
      print('Error loading default tags: $e');
    }
  }

  // Get all tags
  Future<List<Tag>> getAllTags() async {
    return _tagsBox.values.toList();
  }

  // Get tags by category
  Future<List<Tag>> getTagsByCategory(String category) async {
    return _tagsBox.values.where((tag) => tag.category == category).toList();
  }

  // Get default tags
  Future<List<Tag>> getDefaultTags() async {
    return _tagsBox.values.where((tag) => tag.isDefault).toList();
  }

  // Get custom tags
  Future<List<Tag>> getCustomTags() async {
    return _tagsBox.values.where((tag) => !tag.isDefault).toList();
  }

  // Get tag by name
  Future<Tag?> getTagByName(String name) async {
    try {
      return _tagsBox.values.firstWhere((tag) => tag.name == name);
    } catch (e) {
      return null;
    }
  }

  // Add new tag
  Future<String> addTag(Tag tag) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _tagsBox.put(id, tag);
    return id;
  }

  // Update tag
  Future<void> updateTag(String id, Tag tag) async {
    await _tagsBox.put(id, tag);
  }

  // Delete tag
  Future<void> deleteTag(String id) async {
    final tag = await getTagById(id);
    if (tag != null && !tag.isDefault) {
      await _tagsBox.delete(id);
    }
  }

  // Get tag by ID
  Future<Tag?> getTagById(String id) async {
    return _tagsBox.get(id);
  }

  // Search tags
  Future<List<Tag>> searchTags(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _tagsBox.values
        .where((tag) => tag.name.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Get tag statistics
  Future<Map<String, int>> getTagStatistics() async {
    final allTags = await getAllTags();
    final statistics = <String, int>{};
    
    for (final tag in allTags) {
      statistics[tag.category] = (statistics[tag.category] ?? 0) + 1;
    }
    
    return statistics;
  }

  // Get available categories
  static List<String> get availableCategories => [
    'personal',
    'business',
    'emergency',
    'government',
    'entertainment',
    'health',
    'education',
    'transport',
    'utilities',
    'other',
  ];

  // Get category display names
  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'personal':
        return 'Личное';
      case 'business':
        return 'Бизнес';
      case 'emergency':
        return 'Срочное';
      case 'government':
        return 'Государственное';
      case 'entertainment':
        return 'Развлечения';
      case 'health':
        return 'Здоровье';
      case 'education':
        return 'Образование';
      case 'transport':
        return 'Транспорт';
      case 'utilities':
        return 'Коммунальные услуги';
      case 'other':
        return 'Другое';
      default:
        return category;
    }
  }

  // Get category icon
  static String getCategoryIcon(String category) {
    switch (category) {
      case 'personal':
        return 'person';
      case 'business':
        return 'business';
      case 'emergency':
        return 'priority_high';
      case 'government':
        return 'account_balance';
      case 'entertainment':
        return 'movie';
      case 'health':
        return 'local_hospital';
      case 'education':
        return 'school';
      case 'transport':
        return 'directions_car';
      case 'utilities':
        return 'home';
      case 'other':
        return 'more_horiz';
      default:
        return 'label';
    }
  }

  // Get category color
  static String getCategoryColor(String category) {
    switch (category) {
      case 'personal':
        return '#4CAF50';
      case 'business':
        return '#FF9800';
      case 'emergency':
        return '#F44336';
      case 'government':
        return '#795548';
      case 'entertainment':
        return '#00BCD4';
      case 'health':
        return '#E91E63';
      case 'education':
        return '#9C27B0';
      case 'transport':
        return '#2196F3';
      case 'utilities':
        return '#607D8B';
      case 'other':
        return '#9E9E9E';
      default:
        return '#757575';
    }
  }
}
