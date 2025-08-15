import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/credit.dart';
import '../models/payment.dart';
import '../models/settings.dart';

class IsarProvider {
  static Isar? _isar;
  static bool _isInitialized = false;

  static Isar get instance {
    if (_isar == null) {
      throw Exception('Isar not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [CreditSchema, PaymentSchema, SettingsSchema],
      directory: dir.path,
    );

    _isar = isar;
    _isInitialized = true;
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
    _isInitialized = false;
  }

  static Future<void> clear() async {
    if (_isar != null) {
      await _isar!.writeTxn(() async {
        await _isar!.clear();
      });
    }
  }

  static Future<bool> isEmpty() async {
    if (_isar == null) return true;
    
    final creditCount = await _isar!.credits.count();
    final paymentCount = await _isar!.payments.count();
    final settingsCount = await _isar!.settingss.count();
    
    return creditCount == 0 && paymentCount == 0 && settingsCount == 0;
  }
}
