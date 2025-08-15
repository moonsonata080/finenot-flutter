import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../models/org.dart';
import '../../core/services/hive_provider.dart';

class OrgRepository {
  final Box<Org> _orgsBox = HiveProvider.orgsBox;
  static bool _initialized = false;

  // Initialize with default organizations from JSON
  Future<void> initialize() async {
    if (_initialized) return;

    // Check if organizations already exist
    if (_orgsBox.isEmpty) {
      await _loadDefaultOrganizations();
    }

    _initialized = true;
  }

  // Load default organizations from JSON file
  Future<void> _loadDefaultOrganizations() async {
    try {
      // Load from assets/data/orgs_ru.json
      final jsonString = await _loadJsonFromAssets();
      final List<dynamic> jsonList = json.decode(jsonString);
      
      for (final jsonOrg in jsonList) {
        final org = Org(
          name: jsonOrg['name'] ?? '',
          type: jsonOrg['type'] ?? 'bank',
          bic: jsonOrg['bic'],
          ogrn: jsonOrg['ogrn'],
          brand: jsonOrg['brand'],
          searchIndex: _createSearchIndex(jsonOrg['name'] ?? ''),
        );
        
        await _orgsBox.add(org);
      }
    } catch (e) {
      print('Error loading default organizations: $e');
      // Create some default organizations if JSON loading fails
      await _createDefaultOrganizations();
    }
  }

  // Load JSON from assets
  Future<String> _loadJsonFromAssets() async {
    // This would normally load from assets, but for now we'll create inline data
    return '''
    [
      {"id": 1, "type": "bank", "name": "Сбербанк России", "brand": "Сбер", "bic": "044525225", "ogrn": "1027700132195"},
      {"id": 2, "type": "bank", "name": "ВТБ", "brand": "ВТБ", "bic": "044525187", "ogrn": "1027739609391"},
      {"id": 3, "type": "bank", "name": "Газпромбанк", "brand": "Газпромбанк", "bic": "044525823", "ogrn": "1027700167110"},
      {"id": 4, "type": "bank", "name": "Россельхозбанк", "brand": "РСХБ", "bic": "044525745", "ogrn": "1027700342890"},
      {"id": 5, "type": "bank", "name": "Альфа-Банк", "brand": "Альфа-Банк", "bic": "044525593", "ogrn": "1027700067328"},
      {"id": 1001, "type": "mfo", "name": "Екапуста", "brand": "Екапуста", "ogrn": "1137847266575"},
      {"id": 1002, "type": "mfo", "name": "Займер", "brand": "Займер", "ogrn": "1137746395713"}
    ]
    ''';
  }

  // Create default organizations if JSON loading fails
  Future<void> _createDefaultOrganizations() async {
    final defaultOrgs = [
      Org(
        name: 'Сбербанк России',
        type: 'bank',
        bic: '044525225',
        ogrn: '1027700132195',
        brand: 'Сбер',
        searchIndex: _createSearchIndex('Сбербанк России'),
      ),
      Org(
        name: 'ВТБ',
        type: 'bank',
        bic: '044525187',
        ogrn: '1027739609391',
        brand: 'ВТБ',
        searchIndex: _createSearchIndex('ВТБ'),
      ),
      Org(
        name: 'Екапуста',
        type: 'mfo',
        ogrn: '1137847266575',
        brand: 'Екапуста',
        searchIndex: _createSearchIndex('Екапуста'),
      ),
    ];

    for (final org in defaultOrgs) {
      await _orgsBox.add(org);
    }
  }

  // Create search index for fast searching
  String _createSearchIndex(String name) {
    return name
        .toLowerCase()
        .replaceAllMapped(RegExp(r'[а-я]'), (match) {
          // Simple Cyrillic to Latin transliteration
          final cyrillicToLatin = {
            'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'e',
            'ж': 'zh', 'з': 'z', 'и': 'i', 'й': 'y', 'к': 'k', 'л': 'l', 'м': 'm',
            'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u',
            'ф': 'f', 'х': 'h', 'ц': 'ts', 'ч': 'ch', 'ш': 'sh', 'щ': 'sch',
            'ъ': '', 'ы': 'y', 'ь': '', 'э': 'e', 'ю': 'yu', 'я': 'ya',
          };
          final char = match.group(0) ?? '';
          return cyrillicToLatin[char] ?? char;
        })
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  // Get all organizations
  Future<List<Org>> getAllOrgs() async {
    await initialize();
    return _orgsBox.values.toList();
  }

  // Get organizations by type
  Future<List<Org>> getOrgsByType(String type) async {
    await initialize();
    return _orgsBox.values.where((org) => org.type == type).toList();
  }

  // Get banks only
  Future<List<Org>> getBanks() async {
    return await getOrgsByType('bank');
  }

  // Get MFOs only
  Future<List<Org>> getMFOs() async {
    return await getOrgsByType('mfo');
  }

  // Search organizations by name or brand
  Future<List<Org>> searchOrgs(String query) async {
    await initialize();
    if (query.isEmpty) return await getAllOrgs();

    final normalizedQuery = _createSearchIndex(query);
    return _orgsBox.values
        .where((org) => 
            org.searchIndex.contains(normalizedQuery) ||
            org.name.toLowerCase().contains(query.toLowerCase()) ||
            (org.brand != null && org.brand!.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }

  // Get organization by ID
  Future<Org?> getOrgById(String id) async {
    await initialize();
    return _orgsBox.get(id);
  }

  // Get organization by BIC
  Future<Org?> getOrgByBIC(String bic) async {
    await initialize();
    try {
      return _orgsBox.values.firstWhere((org) => org.bic == bic);
    } catch (e) {
      return null;
    }
  }

  // Get organization by OGRN
  Future<Org?> getOrgByOGRN(String ogrn) async {
    await initialize();
    try {
      return _orgsBox.values.firstWhere((org) => org.ogrn == ogrn);
    } catch (e) {
      return null;
    }
  }

  // Add new organization
  Future<String> addOrg(Org org) async {
    await initialize();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _orgsBox.put(id, org);
    return id;
  }

  // Update organization
  Future<void> updateOrg(String id, Org org) async {
    await initialize();
    await _orgsBox.put(id, org);
  }

  // Delete organization
  Future<void> deleteOrg(String id) async {
    await initialize();
    await _orgsBox.delete(id);
  }

  // Get popular organizations (most used)
  Future<List<Org>> getPopularOrgs({int limit = 10}) async {
    await initialize();
    final allOrgs = await getAllOrgs();
    
    // For now, return first N organizations
    // In a real app, you'd track usage and return most used
    return allOrgs.take(limit).toList();
  }

  // Get organizations statistics
  Future<Map<String, dynamic>> getOrgStatistics() async {
    await initialize();
    final allOrgs = await getAllOrgs();
    
    final totalOrgs = allOrgs.length;
    final banks = allOrgs.where((org) => org.type == 'bank').length;
    final mfos = allOrgs.where((org) => org.type == 'mfo').length;
    
    return {
      'totalOrgs': totalOrgs,
      'banks': banks,
      'mfos': mfos,
      'banksPercentage': totalOrgs > 0 ? (banks / totalOrgs) * 100 : 0.0,
      'mfosPercentage': totalOrgs > 0 ? (mfos / totalOrgs) * 100 : 0.0,
    };
  }

  // Export organizations as JSON
  Future<List<Map<String, dynamic>>> exportOrgs() async {
    await initialize();
    final allOrgs = await getAllOrgs();
    
    return allOrgs.map((org) => {
      'name': org.name,
      'type': org.type,
      'bic': org.bic,
      'ogrn': org.ogrn,
      'brand': org.brand,
      'searchIndex': org.searchIndex,
    }).toList();
  }

  // Import organizations from JSON
  Future<void> importOrgs(List<Map<String, dynamic>> orgsData) async {
    await initialize();
    
    for (final orgData in orgsData) {
      final org = Org(
        name: orgData['name'] ?? '',
        type: orgData['type'] ?? 'bank',
        bic: orgData['bic'],
        ogrn: orgData['ogrn'],
        brand: orgData['brand'],
        searchIndex: _createSearchIndex(orgData['name'] ?? ''),
      );
      
      await _orgsBox.add(org);
    }
  }

  // Clear all organizations
  Future<void> clearAllOrgs() async {
    await _orgsBox.clear();
    _initialized = false;
  }

  // Reinitialize with default data
  Future<void> reinitialize() async {
    await clearAllOrgs();
    await initialize();
  }

  // Get organizations with pagination
  Future<List<Org>> getOrgsWithPagination({
    int page = 0,
    int pageSize = 20,
    String? type,
    String? searchQuery,
  }) async {
    await initialize();
    
    List<Org> filteredOrgs;
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredOrgs = await searchOrgs(searchQuery);
    } else if (type != null) {
      filteredOrgs = await getOrgsByType(type);
    } else {
      filteredOrgs = await getAllOrgs();
    }
    
    final startIndex = page * pageSize;
    final endIndex = startIndex + pageSize;
    
    if (startIndex >= filteredOrgs.length) {
      return [];
    }
    
    return filteredOrgs.sublist(
      startIndex,
      endIndex > filteredOrgs.length ? filteredOrgs.length : endIndex,
    );
  }
}
