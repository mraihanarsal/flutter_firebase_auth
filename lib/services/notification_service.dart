// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Handler untuk pesan di background (top-level function, WAJIB)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotif = FlutterLocalNotificationsPlugin();

  // Channel ID harus sama dengan AndroidManifest.xml
  static const _channelId = 'high_importance_channel';
  static const _channelName = 'High Importance Notifications';

  // ════ INISIALISASI ════════════════════════════════════
  Future<void> initialize() async {
    // 1. Daftarkan background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Minta izin notifikasi (iOS + Android 13+)
    await _requestPermission();

    // 3. Setup flutter_local_notifications
    await _setupLocalNotifications();

    // 4. Subscribe ke topic broadcast
    await _messaging.subscribeToTopic('all_users');

    // 5. Listener pesan saat app FOREGROUND
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 6. Listener ketika notif di-tap (app background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // 7. Cek notif yang membuka app dari terminated
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleMessageOpened(initial);
  }

  // ════ REQUEST PERMISSION ══════════════════════════════
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Notification auth status: ${settings.authorizationStatus}');
  }

  // ════ SETUP LOCAL NOTIFICATIONS ════════════════════════
  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Buat channel Android (wajib Android 8+)
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.max,
      playSound: true,
    );
    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ════ HANDLER FOREGROUND ══════════════════════════════
  void _handleForegroundMessage(RemoteMessage message) {
    final notif = message.notification;
    if (notif == null) return;

    _localNotif.show(
      notif.hashCode,
      notif.title,
      notif.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  // ════ HANDLER NOTIFICATION TAP ═════════════════════════
  void _handleMessageOpened(RemoteMessage message) {
    debugPrint('App opened from notification: ${message.messageId}');
    debugPrint('Notif data: ${message.data}');
  }

  // ════ GET DEVICE TOKEN ═════════════════════════════════
  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
    return token;
  }

  // ════ SUBSCRIBE / UNSUBSCRIBE TOPIC ══════════════════
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
}
