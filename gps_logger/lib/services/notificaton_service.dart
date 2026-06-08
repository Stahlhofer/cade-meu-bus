import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onNotificationResponse,
    );
  }

  static Future<void> onNotificationResponse(
    NotificationResponse response,
  ) async {
    if (response.actionId == 'STOP_SERVICE') {
      /// Envia evento para foreground service
      FlutterForegroundTask.sendDataToTask('stop_service');
    }
  }

  static Future<void> showTrackingNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'tracking_channel',
          'Tracking Service',
          channelDescription: 'Serviço de rastreamento',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,

          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'STOP_SERVICE',
              'Parar Serviço',
              cancelNotification: true,
            ),
          ],
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      id: 1001,
      title: 'Rastreamento ativo',
      body: 'GPS e MQTT conectados',
      payload: details.toString(),
    );
  }
}
