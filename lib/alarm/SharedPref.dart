import 'dart:convert';

import 'package:alarm/model/alarm_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static Future<void> saveAlarmsToPrefs(List<AlarmSettings> alarms) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonAlarms =
    alarms.map((alarm) => jsonEncode(alarm.toJson())).toList();
    await prefs.setStringList('alarms', jsonAlarms);
  }

  static Future<List<AlarmSettings>> getAlarmsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonAlarms = prefs.getStringList('alarms');

    if (jsonAlarms != null) {
      return jsonAlarms
          .map((jsonAlarm) => AlarmSettings.fromJson(jsonDecode(jsonAlarm)))
          .toList();
    } else {
      return [];
    }
  }


  static Future<void> saveDefaultAlarmsToPrefs(List<AlarmSettings> alarms) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonAlarms =
    alarms.map((alarm) => jsonEncode(alarm.toJson())).toList();
    await prefs.setStringList('alarmsDefault', jsonAlarms);
  }

  static Future<List<AlarmSettings>> getDefaultAlarmsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonAlarms = prefs.getStringList('alarmsDefault');

    if (jsonAlarms != null) {
      return jsonAlarms
          .map((jsonAlarm) => AlarmSettings.fromJson(jsonDecode(jsonAlarm)))
          .toList();
    } else {
      return [];
    }
  }
}
