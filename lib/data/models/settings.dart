// Simple Settings model without Isar for testing
class Settings {
  int id;
  AppThemeMode themeMode;
  bool lockEnabled;
  AppLockType lockType;
  int notifyAheadHours;
  DateTime? createdAt;
  DateTime? updatedAt;

  Settings({
    this.id = 1,
    this.themeMode = AppThemeMode.system,
    this.lockEnabled = false,
    this.lockType = AppLockType.none,
    this.notifyAheadHours = 24,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'themeMode': themeMode.name,
      'lockEnabled': lockEnabled,
      'lockType': lockType.name,
      'notifyAheadHours': notifyAheadHours,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      id: json['id'] ?? 1,
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      lockEnabled: json['lockEnabled'] ?? false,
      lockType: AppLockType.values.firstWhere(
        (e) => e.name == json['lockType'],
        orElse: () => AppLockType.none,
      ),
      notifyAheadHours: json['notifyAheadHours'] ?? 24,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

enum AppThemeMode {
  system,
  light,
  dark,
}

enum AppLockType {
  none,
  pin,
  biometric,
}
