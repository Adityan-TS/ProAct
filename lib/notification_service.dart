import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings =
      AndroidInitializationSettings("ic_launcher");

  void initialiseNotifications() async {
    InitializationSettings initializationSettings =
        InitializationSettings(android: _androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void sendNotification(String title, String body) async {
    AndroidNotificationDetails and = AndroidNotificationDetails('0', 'Events',
        playSound: true, importance: Importance.max, priority: Priority.high);

    NotificationDetails _notificationDetails =
        NotificationDetails(android: and);

    await _flutterLocalNotificationsPlugin.show(
        0, title, body, _notificationDetails);
  }

  Future initializetimezone() async {
    tz.initializeTimeZones();
  }

  Duration offsetTime = DateTime.now().timeZoneOffset;

  void scheduleNotification(
      String title, String body, int id, int day, int hour, int minutes) async {
    AndroidNotificationDetails and = AndroidNotificationDetails('1', 'Events',
        playSound: true, importance: Importance.max, priority: Priority.high);

    NotificationDetails _notificationDetails =
        NotificationDetails(android: and);

    await initializetimezone();

    var datetime = DateTime.now();

    // int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    tz.TZDateTime time = tz.TZDateTime.now(tz.local);
    var scheduleTime = tz.TZDateTime(time.location, datetime.year,
            datetime.month, day, hour, minutes, 0)
        .subtract(offsetTime);

    // await _flutterLocalNotificationsPlugin.cancelAll();
    await _checkPendingNotificationRequests();

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
          id, title, body, scheduleTime, _notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exact);
    } catch (e) {
      print("notification error ${e}");
    }
  }

  Future<void> _checkPendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print('${pendingNotificationRequests.length} pending notification ');

    for (PendingNotificationRequest pendingNotificationRequest
        in pendingNotificationRequests) {
      print(pendingNotificationRequest.id.toString() +
          " " +
          (pendingNotificationRequest.payload ?? ""));
    }
    print('NOW ' + tz.TZDateTime.now(tz.local).toString());
  }

  void cancelEventNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
