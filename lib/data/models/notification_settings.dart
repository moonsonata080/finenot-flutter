import 'package:hive/hive.dart';

part 'notification_settings.g.dart';

@HiveType(typeId: 5)
class NotificationSettings extends HiveObject {
  @HiveField(0)
  bool enabled; // Enable/disable notifications

  @HiveField(1)
  int defaultReminderHours; // Default hours before due date

  @HiveField(2)
  bool repeatReminders; // Send repeated reminders until paid

  @HiveField(3)
  int repeatIntervalHours; // Hours between repeated reminders

  @HiveField(4)
  int maxRepeatCount; // Maximum number of repeated reminders

  @HiveField(5)
  bool weekendReminders; // Send reminders on weekends

  @HiveField(6)
  List<String> quietHours; // Quiet hours (e.g., ["22:00", "08:00"])

  @HiveField(7)
  bool soundEnabled; // Enable sound for notifications

  @HiveField(8)
  bool vibrationEnabled; // Enable vibration for notifications

  @HiveField(9)
  String notificationSound; // Custom notification sound

  @HiveField(10)
  bool showPaymentButton; // Show "Pay" button in notifications

  @HiveField(11)
  bool showAmountInNotification; // Show payment amount in notification

  @HiveField(12)
  bool showDueDateInNotification; // Show due date in notification

  @HiveField(13)
  List<String> enabledChannels; // Enabled notification channels

  NotificationSettings({
    this.enabled = true,
    this.defaultReminderHours = 24,
    this.repeatReminders = true,
    this.repeatIntervalHours = 12,
    this.maxRepeatCount = 3,
    this.weekendReminders = true,
    this.quietHours = const ["22:00", "08:00"],
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationSound = 'default',
    this.showPaymentButton = true,
    this.showAmountInNotification = true,
    this.showDueDateInNotification = true,
    this.enabledChannels = const ['payments', 'overdue', 'analytics'],
  });

  NotificationSettings copyWith({
    bool? enabled,
    int? defaultReminderHours,
    bool? repeatReminders,
    int? repeatIntervalHours,
    int? maxRepeatCount,
    bool? weekendReminders,
    List<String>? quietHours,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? notificationSound,
    bool? showPaymentButton,
    bool? showAmountInNotification,
    bool? showDueDateInNotification,
    List<String>? enabledChannels,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      defaultReminderHours: defaultReminderHours ?? this.defaultReminderHours,
      repeatReminders: repeatReminders ?? this.repeatReminders,
      repeatIntervalHours: repeatIntervalHours ?? this.repeatIntervalHours,
      maxRepeatCount: maxRepeatCount ?? this.maxRepeatCount,
      weekendReminders: weekendReminders ?? this.weekendReminders,
      quietHours: quietHours ?? this.quietHours,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationSound: notificationSound ?? this.notificationSound,
      showPaymentButton: showPaymentButton ?? this.showPaymentButton,
      showAmountInNotification: showAmountInNotification ?? this.showAmountInNotification,
      showDueDateInNotification: showDueDateInNotification ?? this.showDueDateInNotification,
      enabledChannels: enabledChannels ?? this.enabledChannels,
    );
  }

  // Check if current time is within quiet hours
  bool get isInQuietHours {
    if (quietHours.length != 2) return false;
    
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final startTime = quietHours[0];
    final endTime = quietHours[1];
    
    // Simple time comparison (assumes 24-hour format)
    return currentTime.compareTo(startTime) >= 0 || currentTime.compareTo(endTime) <= 0;
  }

  // Get notification channels
  static List<String> get availableChannels => [
    'payments', // Payment reminders
    'overdue', // Overdue payment alerts
    'analytics', // Financial health updates
    'tips', // Financial tips and advice
    'security', // Security alerts
  ];
}
