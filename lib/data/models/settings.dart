import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 2)
class Settings extends HiveObject {
  @HiveField(0)
  String themeMode; // system, light, dark

  @HiveField(1)
  int notifyAheadHours; // hours before payment to notify

  @HiveField(2)
  bool lockEnabled;

  @HiveField(3)
  String lockType; // none, pin, biometric

  @HiveField(4)
  double? monthlyIncome; // for DSR calculation

  Settings({
    required this.themeMode,
    required this.notifyAheadHours,
    required this.lockEnabled,
    required this.lockType,
    this.monthlyIncome,
  });

  Settings copyWith({
    String? themeMode,
    int? notifyAheadHours,
    bool? lockEnabled,
    String? lockType,
    double? monthlyIncome,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      notifyAheadHours: notifyAheadHours ?? this.notifyAheadHours,
      lockEnabled: lockEnabled ?? this.lockEnabled,
      lockType: lockType ?? this.lockType,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
    );
  }
}
