import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

import 'package:second_eye/profile/profileDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';
import 'Rewards/rewards.dart';
import 'alarm/SharedPref.dart';
import 'eyeFatigueTest/ReportPage.dart';
import 'eyeHealthTrack.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final PersistentTabController _controller = PersistentTabController();

  int selectedIndex = 2;
   bool hidestatus=true;
  late List<AlarmSettings> alarms;
  static StreamSubscription<AlarmSettings>? subscription;

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (Alarm.android) {
      checkAndroidNotificationPermission();
      checkAndroidScheduleExactAlarmPermission();
    }
    loadAlarms();
    subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
    _controller.jumpToTab(2);
    _controller.addListener(() {
      setState(() {
        selectedIndex = _controller.index;
      });
    });
  }


  Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      final res = await Permission.notification.request();
    }
  }


  Future<void> loadAlarms() async {
    var sharedPref = await SharedPreferences.getInstance();
   bool edited = sharedPref.getBool("edited") ?? false;
    if (!edited) {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);

      if (alarms.isNotEmpty) {
        for (int i = 0; i < alarms.length; i++) {
          await Alarm.stop(alarms[i].id);
        }
        alarms.clear();
      }

      if (alarms.isEmpty) {
        DateTime now = DateTime.now();

        // Define alarm times for today
        List<DateTime> todayAlarmTimes = [
          DateTime(now.year, now.month, now.day, 6),
          DateTime(now.year, now.month, now.day, 9),
          DateTime(now.year, now.month, now.day, 12),
          DateTime(now.year, now.month, now.day, 15),
          DateTime(now.year, now.month, now.day, 18),
          DateTime(now.year, now.month, now.day, 21),
          DateTime(now.year, now.month, now.day + 1, 0),
        ];

        // Define alarm times for tomorrow
        List<DateTime> tomorrowAlarmTimes = todayAlarmTimes.map((alarmTime) {
          return alarmTime.add(const Duration(days: 1));
        }).toList();

        for (int i = 0; i < 7; i++) {
          DateTime alarmTime;
          if (todayAlarmTimes[i].isBefore(now)) {
            // Set alarm for tomorrow
            alarmTime = tomorrowAlarmTimes[i];
          } else {
            // Set alarm for today
            alarmTime = todayAlarmTimes[i];
          }

          print("Alarm Time $alarmTime");
          saveAlarm(i, alarmTime);
        }

        Future.delayed(const Duration(seconds: 2), () {
          Alarm.stopAll();
        });
      }
    }
  }

  AlarmSettings buildAlarmSettings(int i, DateTime duration) {
    final id = DateTime.now().millisecondsSinceEpoch % 10000 + i;
    final alarmSettings = AlarmSettings(
        id: id,
        dateTime: duration,
        loopAudio: false,
        vibrate: false,
        fadeDuration: 10.0,
        volume: null,
        assetAudioPath: 'assets/marimba.mp3',
        notificationTitle: 'Test Reminder',
        notificationBody: 'Do your eye test',
        isAlarmOn: false,
        notificationActionSettings: const NotificationActionSettings(
            hasSnoozeButton: false,
            hasStopButton: false,
            snoozeButtonText: "Snooze",
            stopButtonText: "Stop",
            snoozeDurationInSeconds: 300));
    return alarmSettings;
  }

  Future<void> saveAlarm(int i, DateTime duration) async {
    await Alarm.set(alarmSettings: buildAlarmSettings(i, duration));
    alarms = Alarm.getAlarms();
    alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    SharedPref.saveDefaultAlarmsToPrefs(alarms);
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            ExampleAlarmRingScreen(alarmSettings: alarmSettings),
      ),
    );
    loadAlarms();
  }

  Future<void> checkAndroidExternalStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isDenied) {
      final res = await Permission.storage.request();
    }
  }

  Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    if (status.isDenied) {
      final res = await Permission.scheduleExactAlarm.request();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        backgroundColor: Colors.grey.shade100,
        screens: _buildScreens(),
        padding: const NavBarPadding.all(8.0),
        items: _navBarsItems(),
        handleAndroidBackButtonPress: false,
        navBarStyle: NavBarStyle.style15,
        decoration: NavBarDecoration(
          adjustScreenBottomPaddingOnCurve: true,
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.grey,
        ),
        resizeToAvoidBottomInset: false,
        onItemSelected: (value) {},
        navBarHeight: MediaQuery.of(context).viewInsets.bottom > 0
            ? 0.0
            : kBottomNavigationBarHeight,
        bottomScreenMargin: 0,
      ),
    );
  }

  List<Widget> _buildScreens() => [
        ReportPage(),
        EyeHealthTrackDashboard(),
        HomePage(),
        RewardsScreen(),
        UserDashboard(),
      ];

  List<PersistentBottomNavBarItem> _navBarsItems() => [
        PersistentBottomNavBarItem(
          icon: Column(
            children: [
              Image.asset(
                'assets/report.png',color: selectedIndex == 0 ?  Colors.blue: Colors.grey,
                width: 20,
              ),
              Text(
                "Report",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: selectedIndex == 0 ?  Colors.blue:Colors.grey,
                ),
              )
            ],
          ),
        ),
        PersistentBottomNavBarItem(
          icon: Column(
            children: [
              Image.asset(
                'assets/health.png',color: selectedIndex == 1 ?   Colors.blue: Colors.grey,
                width: 17,
              ),
              Text(
                "Health",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: selectedIndex == 1 ?  Colors.blue: Colors.grey,
                ),
              )
            ],
          ),
        ),
        PersistentBottomNavBarItem(
            icon: Image.asset(
              'assets/home.png',
              width: 17,color: selectedIndex == 2 ? Colors.white : Colors.grey,
            ),
            activeColorPrimary:
                selectedIndex == 2 ? Colors.blue : Colors.white
        ),
        PersistentBottomNavBarItem(
          icon: Column(
            children: [
              Image.asset(
                'assets/rewards.png',color: selectedIndex == 3 ?  Colors.blue: Colors.grey,
                width: 17,
              ),
              Text(
                "Rewards",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: selectedIndex == 3 ? Colors.blue: Colors.grey,
                ),
              )
            ],
          ),
        ),
        PersistentBottomNavBarItem(
          icon: Column(
            children: [
              Image.asset(
                'assets/user.png',color: selectedIndex == 4 ?  Colors.blue: Colors.grey,
                width: 16,
              ),
              Text(
                "Account",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: selectedIndex == 4 ? Colors.blue : Colors.grey,
                ),
              )
            ],
          ),
        ),
      ];
}
