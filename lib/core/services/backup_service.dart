import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/db/isar_provider.dart';
import '../../data/models/credit.dart';
import '../../data/models/payment.dart';
import '../../data/models/settings.dart';
import '../../data/repositories/settings_repository.dart';

class BackupService {
  static const String _backupFileName = 'finenot_backup';

  // Export all data to JSON
  static Future<String> exportData() async {
    final isar = IsarProvider.instance;
    final settingsRepo = SettingsRepository();

    // Get all data
    final credits = await isar.credits.where().findAll();
    final payments = await isar.payments.where().findAll();
    final settings = await settingsRepo.getSettings();

    // Prepare export data
    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'credits': credits.map((c) => c.toJson()).toList(),
      'payments': payments.map((p) => p.toJson()).toList(),
      'settings': settingsRepo.settingsToJson(settings),
    };

    return jsonEncode(exportData);
  }

  // Export to file and share
  static Future<void> exportToFile() async {
    try {
      final jsonData = await exportData();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${_backupFileName}_$timestamp.json';

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');

      // Write data to file
      await file.writeAsString(jsonData);

      // Share file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'FinEnot Backup - $fileName',
      );
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  // Import data from JSON
  static Future<void> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // Validate backup version
      final version = data['version'] as String?;
      if (version == null || !version.startsWith('1.')) {
        throw Exception('Unsupported backup version: $version');
      }

      final isar = IsarProvider.instance;
      final settingsRepo = SettingsRepository();

      await isar.writeTxn(() async {
        // Clear existing data
        await isar.clear();

        // Import credits
        final creditsJson = data['credits'] as List<dynamic>? ?? [];
        final credits = <Credit>[];
        
        for (final creditJson in creditsJson) {
          final credit = Credit.fromJson(creditJson as Map<String, dynamic>);
          await isar.credits.put(credit);
          credits.add(credit);
        }

        // Import payments
        final paymentsJson = data['payments'] as List<dynamic>? ?? [];
        
        for (final paymentJson in paymentsJson) {
          final payment = Payment.fromJson(paymentJson as Map<String, dynamic>);
          await isar.payments.put(payment);
          
          // Link payment to credit if creditId is provided
          final creditId = paymentJson['creditId'] as int?;
          if (creditId != null) {
            final credit = credits.firstWhere(
              (c) => c.id == creditId,
              orElse: () => throw Exception('Credit not found for payment: $creditId'),
            );
            payment.credit.value = credit;
            await payment.credit.save();
          }
        }

        // Import settings
        final settingsJson = data['settings'] as Map<String, dynamic>?;
        if (settingsJson != null) {
          final settings = await settingsRepo.settingsFromJson(settingsJson);
          await isar.settingss.put(settings);
        }
      });
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  // Import from file picker
  static Future<void> importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final jsonData = await file.readAsString();
        await importData(jsonData);
      }
    } catch (e) {
      throw Exception('Failed to import from file: $e');
    }
  }

  // Validate backup file
  static Future<bool> validateBackupFile(String jsonData) {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // Check required fields
      if (!data.containsKey('version') ||
          !data.containsKey('credits') ||
          !data.containsKey('payments') ||
          !data.containsKey('settings')) {
        return false;
      }

      // Validate version
      final version = data['version'] as String;
      if (!version.startsWith('1.')) {
        return false;
      }

      // Validate data types
      final credits = data['credits'] as List<dynamic>?;
      final payments = data['payments'] as List<dynamic>?;
      final settings = data['settings'] as Map<String, dynamic>?;

      if (credits == null || payments == null || settings == null) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get backup info
  static Future<Map<String, dynamic>> getBackupInfo(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      
      final credits = data['credits'] as List<dynamic>? ?? [];
      final payments = data['payments'] as List<dynamic>? ?? [];
      final exportDate = data['exportDate'] as String?;
      final version = data['version'] as String?;

      return {
        'version': version,
        'exportDate': exportDate != null ? DateTime.parse(exportDate) : null,
        'creditsCount': credits.length,
        'paymentsCount': payments.length,
        'isValid': true,
      };
    } catch (e) {
      return {
        'isValid': false,
        'error': e.toString(),
      };
    }
  }

  // Create backup summary
  static Future<String> createBackupSummary() async {
    final isar = IsarProvider.instance;
    
    final creditsCount = await isar.credits.count();
    final paymentsCount = await isar.payments.count();
    final activeCredits = await isar.credits
        .filter()
        .statusEqualTo(CreditStatus.active)
        .count();
    final pendingPayments = await isar.payments
        .filter()
        .statusEqualTo(PaymentStatus.pending)
        .count();

    return '''
Backup Summary:
- Total Credits: $creditsCount
- Active Credits: $activeCredits
- Total Payments: $paymentsCount
- Pending Payments: $pendingPayments
- Export Date: ${DateTime.now().toString()}
''';
  }
}
