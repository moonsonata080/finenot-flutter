import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../data/models/credit.dart';
import '../../data/models/payment.dart';
import '../../data/models/settings.dart';
import '../../data/models/org.dart';
import 'isar_provider.dart';

class BackupService {
  static const String _backupFileName = 'finenot_backup';

  // Export data to JSON
  static Future<String> exportData() async {
    final isar = IsarProvider.isar;
    
    // Get all data
    final credits = await isar.credits.where().findAll();
    final payments = await isar.payments.where().findAll();
    final settings = await isar.settingss.where().findAll();
    final orgs = await isar.orgs.where().findAll();

    // Create backup object
    final backup = {
      'version': '1.0.0',
      'exportDate': DateTime.now().toIso8601String(),
      'credits': credits.map((c) => _creditToJson(c)).toList(),
      'payments': payments.map((p) => _paymentToJson(p)).toList(),
      'settings': settings.isNotEmpty ? _settingsToJson(settings.first) : null,
      'orgs': orgs.map((o) => _orgToJson(o)).toList(),
    };

    return jsonEncode(backup);
  }

  // Import data from JSON
  static Future<bool> importData(String jsonData) async {
    try {
      final backup = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // Validate backup format
      if (!_validateBackup(backup)) {
        throw Exception('Invalid backup format');
      }

      final isar = IsarProvider.isar;
      
      await isar.writeTxn(() async {
        // Clear existing data
        await isar.clear();
        
        // Import orgs first (they are referenced by credits)
        if (backup['orgs'] != null) {
          final orgs = (backup['orgs'] as List)
              .map((o) => _orgFromJson(o as Map<String, dynamic>))
              .toList();
          await isar.orgs.putAll(orgs);
        }
        
        // Import credits
        if (backup['credits'] != null) {
          final credits = (backup['credits'] as List)
              .map((c) => _creditFromJson(c as Map<String, dynamic>))
              .toList();
          await isar.credits.putAll(credits);
        }
        
        // Import payments
        if (backup['payments'] != null) {
          final payments = (backup['payments'] as List)
              .map((p) => _paymentFromJson(p as Map<String, dynamic>))
              .toList();
          await isar.payments.putAll(payments);
        }
        
        // Import settings
        if (backup['settings'] != null) {
          final settings = _settingsFromJson(backup['settings'] as Map<String, dynamic>);
          await isar.settingss.put(settings);
        }
      });

      return true;
    } catch (e) {
      print('Import error: $e');
      return false;
    }
  }

  // Save backup to file and share
  static Future<void> saveAndShareBackup() async {
    final jsonData = await exportData();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
    final fileName = '${_backupFileName}_$timestamp.json';
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    
    await file.writeAsString(jsonData);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'FinEnot backup - $timestamp',
    );
  }

  // Load backup from file
  static Future<String?> loadBackupFromFile() async {
    // This would typically use file_picker to select a file
    // For now, return null as this needs UI integration
    return null;
  }

  // Validation helpers
  static bool _validateBackup(Map<String, dynamic> backup) {
    return backup.containsKey('version') && 
           backup.containsKey('exportDate') &&
           backup.containsKey('credits') &&
           backup.containsKey('payments');
  }

  // JSON conversion helpers
  static Map<String, dynamic> _creditToJson(Credit credit) {
    return {
      'id': credit.id,
      'orgId': credit.orgId,
      'name': credit.name,
      'type': credit.type,
      'initialAmount': credit.initialAmount,
      'currentBalance': credit.currentBalance,
      'monthlyPayment': credit.monthlyPayment,
      'interestRate': credit.interestRate,
      'nextPaymentDate': credit.nextPaymentDate.toIso8601String(),
      'status': credit.status,
      'createdAt': credit.createdAt.toIso8601String(),
    };
  }

  static Credit _creditFromJson(Map<String, dynamic> json) {
    return Credit(
      id: json['id'] as Id,
      orgId: json['orgId'] as int?,
      name: json['name'] as String,
      type: json['type'] as String,
      initialAmount: json['initialAmount'] as double,
      currentBalance: json['currentBalance'] as double,
      monthlyPayment: json['monthlyPayment'] as double,
      interestRate: json['interestRate'] as double,
      nextPaymentDate: DateTime.parse(json['nextPaymentDate'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static Map<String, dynamic> _paymentToJson(Payment payment) {
    return {
      'id': payment.id,
      'creditId': payment.creditId,
      'amount': payment.amount,
      'dueDate': payment.dueDate.toIso8601String(),
      'paidDate': payment.paidDate?.toIso8601String(),
      'status': payment.status,
      'createdAt': payment.createdAt.toIso8601String(),
    };
  }

  static Payment _paymentFromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as Id,
      creditId: json['creditId'] as int,
      amount: json['amount'] as double,
      dueDate: DateTime.parse(json['dueDate'] as String),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate'] as String) : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static Map<String, dynamic> _settingsToJson(Settings settings) {
    return {
      'id': settings.id,
      'themeMode': settings.themeMode,
      'notifyAheadHours': settings.notifyAheadHours,
      'lockEnabled': settings.lockEnabled,
      'lockType': settings.lockType,
      'monthlyIncome': settings.monthlyIncome,
    };
  }

  static Settings _settingsFromJson(Map<String, dynamic> json) {
    return Settings(
      themeMode: json['themeMode'] as String,
      notifyAheadHours: json['notifyAheadHours'] as int,
      lockEnabled: json['lockEnabled'] as bool,
      lockType: json['lockType'] as String,
      monthlyIncome: json['monthlyIncome'] as double?,
    );
  }

  static Map<String, dynamic> _orgToJson(Org org) {
    return {
      'id': org.id,
      'name': org.name,
      'type': org.type,
      'bic': org.bic,
      'ogrn': org.ogrn,
      'brand': org.brand,
      'searchIndex': org.searchIndex,
    };
  }

  static Org _orgFromJson(Map<String, dynamic> json) {
    return Org(
      id: json['id'] as Id,
      name: json['name'] as String,
      type: json['type'] as String,
      bic: json['bic'] as String?,
      ogrn: json['ogrn'] as String?,
      brand: json['brand'] as String?,
      searchIndex: json['searchIndex'] as String,
    );
  }
}
