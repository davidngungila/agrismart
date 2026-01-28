import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/alert_model.dart';

/// Notification service without Firebase.
/// Uses only local notifications so there is no "No Firebase App" error.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize local notifications only
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android 13+ permission
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    _initialized = true;
  }

  Future<void> showLocalNotification(Alert alert) async {
    final androidDetails = AndroidNotificationDetails(
      'agrismart_alerts',
      'AgriSmart Alerts',
      channelDescription: 'Notifications for farm monitoring alerts',
      importance: _getImportance(alert.severity),
      priority: _getPriority(alert.severity),
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(alert.message),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      alert.id.hashCode,
      alert.title,
      alert.message,
      details,
      payload: alert.id,
    );
  }

  Future<void> showCustomNotification(
    String title,
    String body, {
    AlertSeverity severity = AlertSeverity.info,
  }) async {
    final alert = Alert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fieldId: '',
      title: title,
      message: body,
      type: AlertType.system,
      severity: severity,
      timestamp: DateTime.now(),
    );

    await showLocalNotification(alert);
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      // Handle notification tap - navigate to alert details
      // This would typically use a navigation service
      print('Notification tapped: ${response.payload}');
    }
  }

  Importance _getImportance(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Importance.high;
      case AlertSeverity.warning:
        return Importance.defaultImportance;
      case AlertSeverity.info:
        return Importance.low;
    }
  }

  Priority _getPriority(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Priority.high;
      case AlertSeverity.warning:
        return Priority.defaultPriority;
      case AlertSeverity.info:
        return Priority.low;
    }
  }

  /// Stub kept for API compatibility. Always returns null because
  /// Firebase Messaging is not used in this offline version.
  Future<String?> getFCMToken() async => null;
}

