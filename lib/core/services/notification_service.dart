import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../data/models/payment.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'payments',
      'Платежи',
      description: 'Уведомления о предстоящих платежах',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> schedulePaymentNotification(Payment payment, int hoursAhead) async {
    if (!_initialized) await initialize();

    final notificationTime = payment.dueDate.subtract(Duration(hours: hoursAhead));
    
    // Don't schedule if notification time has passed
    if (notificationTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      payment.id.toInt(),
      'Напоминание о платеже',
      'Через ${hoursAhead}ч платеж на сумму ${payment.amount.toStringAsFixed(2)} ₽',
      tz.TZDateTime.from(notificationTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'payments',
          'Платежи',
          channelDescription: 'Уведомления о предстоящих платежах',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelPaymentNotification(int paymentId) async {
    await _notifications.cancel(paymentId);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> reschedulePaymentNotifications(List<Payment> payments, int hoursAhead) async {
    // Cancel all existing notifications
    await cancelAllNotifications();
    
    // Schedule new notifications for pending payments
    for (final payment in payments) {
      if (payment.status == 'pending') {
        await schedulePaymentNotification(payment, hoursAhead);
      }
    }
  }
}
