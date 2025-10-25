import 'dart:developer' as developer;
import 'package:flutter_local_notifications/flutter_local_notifications.dart' hide Message;
import 'package:mesh_app/core/constants/app_constants.dart';
import 'package:mesh_app/core/models/message.dart' as models;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Initialize notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        await _createNotificationChannel();
        _isInitialized = true;
        return true;
      }
      
      return false;
    } catch (e) {
      developer.log('Notification initialization error: $e');
      return false;
    }
  }

  // Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate to specific message or tab
    developer.log('Notification tapped: ${response.payload}');
  }

  // Show message notification
  Future<void> showMessageNotification(models.Message message) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final notificationId = message.id.hashCode;

      const androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
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

      String title = message.isVerified
          ? '🔒 ${message.senderName} (Verified)'
          : message.senderName;

      String body = message.type == models.MessageType.text
          ? message.content
          : _getMediaNotificationBody(message.type);

      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        details,
        payload: message.id,
      );
    } catch (e) {
      developer.log('Show notification error: $e');
    }
  }

  // Show update notification (for verified posts)
  Future<void> showUpdateNotification(models.Message update) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final notificationId = update.id.hashCode;

      const androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        styleInformation: BigTextStyleInformation(''),
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

      await _notificationsPlugin.show(
        notificationId,
        '📢 Official Update',
        update.content,
        details,
        payload: update.id,
      );
    } catch (e) {
      developer.log('Show update notification error: $e');
    }
  }

  // Show alarm notification
  Future<void> showAlarmNotification(String title, String body) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        playSound: true,
        enableVibration: true,
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

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
      );
    } catch (e) {
      developer.log('Show alarm notification error: $e');
    }
  }

  // Get media notification body
  String _getMediaNotificationBody(models.MessageType type) {
    switch (type) {
      case models.MessageType.image:
        return '📷 Sent an image';
      case models.MessageType.audio:
        return '🎵 Sent an audio message';
      case models.MessageType.video:
        return '🎥 Sent a video';
      default:
        return 'Sent a message';
    }
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Request permissions (for iOS)
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    final result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? false;
  }
}

