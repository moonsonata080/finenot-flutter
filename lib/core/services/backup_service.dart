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
import '../../data/repositories/credit_repository.dart';
import '../../data/repositories/payment_repository.dart';

class BackupService {
  static const String _backupFileName = 'finenot_backup';

  // Export all data to JSON
  static Future<Map<String, dynamic>> exportData() async {
    try {
      final creditsRepo = CreditRepository();
      final paymentsRepo = PaymentRepository();
      final settingsRepo = SettingsRepository();

      final credits = await creditsRepo.getAllCredits();
      final payments = await paymentsRepo.getAllPayments();
      final settings = await settingsRepo.getSettings();

      return {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'credits': credits.map((c) => c.toJson()).toList(),
        'payments': payments.map((p) => p.toJson()).toList(),
        'settings': settings.toJson(),
      };
    } catch (e) {
      print('Error exporting data: $e');
      rethrow;
    }
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
      await file.writeAsString(jsonEncode(jsonData));

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
  static Future<bool> importData(Map<String, dynamic> data) async {
    try {
      final creditsRepo = CreditRepository();
      final paymentsRepo = PaymentRepository();
      final settingsRepo = SettingsRepository();

      // Import credits
      if (data['credits'] != null) {
        final creditsJson = data['credits'] as List;
        for (final creditJson in creditsJson) {
          final credit = Credit.fromJson(creditJson);
          await creditsRepo.addCredit(credit);
        }
      }

      // Import payments
      if (data['payments'] != null) {
        final paymentsJson = data['payments'] as List;
        for (final paymentJson in paymentsJson) {
          final payment = Payment.fromJson(paymentJson);
          await paymentsRepo.addPayment(payment);
        }
      }

      // Import settings
      if (data['settings'] != null) {
        final settings = Settings.fromJson(data['settings']);
        await settingsRepo.updateSettings(settings);
      }

      return true;
    } catch (e) {
      print('Error importing data: $e');
      return false;
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
        final data = jsonDecode(jsonData) as Map<String, dynamic>;
        await importData(data);
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
