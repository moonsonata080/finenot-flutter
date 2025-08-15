import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../data/models/payment.dart';
import '../../data/models/credit.dart';
import '../../data/models/settings.dart';
import '../../data/repositories/settings_repository.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static const String _channelId = 'payments_channel';
  static const String _channelName = 'Payment Reminders';
  static const String _channelDescription = 'Reminders about upcoming payments';

  static Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _isInitialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Navigate to payments page when notification is tapped
    // This will be handled by the app's navigation system
  }

  // Schedule notification for a payment
  static Future<void> schedulePaymentNotification(Payment payment) async {
    if (!_isInitialized) await initialize();

    final notificationId = payment.id.toInt();
    final notifyTime = payment.dueDate.subtract(const Duration(hours: 24));

    const androidDetails = AndroidNotificationDetails(
      'payment_channel',
      'Payment Notifications',
      channelDescription: 'Notifications for upcoming payments',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      notificationId,
      'Payment Reminder',
      'Payment of ${payment.amount.toStringAsFixed(2)} is due soon',
      tz.TZDateTime.from(notifyTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'payment_${payment.id}',
    );
  }

  // Cancel notification for a payment
  static Future<void> cancelPaymentNotification(Payment payment) async {
    if (!_isInitialized) return;

    final notificationId = payment.id.toInt();
    await _notifications.cancel(notificationId);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;

    await _notifications.cancelAll();
  }

  // Reschedule all pending payment notifications
  static Future<void> rescheduleAllNotifications() async {
    if (!_isInitialized) await initialize();

    // Cancel existing notifications
    await cancelAllNotifications();

    // For now, we'll skip rescheduling since we don't have Isar
    // This can be implemented later when we restore the database
  }

  // Update notifications when payment status changes
  static Future<void> onPaymentStatusChanged(Payment payment) async {
    // Remove existing notification for this payment
    await _notifications.cancel(payment.id.toInt());
    
    // Create new notification based on status
    switch (payment.status) {
      case PaymentStatus.paid:
        await _notifications.show(
          payment.id.toInt(),
          'Платеж оплачен',
          'Платеж на сумму ${payment.amount.toStringAsFixed(0)} ₽ успешно оплачен',
        );
        break;
      case PaymentStatus.overdue:
        await _notifications.show(
          payment.id.toInt(),
          'Платеж просрочен',
          'Платеж на сумму ${payment.amount.toStringAsFixed(0)} ₽ просрочен',
        );
        break;
      default:
        break;
    }
  }

  static Future<void> _showNotification(int id, String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'payment_channel',
      'Payment Notifications',
      channelDescription: 'Notifications for payment status changes',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, notificationDetails);
  }

  // Update notifications when settings change
  static Future<void> onNotificationSettingsChanged() async {
    await rescheduleAllNotifications();
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) await initialize();

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      return await androidPlugin.areNotificationsEnabled() ?? false;
    }

    return true; // Assume enabled for iOS
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      return await androidPlugin.requestNotificationsPermission() ?? false;
    }

    return true; // iOS permissions are handled in initialization
  }
}
