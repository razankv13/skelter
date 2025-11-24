import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:skelter/presentation/reminder/model/reminder_model.dart';
import 'package:skelter/widgets/styling/app_colors.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Message data: ${message.data}');
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AwesomeNotifications _awesomeNotifications = AwesomeNotifications();

  final _onNotificationTapController =
      StreamController<Map<String, dynamic>>.broadcast();

  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;
  StreamSubscription<String>? _onTokenRefreshSubscription;

  RemoteMessage? _initialMessage;

  Stream<Map<String, dynamic>> get onNotificationTap =>
      _onNotificationTapController.stream;

  Map<String, dynamic>? get initialNotificationPayload => _initialMessage?.data;

  Future<void> initialize() async {
    await _initializeAwesomeNotifications();
    await _requestPermissions();
    await _setupFCMListeners();
    await _getFCMToken();
  }

  Future<void> _initializeAwesomeNotifications() async {
    await _awesomeNotifications.initialize(
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic notifications',
          ledColor: AppColors.white,
          defaultColor: AppColors.brand500,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'reminder_channel',
          channelName: 'Reminders',
          channelDescription: 'Notification channel for reminders',
          ledColor: AppColors.white,
          defaultColor: AppColors.brand500,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: kDebugMode,
    );

    await _awesomeNotifications.setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }

  Future<void> _requestPermissions() async {
    final isAllowed = await _awesomeNotifications.isNotificationAllowed();
    if (!isAllowed) {
      await _awesomeNotifications.requestPermissionToSendNotifications();
    }

    final settings = await _firebaseMessaging.requestPermission();
    debugPrint('FCM Permission granted: ${settings.authorizationStatus}');
  }

  Future<void> _setupFCMListeners() async {
    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    _onMessageOpenedAppSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    _initialMessage = await _firebaseMessaging.getInitialMessage();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Got a message in foreground: ${message.messageId}');
    debugPrint('Message data: ${message.data}');

    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      await showNotification(
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        payload: data,
        imageUrl:
            notification.android?.imageUrl ?? notification.apple?.imageUrl,
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');
    debugPrint('Message data: ${message.data}');

    _onNotificationTapController.add(message.data);
  }

  Future<String?> _getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');

      _onTokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen(
        (newToken) {
          debugPrint('FCM Token refreshed: $newToken');
        },
      );

      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
    String? imageUrl,
    String channelKey = 'basic_channel',
  }) async {
    await _awesomeNotifications.createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: channelKey,
        title: title,
        body: body,
        payload: payload?.map((key, value) => MapEntry(key, value.toString())),
        bigPicture: imageUrl,
        notificationLayout: imageUrl != null
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Message,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('Notification created: ${receivedNotification.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('Notification displayed: ${receivedNotification.id}');
  }

  // On Tap Foreground notification
  @pragma('vm:entry-point')
  static Future<void> _onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('Notification action received: ${receivedAction.id}');
    debugPrint('Payload: ${receivedAction.payload}');
    final payloadMap = receivedAction.payload ?? {};
    instance._onNotificationTapController.add(payloadMap);
  }

  @pragma('vm:entry-point')
  static Future<void> _onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('Notification dismissed: ${receivedAction.id}');
  }

  Future<bool> scheduleReminder(ReminderModel reminder) async {
    try {
      await _awesomeNotifications.createNotification(
        content: NotificationContent(
          id: reminder.id,
          channelKey: 'reminder_channel',
          title: reminder.title,
          body: reminder.description,
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
          autoDismissible: false,
        ),
        schedule: NotificationCalendar.fromDate(
          date: reminder.scheduledDateTime,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );

      debugPrint(
        'Scheduled reminder: ${reminder.title} at '
        '${reminder.scheduledDateTime}',
      );
      return true;
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
      return false;
    }
  }

  void dispose() {
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
    _onTokenRefreshSubscription?.cancel();
    _onNotificationTapController.close();
  }
}
