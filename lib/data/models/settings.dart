import 'package:isar/isar.dart';

part 'settings.g.dart';

@collection
class Settings {
  Id id = 1; // singleton

  @enumerated
  ThemeMode themeMode = ThemeMode.system;

  bool lockEnabled = false;

  @enumerated
  LockType lockType = LockType.none;

  int notifyAheadHours = 24;

  DateTime? createdAt;

  DateTime? updatedAt;
}

enum ThemeMode {
  system,
  light,
  dark,
}

enum LockType {
  none,
  pin,
  biometric,
}
