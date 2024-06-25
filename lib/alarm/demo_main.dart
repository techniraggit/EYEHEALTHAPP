//
// import 'dart:async';
// import 'dart:io';
//
// import 'package:alarm/alarm.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import 'package:alarm/model/alarm_settings.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//
//   await Alarm.init();
//
//   runApp(
//     MaterialApp(
//       theme: ThemeData(useMaterial3: false),
//       home: const ExampleAlarmHomeScreen(),
//     ),
//   );
// }
//
//
// class ExampleAlarmHomeScreen extends StatefulWidget {
//   const ExampleAlarmHomeScreen({super.key});
//
//   @override
//   State<ExampleAlarmHomeScreen> createState() => _ExampleAlarmHomeScreenState();
// }
//
// class _ExampleAlarmHomeScreenState extends State<ExampleAlarmHomeScreen> {
//   late List<AlarmSettings> alarms;
//
//   // static StreamSubscription<AlarmSettings>? subscription;
//
//   @override
//   void initState() {
//     super.initState();
//     if (Alarm.android) {
//       checkAndroidNotificationPermission();
//       checkAndroidScheduleExactAlarmPermission();
//     }
//     loadAlarms();
//   }
//
//   void loadAlarms() {
//     setState(() {
//       alarms = Alarm.getAlarms();
//       alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
//
//
//     });
//   }
//
//   Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute<void>(
//         builder: (context) =>
//             ExampleAlarmRingScreen(alarmSettings: alarmSettings),
//       ),
//     );
//     loadAlarms();
//   }
//
//   Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
//     final res = await showModalBottomSheet<bool?>(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       builder: (context) {
//         return FractionallySizedBox(
//           heightFactor: 0.75,
//           child: ExampleAlarmEditScreen(alarmSettings: settings),
//         );
//       },
//     );
//
//     if (res != null && res == true) loadAlarms();
//   }
//
//   Future<void> checkAndroidNotificationPermission() async {
//     final status = await Permission.notification.status;
//     if (status.isDenied) {
//       alarmPrint('Requesting notification permission...');
//       final res = await Permission.notification.request();
//       alarmPrint(
//         'Notification permission ${res.isGranted ? '' : 'not '}granted',
//       );
//     }
//   }
//
//   Future<void> checkAndroidExternalStoragePermission() async {
//     final status = await Permission.storage.status;
//     if (status.isDenied) {
//       alarmPrint('Requesting external storage permission...');
//       final res = await Permission.storage.request();
//       alarmPrint(
//         'External storage permission ${res.isGranted ? '' : 'not'} granted',
//       );
//     }
//   }
//
//   Future<void> checkAndroidScheduleExactAlarmPermission() async {
//     final status = await Permission.scheduleExactAlarm.status;
//     alarmPrint('Schedule exact alarm permission: $status.');
//     if (status.isDenied) {
//       alarmPrint('Requesting schedule exact alarm permission...');
//       final res = await Permission.scheduleExactAlarm.request();
//       alarmPrint(
//         'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted',
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     // subscription?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title:  const Center(child: Text('Alarms Scheduled',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 17,color: Colors.black),))),
//
//       body: SafeArea(
//         child: alarms.isNotEmpty
//             ? ListView.builder(
//           itemCount: alarms.length,
//           itemBuilder: (context, index) {
//             return ExampleAlarmTile(
//               key: Key(alarms[index].id.toString()),
//               title: TimeOfDay(
//                 hour: alarms[index].dateTime.hour,
//                 minute: alarms[index].dateTime.minute,
//               ).format(context),
//               onPressed: () => navigateToAlarmScreen(alarms[index]),
//               onDismissed: () {
//                 Alarm.stop(alarms[index].id).then((_) => loadAlarms());
//               },
//             );
//           },
//         )
//             : Center(
//           child: Text(
//             'No alarm set',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//         ),
//       ),
//
//       floatingActionButton: Padding(
//         padding:  const EdgeInsets.fromLTRB(10,10,40,60),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             ExampleAlarmHomeShortcutButton(refreshAlarms: loadAlarms),
//             FloatingActionButton(
//               onPressed: () => navigateToAlarmScreen(null),
//               child: const Icon(Icons.alarm_add_rounded, size: 33),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
//
//   Future<bool?> getBoolValueWithId(int id) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     // Retrieve the boolean value based on the ID
//     return prefs.getBool('bool_$id');
//   }
// }
//
//
// class ExampleAlarmEditScreen extends StatefulWidget {
//   const ExampleAlarmEditScreen({super.key, this.alarmSettings});
//
//   final AlarmSettings? alarmSettings;
//
//   @override
//   State<ExampleAlarmEditScreen> createState() => _ExampleAlarmEditScreenState();
// }
//
// class _ExampleAlarmEditScreenState extends State<ExampleAlarmEditScreen> {
//   bool loading = false;
//   late bool isSwitched = true;
//
//   late bool creating;
//   late DateTime selectedDateTime;
//   late bool loopAudio;
//   late bool vibrate;
//   late double? volume;
//   late String assetAudio;
//
//   @override
//   void initState() {
//     super.initState();
//     creating = widget.alarmSettings == null;
//
//     if (creating) {
//       selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
//       selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
//       loopAudio = true;
//       vibrate = true;
//       // isSwitched=true;
//       volume = null;
//       assetAudio = 'assets/marimba.mp3';
//     } else {
//       selectedDateTime = widget.alarmSettings!.dateTime;
//       loopAudio = widget.alarmSettings!.loopAudio;
//       vibrate = widget.alarmSettings!.vibrate;
//       // isSwitched=widget.alarmSettings!.alarmStatus;
//       volume = widget.alarmSettings!.volume;
//       assetAudio = widget.alarmSettings!.assetAudioPath;
//     }
//   }
//
//   String getDay() {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final difference = selectedDateTime.difference(today).inDays;
//
//     switch (difference) {
//       case 0:
//         return 'Today';
//       case 1:
//         return 'Tomorrow';
//       case 2:
//         return 'After tomorrow';
//       default:
//         return 'In $difference days';
//     }
//   }
//
//   Future<void> pickTime() async {
//     final res = await showTimePicker(
//       initialTime: TimeOfDay.fromDateTime(selectedDateTime),
//       context: context,
//     );
//
//     if (res != null) {
//       setState(() {
//         final now = DateTime.now();
//         selectedDateTime = now.copyWith(
//           hour: res.hour,
//           minute: res.minute,
//           second: 0,
//           millisecond: 0,
//           microsecond: 0,
//         );
//         if (selectedDateTime.isBefore(now)) {
//           selectedDateTime = selectedDateTime.add(const Duration(days: 1));
//         }
//       });
//     }
//   }
//
//   AlarmSettings buildAlarmSettings() {
//     final id = creating
//         ? DateTime.now().millisecondsSinceEpoch % 10000 + 1
//         : widget.alarmSettings!.id;
//
//     final alarmSettings = AlarmSettings(
//       id: id,
//       dateTime: selectedDateTime,
//       loopAudio: loopAudio,
//       vibrate: vibrate,
//       volume: volume,
//       assetAudioPath: assetAudio,
//       notificationTitle: 'Test Reminder',
//       notificationBody: 'Do your eye test',
//       enableNotificationOnKill: Platform.isIOS,
//       // notificationActionSettings: const NotificationActionSettings(hasSnoozeButton: true,hasStopButton: true,snoozeButtonText: "Snooze",stopButtonText: "Stop",snoozeDurationInSeconds: 300)
//     );
//     return alarmSettings;
//   }
//   void requestAlarmNotiPermission() async {
//     PermissionStatus permission = await Permission.notification.status;
//
//     if (permission.isDenied || permission.isPermanentlyDenied) {
//       await Permission.notification.request();
//
//       // Permissions are denied or denied forever, let's request it!
//       permission = await Permission.notification.status;
//       if (permission.isDenied) {
//         await Permission.notification.request();
//         print("Notification permissions are still denied");
//       }
//       else if (permission.isPermanentlyDenied) {
//         print("Notification permissions are permanently denied");
//         // Prompt the user to open app settings to enable notification permissions manually
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text("Notification permissions required"),
//               content: const Text("Notification permissions are permanently denied. Please go to app settings to enable notification permissions."),
//               actions: <Widget>[
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue, // Set your desired background color here
//                     // You can also customize other button properties here if needed
//                   ),
//                   onPressed: () async {
//                     Navigator.pop(context); // Close the dialog
//                     await openAppSettings();
//                   },
//                   child: const Text(
//                     "OK",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//       else {
//         saveAlarm();
//         // Permissions are granted.
//         print("Notification permissions are granted");
//       }
//     }
//     else {
//       saveAlarm();
//       print("Notification permissions are already granted");
//     }
//   }
//
//
//
//
//
//   Future<void> saveAlarm() async {
//     print('alrm 0000000000');
//
//     // requestAlarmNotiPermission();
//
//
//
//     if (loading) return;
//     setState(() => loading = true);
//     Alarm.set(alarmSettings: buildAlarmSettings()).then((res) {
//       if (res) Navigator.pop(context, true);
//       setState(() => loading = false);
//     });
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('edited', true);
//   }
//
//   Future<void> deleteAlarm() async {
//     Alarm.stop(widget.alarmSettings!.id).then((res) {
//       if (res) Navigator.pop(context, true);
//     });
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('edited', true);
//   }
//   Future<void> saveBoolValueWithId(int id, bool value) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     // Save the boolean value with its corresponding ID
//     await prefs.setBool('bool_$id', value);
//   }
//
//   Future<void> toggleSwitch(bool value) async {
//     var sharedPref = await SharedPreferences.getInstance();
//
//     if (isSwitched ==false) {
//       saveBoolValueWithId(widget.alarmSettings!.id, true);
//
//       setState(() {
//         isSwitched = true;
//
//         Alarm.set(
//           alarmSettings: widget.alarmSettings!.copyWith(
//             dateTime: DateTime(
//               selectedDateTime.year,
//               selectedDateTime.month,
//               selectedDateTime.day,
//               selectedDateTime.hour,
//               selectedDateTime.minute,
//             ).add(const Duration(minutes: 1)),
//           ),
//         );
//       });
//     }
//     else{
//       setState(() {
//         saveBoolValueWithId(widget.alarmSettings!.id, false);
//
//         isSwitched = false;
//         Alarm.stop(widget.alarmSettings!.id);
//
//       });
//     }
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('edited', true);
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Select Time Slot',style: TextStyle(color: Colors.black,fontSize: 16),
//                 // style: Theme.of(context)
//                 //     .textTheme
//                 //     .titleLarge!
//                 //     .copyWith(color: Colors.blueAccent),
//               ),
//               TextButton(
//                 onPressed:requestAlarmNotiPermission,// saveAlarm,requestAlarmNotiPermission
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all<Color>(Colors.background),
//                 ),
//                 child: loading
//                     ? const CircularProgressIndicator()
//                     : const Text(
//                     'Done',
//                     style:TextStyle(color: Colors.white,fontSize: 13)
//                   // style: Theme.of(context)
//                   //     .textTheme
//                   //     .titleLarge!
//                   //     .copyWith(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//           // Text(
//           //   getDay(),
//           //   style: Theme.of(context)
//           //       .textTheme
//           //       .titleMedium!
//           //       .copyWith(color: Colors.blueAccent.withOpacity(0.8)),
//           // ),
//           RawMaterialButton(
//             onPressed: pickTime,
//             fillColor: Colors.grey[200],
//             child: Container(
//               margin:  const EdgeInsets.all(30),
//               child: Text(
//                 TimeOfDay.fromDateTime(selectedDateTime).format(context),
//                 style: Theme.of(context)
//                     .textTheme
//                     .displayMedium!
//                     .copyWith(color: Colors.black,fontSize: 29),
//               ),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Loop alarm audio',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               Switch(
//                 value: loopAudio,
//                 onChanged: (value) => setState(() => loopAudio = value),
//               ),
//             ],
//           ),
//
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Vibrate',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               Switch(
//                 value: vibrate,
//                 onChanged: (value) => setState(() => vibrate = value),
//               ),
//             ],
//           ),
//
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Custom volume',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               Switch(
//                 value: volume != null,
//                 onChanged: (value) =>
//                     setState(() => volume = value ? 0.5 : null),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Text(
//                 'Alarm status: ${isSwitched ? 'ON' : 'OFF'}',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               SizedBox(height: 20),
//               Switch(
//                 value: isSwitched,
//                 onChanged: toggleSwitch,
//                 activeColor: Colors.white,
//                 activeTrackColor: Colors.background,
//                 inactiveThumbColor: Colors.grey,
//                 inactiveTrackColor: Colors.grey[300],
//               ),
//             ],
//           ),
//           SizedBox(
//             height: 30,
//             child: volume != null
//                 ? Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Icon(
//                   volume! > 0.7
//                       ? Icons.volume_up_rounded
//                       : volume! > 0.1
//                       ? Icons.volume_down_rounded
//                       : Icons.volume_mute_rounded,
//                 ),
//                 Expanded(
//                   child: Slider(
//                     value: volume!,
//                     onChanged: (value) {
//                       setState(() => volume = value);
//                     },
//                   ),
//                 ),
//               ],
//             )
//                 : const SizedBox(),
//           ),
//           if (!creating)
//             TextButton(
//               onPressed: deleteAlarm,
//               child: Text(
//                 'Delete Alarm',
//                 style: Theme.of(context)
//                     .textTheme
//                     .titleMedium!
//                     .copyWith(color: Colors.red),
//               ),
//             ),
//           const SizedBox(),
//         ],
//       ),
//     );
//   }
// }
//
//
// class ExampleAlarmRingScreen extends StatelessWidget {
//   const ExampleAlarmRingScreen({required this.alarmSettings, super.key});
//
//   final AlarmSettings alarmSettings;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Text(
//               'You alarm (${alarmSettings.id}) is-- ringing...',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const Text('🔔', style: TextStyle(fontSize: 50)),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 RawMaterialButton(
//                   onPressed: () {
//                     final now = DateTime.now();
//                     Alarm.set(
//                       alarmSettings: alarmSettings.copyWith(
//                         dateTime: DateTime(
//                           now.year,
//                           now.month,
//                           now.day,
//                           now.hour,
//                           now.minute,
//                         ).add(const Duration(minutes: 1)),
//                       ),
//                     ).then((_) => Navigator.pop(context));
//                   },
//                   child: Text(
//                     'Snooze',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                 ),
//                 RawMaterialButton(
//                   onPressed: () {
//                     Alarm.stop(alarmSettings.id)
//                         .then((_) => Navigator.pop(context));
//                   },
//                   child: Text(
//                     'Stop',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
//
//
//
// class ExampleAlarmHomeShortcutButton extends StatefulWidget {
//   const ExampleAlarmHomeShortcutButton({
//     required this.refreshAlarms,
//     super.key,
//   });
//
//   final void Function() refreshAlarms;
//
//   @override
//   State<ExampleAlarmHomeShortcutButton> createState() =>
//       _ExampleAlarmHomeShortcutButtonState();
// }
//
// class _ExampleAlarmHomeShortcutButtonState
//     extends State<ExampleAlarmHomeShortcutButton> {
//   bool showMenu = false;
//
//   Future<void> onPressButton(int delayInHours) async {
//     var dateTime = DateTime.now().add(Duration(hours: delayInHours));
//     double? volume;
//
//     if (delayInHours != 0) {
//       dateTime = dateTime.copyWith(second: 0, millisecond: 0);
//       volume = 0.5;
//     }
//
//     setState(() => showMenu = false);
//
//     final alarmSettings = AlarmSettings(
//       id: DateTime.now().millisecondsSinceEpoch % 10000,
//       dateTime: dateTime,
//       assetAudioPath: 'assets/marimba.mp3',
//       volume: volume,
//       notificationTitle: 'Test Reminder',
//       notificationBody: 'Do your eye test',
//       enableNotificationOnKill: Platform.isIOS,
//     );
//
//     await Alarm.set(alarmSettings: alarmSettings);
//
//     widget.refreshAlarms();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//
//         if (showMenu)
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextButton(
//                 onPressed: () => onPressButton(24),
//                 child: const Text('+24h'),
//               ),
//               TextButton(
//                 onPressed: () => onPressButton(36),
//                 child: const Text('+36h'),
//               ),
//               TextButton(
//                 onPressed: () => onPressButton(48),
//                 child: const Text('+48h'),
//               ),
//             ],
//           ),
//       ],
//     );
//   }
// }
//
// class ExampleAlarmTile extends StatelessWidget {
//   const ExampleAlarmTile({
//     required this.title,
//     required this.onPressed,
//     super.key,
//     this.onDismissed,
//   });
//
//   final String title;
//   final void Function() onPressed;
//   final void Function()? onDismissed;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: (){
//         onPressed();
//       },
//       child: SizedBox( // Wrap the Card in a SizedBox to control its size
//         height: 85, // Set height to 40
//         child: Card(
//           elevation: 0.4, // Adjust the elevation as needed
//           margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 8), // Adjust the margin as needed
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20), // Adjust the border radius as needed
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 18),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16, // Adjusted font size
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 const Icon(Icons.keyboard_arrow_right_rounded, size: 24), // Adjusted icon size
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }






















// ignore_for_file: avoid_print
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:alarm/model/alarm_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SharedPref.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Alarm.init();

  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: false),
      home: const ExampleAlarmHomeScreen(),
    ),
  );
}

class ExampleAlarmHomeScreen extends StatefulWidget {
  const ExampleAlarmHomeScreen({super.key});

  @override
  State<ExampleAlarmHomeScreen> createState() => _ExampleAlarmHomeScreenState();
}

class _ExampleAlarmHomeScreenState extends State<ExampleAlarmHomeScreen> {
  List<AlarmSettings> alarms = [];

  // static StreamSubscription<AlarmSettings>? subscription;

  @override
  void initState() {
    super.initState();
    if (Alarm.android) {
      checkAndroidNotificationPermission();
      checkAndroidScheduleExactAlarmPermission();
    }
    loadAlarms();
  }

  Future<void> loadAlarms() async {
    alarms = await SharedPref.getAlarmsFromPrefs();
    alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    if (mounted) {
      setState(() {});
    }
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

  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: ExampleAlarmEditScreen(alarmSettings: settings),
        );
      },
    );

    if (res != null && res == true) loadAlarms();
  }

  Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      alarmPrint('Requesting notification permission...');
      final res = await Permission.notification.request();
      alarmPrint(
        'Notification permission ${res.isGranted ? '' : 'not '}granted',
      );
    }
  }

  Future<void> checkAndroidExternalStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isDenied) {
      alarmPrint('Requesting external storage permission...');
      final res = await Permission.storage.request();
      alarmPrint(
        'External storage permission ${res.isGranted ? '' : 'not'} granted',
      );
    }
  }

  Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    alarmPrint('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
      alarmPrint('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      alarmPrint(
        'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted',
      );
    }
  }

  @override
  void dispose() {
    // subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Center(
              child: Text(
                'Alarms Scheduled',
                style: TextStyle(
                    fontWeight: FontWeight.w400, fontSize: 17, color: Colors.black),
              ))),
      body: SafeArea(
        child: alarms.isNotEmpty
            ? ListView.builder(
          itemCount: alarms.length,
          itemBuilder: (context, index) {
            return ExampleAlarmTile(
              key: Key(alarms[index].id.toString()),
              title: TimeOfDay(
                hour: alarms[index].dateTime.hour,
                minute: alarms[index].dateTime.minute,
              ).format(context),
              onPressed: () => navigateToAlarmScreen(alarms[index]),
              onDismissed: () {
                Alarm.stop(alarms[index].id).then((_) => loadAlarms());
              },
            );
          },
        )
            : Center(
          child: Text(
            'No alarm set',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 40, 60),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ExampleAlarmHomeShortcutButton(refreshAlarms: loadAlarms),
            FloatingActionButton(
              onPressed: () => navigateToAlarmScreen(null),
              child: const Icon(Icons.alarm_add_rounded, size: 33),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<bool?> getBoolValueWithId(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Retrieve the boolean value based on the ID
    return prefs.getBool('bool_$id');
  }
}

class ExampleAlarmEditScreen extends StatefulWidget {
  const ExampleAlarmEditScreen({super.key, this.alarmSettings});

  final AlarmSettings? alarmSettings;

  @override
  State<ExampleAlarmEditScreen> createState() => _ExampleAlarmEditScreenState();
}

class _ExampleAlarmEditScreenState extends State<ExampleAlarmEditScreen> {
  bool loading = false;
  late bool isSwitched = true;

  late bool creating;
  late DateTime selectedDateTime;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String assetAudio;

  @override
  void initState() {
    super.initState();
    creating = widget.alarmSettings == null;

    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volume = null;
      assetAudio = 'assets/marimba.mp3';
      isSwitched = true;
    } else {
      selectedDateTime = widget.alarmSettings!.dateTime;
      loopAudio = widget.alarmSettings!.loopAudio;
      vibrate = widget.alarmSettings!.vibrate;
      isSwitched = widget.alarmSettings!.isAlarmOn;
      volume = widget.alarmSettings!.volume;
      assetAudio = widget.alarmSettings!.assetAudioPath;
    }
  }

  String getDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = selectedDateTime.difference(today).inDays;

    switch (difference) {
      case 0:
        return 'Today';
      case 1:
        return 'Tomorrow';
      case 2:
        return 'After tomorrow';
      default:
        return 'In $difference days';
    }
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      context: context,
    );

    if (res != null) {
      setState(() {
        final now = DateTime.now();
        selectedDateTime = now.copyWith(
          hour: res.hour,
          minute: res.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        if (selectedDateTime.isBefore(now)) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
      });
    }
  }

  AlarmSettings buildAlarmSettings() {
    final id = creating
        ? DateTime.now().millisecondsSinceEpoch % 10000 + 1
        : widget.alarmSettings!.id;

    print("ID of the alarm $id");

    final alarmSettings = AlarmSettings(
        id: id,
        dateTime: selectedDateTime,
        loopAudio: loopAudio,
        vibrate: vibrate,
        volume: volume,
        assetAudioPath: assetAudio,
        notificationTitle: 'Test Reminder',
        notificationBody: 'Do your eye test',
        enableNotificationOnKill: Platform.isIOS,
        isAlarmOn: isSwitched
      // notificationActionSettings: const NotificationActionSettings(hasSnoozeButton: true,hasStopButton: true,snoozeButtonText: "Snooze",stopButtonText: "Stop",snoozeDurationInSeconds: 300)
    );
    return alarmSettings;
  }

  void requestAlarmNotiPermission() async {
    PermissionStatus permission = await Permission.notification.status;

    if (permission.isDenied || permission.isPermanentlyDenied) {
      await Permission.notification.request();

      // Permissions are denied or denied forever, let's request it!
      permission = await Permission.notification.status;
      if (permission.isDenied) {
        await Permission.notification.request();
        print("Notification permissions are still denied");
      } else if (permission.isPermanentlyDenied) {
        print("Notification permissions are permanently denied");
        // Prompt the user to open app settings to enable notification permissions manually
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Notification permissions required"),
              content: const Text(
                  "Notification permissions are permanently denied. Please go to app settings to enable notification permissions."),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.blue, // Set your desired background color here
                    // You can also customize other button properties here if needed
                  ),
                  onPressed: () async {
                    Navigator.pop(context); // Close the dialog
                    await openAppSettings();
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        saveAlarm();
        // Permissions are granted.
        print("Notification permissions are granted");
      }
    } else {
      saveAlarm();
      print("Notification permissions are already granted");
    }
  }

  Future<void> saveAlarm() async {
    print('alrm 0000000000');

    // requestAlarmNotiPermission();

    if (loading) return;
    setState(() => loading = true);

    AlarmSettings alarmSettings = buildAlarmSettings();
    if (isSwitched) {
      print("Alarm set");
      await Alarm.set(alarmSettings: alarmSettings);
    } else if (!creating) {
      print("Already set alarm is off now ${widget.alarmSettings!.id}");
      // await Alarm.stop(widget.alarmSettings!.id);

      Alarm.stop(widget.alarmSettings!.id).then((value) {
        print("asdlksadasjkldk $value");
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('edited', true);

    loading = false;
    final alarms = await SharedPref.getAlarmsFromPrefs();

    if (creating) {
      alarms.add(alarmSettings);
    } else {
      for (var i = 0; i < alarms.length; i++) {
        if (alarms[i].id == alarmSettings.id) {
          alarms[i] = alarmSettings;
          break;
        }
      }
    }
    alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    SharedPref.saveAlarmsToPrefs(alarms);

    Navigator.pop(context, true);
  }

  Future<void> deleteAlarm() async {
    Alarm.stop(widget.alarmSettings!.id).then((value) {
      print("asdlksadasjkldk $value");
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('edited', true);

    final alarms = await SharedPref.getAlarmsFromPrefs();

    for (var i = 0; i < alarms.length; i++) {
      if (alarms[i].id == widget.alarmSettings!.id) {
        alarms.removeAt(i);
        break;
      }
    }
    alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    print("asdsadsadsadsadsasdsasasdassd ${alarms.toList()}");
    SharedPref.saveAlarmsToPrefs(alarms);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Time Slot',
                style: TextStyle(color: Colors.black, fontSize: 16),
                // style: Theme.of(context)
                //     .textTheme
                //     .titleLarge!
                //     .copyWith(color: Colors.blueAccent),
              ),
              TextButton(
                onPressed:
                requestAlarmNotiPermission, // saveAlarm,requestAlarmNotiPermission
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.background),
                ),
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Done',
                    style: TextStyle(color: Colors.white, fontSize: 13)
                  // style: Theme.of(context)
                  //     .textTheme
                  //     .titleLarge!
                  //     .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          // Text(
          //   getDay(),
          //   style: Theme.of(context)
          //       .textTheme
          //       .titleMedium!
          //       .copyWith(color: Colors.blueAccent.withOpacity(0.8)),
          // ),
          RawMaterialButton(
            onPressed: pickTime,
            fillColor: Colors.grey[200],
            child: Container(
              margin: const EdgeInsets.all(30),
              child: Text(
                TimeOfDay.fromDateTime(selectedDateTime).format(context),
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: Colors.black, fontSize: 29),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loop alarm audio',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: loopAudio,
                onChanged: (value) => setState(() => loopAudio = value),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vibrate',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: vibrate,
                onChanged: (value) => setState(() => vibrate = value),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Custom volume',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: volume != null,
                onChanged: (value) =>
                    setState(() => volume = value ? 0.5 : null),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Alarm status: ${isSwitched ? 'ON' : 'OFF'}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = !isSwitched;
                  });
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.background,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey[300],
              ),
            ],
          ),
          SizedBox(
            height: 30,
            child: volume != null
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  volume! > 0.7
                      ? Icons.volume_up_rounded
                      : volume! > 0.1
                      ? Icons.volume_down_rounded
                      : Icons.volume_mute_rounded,
                ),
                Expanded(
                  child: Slider(
                    value: volume!,
                    onChanged: (value) {
                      setState(() => volume = value);
                    },
                  ),
                ),
              ],
            )
                : const SizedBox(),
          ),
          if (!creating)
            TextButton(
              onPressed: deleteAlarm,
              child: Text(
                'Delete Alarm',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.red),
              ),
            ),
          const SizedBox(),
        ],
      ),
    );
  }
}

class ExampleAlarmRingScreen extends StatelessWidget {
  const ExampleAlarmRingScreen({required this.alarmSettings, super.key});

  final AlarmSettings alarmSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'You alarm (${alarmSettings.id}) is-- ringing...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text('🔔', style: TextStyle(fontSize: 50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RawMaterialButton(
                  onPressed: () {
                    final now = DateTime.now();
                    Alarm.set(
                      alarmSettings: alarmSettings.copyWith(
                        dateTime: DateTime(
                          now.year,
                          now.month,
                          now.day,
                          now.hour,
                          now.minute,
                        ).add(const Duration(minutes: 1)),
                      ),
                    ).then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    'Snooze',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                RawMaterialButton(
                  onPressed: () {
                    Alarm.stop(alarmSettings.id)
                        .then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    'Stop',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExampleAlarmHomeShortcutButton extends StatefulWidget {
  const ExampleAlarmHomeShortcutButton({
    required this.refreshAlarms,
    super.key,
  });

  final void Function() refreshAlarms;

  @override
  State<ExampleAlarmHomeShortcutButton> createState() =>
      _ExampleAlarmHomeShortcutButtonState();
}

class _ExampleAlarmHomeShortcutButtonState
    extends State<ExampleAlarmHomeShortcutButton> {
  bool showMenu = false;

  Future<void> onPressButton(int delayInHours) async {
    var dateTime = DateTime.now().add(Duration(hours: delayInHours));
    double? volume;

    if (delayInHours != 0) {
      dateTime = dateTime.copyWith(second: 0, millisecond: 0);
      volume = 0.5;
    }

    setState(() => showMenu = false);

    final alarmSettings = AlarmSettings(
      id: DateTime.now().millisecondsSinceEpoch % 10000,
      dateTime: dateTime,
      assetAudioPath: 'assets/marimba.mp3',
      volume: volume,
      notificationTitle: 'Test Reminder',
      notificationBody: 'Do your eye test',
      enableNotificationOnKill: Platform.isIOS,
    );

    await Alarm.set(alarmSettings: alarmSettings);

    widget.refreshAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showMenu)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () => onPressButton(24),
                child: const Text('+24h'),
              ),
              TextButton(
                onPressed: () => onPressButton(36),
                child: const Text('+36h'),
              ),
              TextButton(
                onPressed: () => onPressButton(48),
                child: const Text('+48h'),
              ),
            ],
          ),
      ],
    );
  }
}

class ExampleAlarmTile extends StatelessWidget {
  const ExampleAlarmTile({
    required this.title,
    required this.onPressed,
    super.key,
    this.onDismissed,
  });

  final String title;
  final void Function() onPressed;
  final void Function()? onDismissed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: SizedBox(
        // Wrap the Card in a SizedBox to control its size
        height: 85, // Set height to 40
        child: Card(
          elevation: 0.4, // Adjust the elevation as needed
          margin: const EdgeInsets.symmetric(
              horizontal: 22, vertical: 8), // Adjust the margin as needed
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20), // Adjust the border radius as needed
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16, // Adjusted font size
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_right_rounded,
                    size: 24), // Adjusted icon size
              ],
            ),
          ),
        ),
      ),
    );
  }
}
