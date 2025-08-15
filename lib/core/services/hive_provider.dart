import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/credit.dart';
import '../../data/models/payment.dart';
import '../../data/models/settings.dart';
import '../../data/models/org.dart';

class HiveProvider {
  static bool _initialized = false;
  static late Box<Credit> _creditsBox;
  static late Box<Payment> _paymentsBox;
  static late Box<Settings> _settingsBox;
  static late Box<Org> _orgsBox;

  static Box<Credit> get creditsBox {
    if (!_initialized) {
      throw Exception('Hive not initialized. Call initialize() first.');
    }
    return _creditsBox;
  }

  static Box<Payment> get paymentsBox {
    if (!_initialized) {
      throw Exception('Hive not initialized. Call initialize() first.');
    }
    return _paymentsBox;
  }

  static Box<Settings> get settingsBox {
    if (!_initialized) {
      throw Exception('Hive not initialized. Call initialize() first.');
    }
    return _settingsBox;
  }

  static Box<Org> get orgsBox {
    if (!_initialized) {
      throw Exception('Hive not initialized. Call initialize() first.');
    }
    return _orgsBox;
  }

  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(CreditAdapter());
    Hive.registerAdapter(PaymentAdapter());
    Hive.registerAdapter(SettingsAdapter());
    Hive.registerAdapter(OrgAdapter());

    // Open boxes
    _creditsBox = await Hive.openBox<Credit>('credits');
    _paymentsBox = await Hive.openBox<Payment>('payments');
    _settingsBox = await Hive.openBox<Settings>('settings');
    _orgsBox = await Hive.openBox<Org>('orgs');

    _initialized = true;
  }

  static Future<void> close() async {
    if (_initialized) {
      await _creditsBox.close();
      await _paymentsBox.close();
      await _settingsBox.close();
      await _orgsBox.close();
      _initialized = false;
    }
  }
}
