import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/credit.dart';
import '../../data/models/payment.dart';
import '../../data/models/settings.dart';
import '../../data/models/org.dart';
import '../../data/models/tag.dart';
import '../../data/models/notification_settings.dart';

class HiveProvider {
  static bool _initialized = false;
  static late Box<Credit> _creditsBox;
  static late Box<Payment> _paymentsBox;
  static late Box<Settings> _settingsBox;
  static late Box<Org> _orgsBox;
  static late Box<Tag> _tagsBox;
  static late Box<NotificationSettings> _notificationSettingsBox;

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

  static Box<Tag> get tagsBox {
    if (!_initialized) {
      throw Exception('Hive not initialized. Call initialize() first.');
    }
    return _tagsBox;
  }

  static Box<NotificationSettings> get notificationSettingsBox {
    if (!_initialized) {
      throw Exception('Hive not initialized. Call initialize() first.');
    }
    return _notificationSettingsBox;
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
    Hive.registerAdapter(TagAdapter());
    Hive.registerAdapter(NotificationSettingsAdapter());

    // Open boxes
    _creditsBox = await Hive.openBox<Credit>('credits');
    _paymentsBox = await Hive.openBox<Payment>('payments');
    _settingsBox = await Hive.openBox<Settings>('settings');
    _orgsBox = await Hive.openBox<Org>('orgs');
    _tagsBox = await Hive.openBox<Tag>('tags');
    _notificationSettingsBox = await Hive.openBox<NotificationSettings>('notification_settings');

    _initialized = true;
  }

  static Future<void> close() async {
    if (_initialized) {
      await _creditsBox.close();
      await _paymentsBox.close();
      await _settingsBox.close();
      await _orgsBox.close();
      await _tagsBox.close();
      await _notificationSettingsBox.close();
      _initialized = false;
    }
  }
}
