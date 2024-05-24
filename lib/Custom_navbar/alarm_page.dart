import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;


class AlarmPage extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const AlarmPage({Key? key, required this.flutterLocalNotificationsPlugin})
      : super(key: key);

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Alarm'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => scheduleAlarm(widget.flutterLocalNotificationsPlugin),
          child: Text('Set Alarm for 10:00 AM'),
        ),
      ),
    );
  }
  Future<void> scheduleAlarm(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'alarm_channel', 'Alarm',
        channelDescription: 'Channel for alarm notifications', // Use named argument
        importance: Importance.high,
        priority: Priority.high
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Alarm',
        'Wake up!',
        _nextInstanceOfTenAM(),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

}

