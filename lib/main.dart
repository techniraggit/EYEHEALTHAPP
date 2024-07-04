
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:platform_device_id_v2/platform_device_id_v2.dart';
import 'package:project_new/HomePage.dart';
import 'package:project_new/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'FirebaseOptions/FirebaseApi.dart';
import 'api/firebase_options.dart';


final navigatorKey=GlobalKey<NavigatorState>();
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
bool isLoggedIn=false;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  print("message----1bavk"+message.notification!.body.toString());
  Map<String, dynamic> parsedJson = json.decode(message.notification!.body.toString());
  String description = parsedJson['data']['description'];
  String title = parsedJson['data']['title'];
  FirebaseApi().showNotification1(title, description);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Upgrader.clearSavedSettings(); // REMOVE this for release builds

  // FlutterAlarmBackgroundTrigger.initialize();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // await dotenv.load(fileName: ".env");

 await Alarm.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  await FirebaseApi().getdeviceToken();
  //foreground noti
  FirebaseApi();
  Stripe.publishableKey =
  'pk_test_51OJvAESInaGLb0MUv9RqwK5GqS1LhAWLWPfP2OVRyOzuVPepwaN9L58rWq3ixOUq39RKjkkjf2qUNjl782PntLLX00npNk74Y8';

  Fluttertoast.showToast;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isLoggedIn =  prefs.getBool('isLoggedIn') ?? false;
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  // runApp( PersistenBottomNavBarDemo());

  runApp( MyApp());
}

//
//
//
//
//
// //
// // class PersistenBottomNavBarDemo extends StatelessWidget {
// //   const PersistenBottomNavBarDemo({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) => MaterialApp(
// //     title: "Persistent Bottom Navigation Bar Demo",
// //     home: Builder(
// //       builder: (context) => Center(
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //
// //             ElevatedButton(
// //               onPressed: () =>
// //                   Navigator.of(context).pushNamed("/interactive"),
// //               child: const Text("Show Interactive Example"),
// //             ),
// //           ],
// //         ),
// //       ),
// //     ),
// //     routes: {
// //       "/interactive": (context) => const InteractiveExample(),
// //     },
// //   );
// // }
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// // class InteractiveExample extends StatefulWidget {
// //   const InteractiveExample({super.key});
// //
// //   @override
// //   State<InteractiveExample> createState() => _InteractiveExampleState();
// // }
// //
// // class _InteractiveExampleState extends State<InteractiveExample> {
// //   final PersistentTabController _controller = PersistentTabController();
// //   Settings settings = Settings();
// //
// //   List<PersistentTabConfig> _tabs() => [
// //     PersistentTabConfig(
// //       screen: const MainScreen(),
// //       item: ItemConfig(
// //         icon: const Icon(Icons.home),
// //         title: "Home",
// //         activeForegroundColor: Colors.blue,
// //         inactiveForegroundColor: Colors.grey,
// //       ),
// //     ),
// //     PersistentTabConfig(
// //       screen: const MainScreen(),
// //       item: ItemConfig(
// //         icon: const Icon(Icons.search),
// //         title: "Search",
// //         activeForegroundColor: Colors.teal,
// //         inactiveForegroundColor: Colors.grey,
// //       ),
// //     ),
// //     PersistentTabConfig.noScreen(
// //       item: ItemConfig(
// //         icon: const Icon(Icons.add),
// //         title: "Add",
// //         activeForegroundColor: Colors.blueAccent,
// //         inactiveForegroundColor: Colors.grey,
// //       ),
// //       onPressed: (context) {
// //         pushWithNavBar(
// //           context,
// //           DialogRoute(
// //             context: context,
// //             builder: (context) => const ExampleDialog(),
// //           ),
// //         );
// //       },
// //     ),
// //     PersistentTabConfig(
// //       screen: const MainScreen(),
// //       item: ItemConfig(
// //         icon: const Icon(Icons.message),
// //         title: "Messages",
// //         activeForegroundColor: Colors.deepOrange,
// //         inactiveForegroundColor: Colors.grey,
// //       ),
// //     ),
// //     PersistentTabConfig(
// //       screen: const MainScreen(),
// //       item: ItemConfig(
// //         icon: const Icon(Icons.settings),
// //         title: "Settings",
// //         activeForegroundColor: Colors.indigo,
// //         inactiveForegroundColor: Colors.grey,
// //       ),
// //     ),
// //   ];
// //
// //   @override
// //   Widget build(BuildContext context) =>
// //       PersistentTabView(
// //     controller: _controller,
// //     tabs: _tabs(),
// //     navBarBuilder: (navBarConfig) => settings.navBarBuilder(
// //       navBarConfig,
// //       NavBarDecoration(
// //         color: settings.navBarColor,
// //         borderRadius: BorderRadius.circular(10),
// //       ),
// //       const ItemAnimation(),
// //       const NeumorphicProperties(),
// //     ),
// //     floatingActionButton: FloatingActionButton(
// //       onPressed: () => showDialog(
// //         context: context,
// //         builder: (context) => Dialog(
// //           child: SettingsView(
// //             settings: settings,
// //             onChanged: (newSettings) => setState(() {
// //               settings = newSettings;
// //             }),
// //           ),
// //         ),
// //       ),
// //       child: const Icon(Icons.settings),
// //     ),
// //     backgroundColor: Colors.green,
// //     margin: settings.margin,
// //     avoidBottomPadding: settings.avoidBottomPadding,
// //     handleAndroidBackButtonPress: settings.handleAndroidBackButtonPress,
// //     resizeToAvoidBottomInset: settings.resizeToAvoidBottomInset,
// //     stateManagement: settings.stateManagement,
// //     onWillPop: (context) async {
// //       await showDialog(
// //         context: context,
// //         builder: (context) => Dialog(
// //           child: Center(
// //             child: ElevatedButton(
// //               child: const Text("Close"),
// //               onPressed: () {
// //                 Navigator.pop(context);
// //               },
// //             ),
// //           ),
// //         ),
// //       );
// //       return false;
// //     },
// //     hideNavigationBar: settings.hideNavBar,
// //     popAllScreensOnTapOfSelectedTab:
// //     settings.popAllScreensOnTapOfSelectedTab,
// //   );
// // }
//
//
// class MainScreen extends StatelessWidget {
//   const MainScreen({super.key, this.useRouter = false});
//
//   final bool useRouter;
//
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: const Text("Tab Main Screen")),
//     backgroundColor: Colors.indigo,
//     body: ListView(
//       padding: const EdgeInsets.all(16)
//           .copyWith(bottom: MediaQuery.of(context).padding.bottom),
//       children: <Widget>[
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//           child: TextField(
//             decoration: InputDecoration(hintText: "Test Text Field"),
//           ),
//         ),
//         Center(
//           child: ElevatedButton(
//             onPressed: () {
//               if (useRouter) {
//                 context.go("/settings/detail");
//               } else {
//                 pushScreen(
//                   context,
//                   withNavBar: true,
//                   settings: const RouteSettings(name: "/home"),
//                   screen: const MainScreen2(),
//                   pageTransitionAnimation:
//                   PageTransitionAnimation.scaleRotate,
//                 );
//               }
//             },
//             child: const Text("Go to Second Screen with Navbar"),
//           ),
//         ),
//         Center(
//           child: ElevatedButton(
//             onPressed: () {
//               if (useRouter) {
//                 context.go("/home/detail");
//               } else {
//                 pushScreen(
//                   context,
//                   settings: const RouteSettings(name: "/home"),
//                   screen: const MainScreen2(),
//                   pageTransitionAnimation:
//                   PageTransitionAnimation.scaleRotate,
//                 );
//               }
//             },
//             child: const Text("Go to Second Screen without Navbar"),
//           ),
//         ),
//         Center(
//           child: ElevatedButton(
//             onPressed: () {
//               showModalBottomSheet(
//                 context: context,
//                 backgroundColor: Colors.white,
//                 useRootNavigator: true,
//                 builder: (context) => Center(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Text("Exit"),
//                   ),
//                 ),
//               );
//             },
//             child: const Text("Push bottom sheet on TOP of Nav Bar"),
//           ),
//         ),
//         Center(
//           child: ElevatedButton(
//             onPressed: () {
//               showModalBottomSheet(
//                 context: context,
//                 backgroundColor: Colors.white,
//                 useRootNavigator: false,
//                 builder: (context) => Center(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Text("Exit"),
//                   ),
//                 ),
//               );
//             },
//             child: const Text("Push bottom sheet BEHIND the Nav Bar"),
//           ),
//         ),
//         Center(
//           child: ElevatedButton(
//             onPressed: () {
//               pushWithNavBar(
//                 context,
//                 DialogRoute(
//                   context: context,
//                   builder: (context) => const ExampleDialog(),
//                 ),
//               );
//             },
//             child: const Text("Push Dynamic/Modal Screen"),
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// class MainScreen2 extends StatelessWidget {
//   const MainScreen2({super.key, this.useRouter = false});
//
//   final bool useRouter;
//
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: const Text("Secondary Screen")),
//     backgroundColor: Colors.teal,
//     body: ListView(
//       padding: const EdgeInsets.all(16)
//           .copyWith(bottom: MediaQuery.of(context).padding.bottom),
//       children: <Widget>[
//         Center(
//           child: ElevatedButton(
//             onPressed: () {
//               if (useRouter) {
//                 context.go("/home/detail/super-detail");
//               } else {
//                 pushScreen(
//                   context,
//                   screen: const MainScreen3(),
//                   withNavBar: true,
//                 );
//               }
//             },
//             child: const Text("Go to Third Screen with Navbar"),
//           ),
//         ),
//         Center(
//           child: ElevatedButton(
//             onPressed: () {
//               if (useRouter) {
//                 context.go("/detail/super-detail");
//               } else {
//                 pushScreen(context, screen: const MainScreen3());
//               }
//             },
//             child: const Text("Go to Second Screen without Navbar"),
//           ),
//         ),
//         Center(
//           child: ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("Go Back to First Screen"),
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// class MainScreen3 extends StatelessWidget {
//   const MainScreen3({super.key});
//
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: const Text("Tertiary Screen")),
//     backgroundColor: Colors.deepOrangeAccent,
//     body: Center(
//       child: ElevatedButton(
//         onPressed: () {
//           Navigator.pop(context);
//         },
//         child: const Text("Go Back to Second Screen"),
//       ),
//     ),
//   );
// }
//
// class ExampleDialog extends StatelessWidget {
//   const ExampleDialog({super.key});
//
//   @override
//   Widget build(BuildContext context) => Dialog(
//     child: Container(
//       height: MediaQuery.of(context).size.height * 0.6,
//       width: MediaQuery.of(context).size.width * 0.3,
//       padding: const EdgeInsets.symmetric(horizontal: 30),
//       color: Colors.amber,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           const Text(
//             "This is a modal screen",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 26,
//             ),
//           ),
//           Center(
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text("Return"),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
//
//
//
//
//
//
// typedef NavBarBuilder = Widget Function(
//     NavBarConfig,
//     NavBarDecoration,
//     ItemAnimation,
//     NeumorphicProperties,
//     );
//
// class Settings {
//   bool hideNavBar = false;
//   bool resizeToAvoidBottomInset = true;
//   bool stateManagement = true;
//   bool handleAndroidBackButtonPress = true;
//   bool popAllScreensOnTapOfSelectedTab = true;
//   bool avoidBottomPadding = true;
//   Color navBarColor = Colors.white;
//   NavBarBuilder get navBarBuilder => navBarStyles[navBarStyle]!;
//   String navBarStyle = "Style 1";
//   EdgeInsets margin = EdgeInsets.zero;
//
//   Map<String, NavBarBuilder> navBarStyles = {
//     "Neumorphic": (p0, p1, p2, p3) => NeumorphicBottomNavBar(
//       navBarConfig: p0,
//       navBarDecoration: p1,
//       neumorphicProperties: p3,
//     ),
//     "Style 1": (p0, p1, p2, p3) =>
//         Style1BottomNavBar(navBarConfig: p0, navBarDecoration: p1),
//     "Style 2": (p0, p1, p2, p3) => Style2BottomNavBar(
//       navBarConfig: p0,
//       navBarDecoration: p1,
//       itemAnimationProperties: p2,
//     ),
//     "Style 3": (p0, p1, p2, p3) =>
//         Style3BottomNavBar(navBarConfig: p0, navBarDecoration: p1),
//     "Style 4": (p0, p1, p2, p3) => Style4BottomNavBar(
//       navBarConfig: p0,
//       navBarDecoration: p1,
//       itemAnimationProperties: p2,
//     ),
//     "Style 5": (p0, p1, p2, p3) =>
//         Style5BottomNavBar(navBarConfig: p0, navBarDecoration: p1),
//     "Style 6": (p0, p1, p2, p3) => Style6BottomNavBar(
//       navBarConfig: p0,
//       navBarDecoration: p1,
//       itemAnimationProperties: p2,
//     ),
//     "Style 7": (p0, p1, p2, p3) => Style7BottomNavBar(
//       navBarConfig: p0,
//       navBarDecoration: p1,
//       itemAnimationProperties: p2,
//     ),
//     "Style 8": (p0, p1, p2, p3) => Style8BottomNavBar(
//       navBarConfig: p0,
//       navBarDecoration: p1,
//       itemAnimationProperties: p2,
//     ),
//     "Style 9": (p0, p1, p2, p3) => Style9BottomNavBar(
//       navBarConfig: p0,
//       navBarDecoration: p1,
//       itemAnimationProperties: p2,
//     ),
//     "Style 10": (p0, p1, p2, p3) => Style10BottomNavBar(
//       navBarConfig: p0,
//       navBarDecoration: p1,
//       itemAnimationProperties: p2,
//     ),
//     "Style 11": (p0, p1, p2, p3) => Style11BottomNavBar(
//       navBarConfig: p0,
//       navBarDecoration: p1,
//       itemAnimationProperties: p2,
//     ),
//     "Style 12": (p0, p1, p2, p3) => Style12BottomNavBar(
//       navBarConfig: p0,
//       navBarDecoration: p1,
//       itemAnimationProperties: p2,
//     ),
//     "Style 13": (p0, p1, p2, p3) =>
//         Style13BottomNavBar(navBarConfig: p0, navBarDecoration: p1),
//     "Style 14": (p0, p1, p2, p3) =>
//         Style14BottomNavBar(navBarConfig: p0, navBarDecoration: p1),
//     "Style 15": (p0, p1, p2, p3) =>
//         Style15BottomNavBar(navBarConfig: p0, navBarDecoration: p1),
//     "Style 16": (p0, p1, p2, p3) =>
//         Style16BottomNavBar(navBarConfig: p0, navBarDecoration: p1),
//   };
// }
//
// class SettingsView extends StatefulWidget {
//   const SettingsView({
//     required this.settings,
//     required this.onChanged,
//     super.key,
//   });
//
//   final Settings settings;
//   final void Function(Settings) onChanged;
//
//   @override
//   State<SettingsView> createState() => _SettingsViewState();
// }
//
// class _SettingsViewState extends State<SettingsView> {
//   List<Color> colors = [
//     Colors.white,
//     Colors.black,
//     Colors.red,
//     Colors.green,
//     Colors.blue,
//     Colors.yellow,
//     Colors.orange,
//     Colors.purple,
//     Colors.grey,
//   ];
//
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.all(8),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       mainAxisSize: MainAxisSize.min,
//       children: <Widget>[
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             DropdownButton<Color>(
//               value: widget.settings.navBarColor,
//               icon: const Icon(Icons.arrow_downward),
//               elevation: 16,
//               onChanged: (value) {
//                 setState(() {
//                   widget.settings.navBarColor = value!;
//                 });
//                 widget.onChanged(widget.settings);
//               },
//               items: colors
//                   .map<DropdownMenuItem<Color>>(
//                     (value) => DropdownMenuItem<Color>(
//                   value: value,
//                   child: Container(
//                     width: 25,
//                     height: 25,
//                     decoration: BoxDecoration(
//                       color: value,
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.grey,
//                           spreadRadius: 2,
//                           blurRadius: 2,
//                         ),
//                       ],
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                 ),
//               )
//                   .toList(),
//             ),
//             const Text("NavBar Color"),
//           ],
//         ),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             DropdownButton<String>(
//               value: widget.settings.navBarStyle,
//               icon: const Icon(Icons.arrow_downward),
//               elevation: 16,
//               onChanged: (value) {
//                 setState(() {
//                   widget.settings.navBarStyle = value!;
//                 });
//                 widget.onChanged(widget.settings);
//               },
//               items: widget.settings.navBarStyles.keys
//                   .map<DropdownMenuItem<String>>(
//                     (value) => DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 ),
//               )
//                   .toList(),
//             ),
//             const Text("NavBar Style"),
//           ],
//         ),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("Margin LTRB:"),
//             const SizedBox(width: 4),
//             SizedBox(
//               width: 26,
//               child: TextFormField(
//                 initialValue:
//                 widget.settings.margin.left.toInt().toString(),
//                 decoration: const InputDecoration(
//                   isDense: true,
//                   border: OutlineInputBorder(),
//                   contentPadding: EdgeInsets.fromLTRB(4, 4, 4, 0),
//                 ),
//                 keyboardType: TextInputType.number,
//                 inputFormatters: <TextInputFormatter>[
//                   FilteringTextInputFormatter.digitsOnly,
//                 ],
//                 onChanged: (value) {
//                   setState(() {
//                     widget.settings.margin = widget.settings.margin
//                         .copyWith(left: double.tryParse(value) ?? 0);
//                   });
//                   widget.onChanged(widget.settings);
//                 },
//               ),
//             ),
//             const SizedBox(width: 4),
//             SizedBox(
//               width: 26,
//               child: TextFormField(
//                 initialValue: widget.settings.margin.top.toInt().toString(),
//                 decoration: const InputDecoration(
//                   isDense: true,
//                   border: OutlineInputBorder(),
//                   contentPadding: EdgeInsets.fromLTRB(4, 4, 4, 0),
//                 ),
//                 keyboardType: TextInputType.number,
//                 inputFormatters: <TextInputFormatter>[
//                   FilteringTextInputFormatter.digitsOnly,
//                 ],
//                 onChanged: (value) {
//                   setState(() {
//                     widget.settings.margin = widget.settings.margin
//                         .copyWith(top: double.tryParse(value) ?? 0);
//                   });
//                   widget.onChanged(widget.settings);
//                 },
//               ),
//             ),
//             const SizedBox(width: 4),
//             SizedBox(
//               width: 26,
//               child: TextFormField(
//                 initialValue:
//                 widget.settings.margin.right.toInt().toString(),
//                 decoration: const InputDecoration(
//                   isDense: true,
//                   border: OutlineInputBorder(),
//                   contentPadding: EdgeInsets.fromLTRB(4, 4, 4, 0),
//                 ),
//                 keyboardType: TextInputType.number,
//                 inputFormatters: <TextInputFormatter>[
//                   FilteringTextInputFormatter.digitsOnly,
//                 ],
//                 onChanged: (value) {
//                   setState(() {
//                     widget.settings.margin = widget.settings.margin
//                         .copyWith(right: double.tryParse(value) ?? 0);
//                   });
//                   widget.onChanged(widget.settings);
//                 },
//               ),
//             ),
//             const SizedBox(width: 4),
//             SizedBox(
//               width: 26,
//               child: TextFormField(
//                 initialValue:
//                 widget.settings.margin.bottom.toInt().toString(),
//                 decoration: const InputDecoration(
//                   isDense: true,
//                   border: OutlineInputBorder(),
//                   contentPadding: EdgeInsets.fromLTRB(4, 4, 4, 0),
//                 ),
//                 keyboardType: TextInputType.number,
//                 inputFormatters: <TextInputFormatter>[
//                   FilteringTextInputFormatter.digitsOnly,
//                 ],
//                 onChanged: (value) {
//                   setState(() {
//                     widget.settings.margin = widget.settings.margin
//                         .copyWith(bottom: double.tryParse(value) ?? 0);
//                   });
//                   widget.onChanged(widget.settings);
//                 },
//               ),
//             ),
//           ],
//         ),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Switch(
//               value: widget.settings.hideNavBar,
//               onChanged: (value) {
//                 setState(() {
//                   widget.settings.hideNavBar = value;
//                 });
//                 widget.onChanged(widget.settings);
//               },
//             ),
//             const Text("Hide Navigation Bar"),
//           ],
//         ),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Switch(
//               value: widget.settings.resizeToAvoidBottomInset,
//               onChanged: (value) {
//                 setState(() {
//                   widget.settings.resizeToAvoidBottomInset = value;
//                 });
//                 widget.onChanged(widget.settings);
//               },
//             ),
//             const Text("Resize to avoid bottom inset"),
//           ],
//         ),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Switch(
//               value: widget.settings.stateManagement,
//               onChanged: (value) {
//                 setState(() {
//                   widget.settings.stateManagement = value;
//                 });
//                 widget.onChanged(widget.settings);
//               },
//             ),
//             const Text("State Management"),
//           ],
//         ),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Switch(
//               value: widget.settings.handleAndroidBackButtonPress,
//               onChanged: (value) {
//                 setState(() {
//                   widget.settings.handleAndroidBackButtonPress = value;
//                 });
//                 widget.onChanged(widget.settings);
//               },
//             ),
//             const Text("Handle Android Back Button Press"),
//           ],
//         ),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Switch(
//               value: widget.settings.popAllScreensOnTapOfSelectedTab,
//               onChanged: (value) {
//                 setState(() {
//                   widget.settings.popAllScreensOnTapOfSelectedTab = value;
//                 });
//                 widget.onChanged(widget.settings);
//               },
//             ),
//             const Text("Pop all screens when\ntapping current tab"),
//           ],
//         ),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Switch(
//               value: widget.settings.avoidBottomPadding,
//               onChanged: (value) {
//                 setState(() {
//                   widget.settings.avoidBottomPadding = value;
//                 });
//                 widget.onChanged(widget.settings);
//               },
//             ),
//             const Text("Avoid bottom padding"),
//           ],
//         ),
//       ],
//     ),
//   );
// }
//
//
//
//
//
// class GoRouterExample extends StatelessWidget {
//   GoRouterExample({super.key});
//
//   final _parentKey = GlobalKey<NavigatorState>();
//   final _shellKey = GlobalKey<NavigatorState>();
//
//   final subRoutes = GoRoute(
//     path: "detail",
//     builder: (context, state) => const MainScreen2(
//       useRouter: true,
//     ),
//     routes: [
//       GoRoute(
//         path: "super-detail",
//         builder: (context, state) => const MainScreen3(),
//       ),
//     ],
//   );
//
//   late final GoRouter goRouter = GoRouter(
//     /// If you want the app to start on the first tab use this:
//     // initialLocation: "/home",
//     navigatorKey: _parentKey,
//     routes: [
//       GoRoute(
//         path: "/",
//         builder: (context, state) => Material(
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => context.go("/home"),
//                   child: const Text("Show Router Example"),
//                 ),
//                 const SizedBox(height: 16),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 32),
//                   child: Text(
//                     "This screen could be something you require the user to do before entering the main app content (like a login form)",
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         routes: [
//           StatefulShellRoute.indexedStack(
//             builder: (context, state, navigationShell) =>
//                 PersistentTabView.router(
//                   tabs: [
//                     PersistentRouterTabConfig(
//                       item: ItemConfig(
//                         icon: const Icon(Icons.home),
//                         title: "Home",
//                       ),
//                     ),
//                     PersistentRouterTabConfig(
//                       item: ItemConfig(
//                         icon: const Icon(Icons.message),
//                         title: "Messages",
//                       ),
//                     ),
//                     PersistentRouterTabConfig(
//                       item: ItemConfig(
//                         icon: const Icon(Icons.settings),
//                         title: "Settings",
//                       ),
//                     ),
//                   ],
//                   navBarBuilder: (navBarConfig) => Style1BottomNavBar(
//                     navBarConfig: navBarConfig,
//                   ),
//                   navigationShell: navigationShell,
//                 ),
//             branches: [
//               // The route branch for the 1st Tab
//               StatefulShellBranch(
//                 navigatorKey: _shellKey,
//                 routes: <RouteBase>[
//                   GoRoute(
//                     path: "home",
//                     builder: (context, state) => const MainScreen(
//                       useRouter: true,
//                     ),
//                     routes: [
//                       /// When you use the navigator Key that of the root navigator, this and all the sub routes will be pushed to the root navigator (-> without the navbar)
//                       GoRoute(
//                         parentNavigatorKey: _parentKey,
//                         path: "detail",
//                         builder: (context, state) => const MainScreen2(
//                           useRouter: true,
//                         ),
//                         routes: [
//                           GoRoute(
//                             path: "super-detail",
//                             builder: (context, state) => const MainScreen3(),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//
//               // The route branch for 2nd Tab
//               StatefulShellBranch(
//                 routes: <RouteBase>[
//                   GoRoute(
//                     path: "messages",
//                     builder: (context, state) => const MainScreen(
//                       useRouter: true,
//                     ),
//                     routes: [subRoutes],
//                   ),
//                 ],
//               ),
//
//               // The route branch for 3rd Tab
//               StatefulShellBranch(
//                 routes: <RouteBase>[
//                   GoRoute(
//                     path: "settings",
//                     builder: (context, state) => const MainScreen(
//                       useRouter: true,
//                     ),
//                     routes: [subRoutes],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     ],
//   );
//
//   @override
//   Widget build(BuildContext context) => MaterialApp.router(
//     title: "Persistent Bottom Navigation Bar Demo",
//     routerConfig: goRouter,
//   );
// }

















class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return
      MaterialApp(
        builder: EasyLoading.init(),
        home:SplashScreen(),//SplashScreen(),

        navigatorKey: navigatorKey,

          routes: isLoggedIn
              ? {
            '/notification_screen': (context) => SignIn(),
          }
              : {
            '/other_screen': (context) => HomePage(),
          },


        // theme: ThemeData.dark(),
        // routes: {'/notification_screen':(context)=>
        //     SignIn(),
        // },//Notificationpage(
        debugShowCheckedModeBanner: false,

      );

  }
}



class SplashScreen extends StatefulWidget {

  @override
  State<SplashScreen> createState() => Splash();
}

class Splash extends State<SplashScreen> {
  late Future<bool>isLoggedIn;
  @override
  void initState() {
    super.initState();
    isLoggedIn = checkLoggedIn();
    Timer(
      const Duration(seconds: 3),
          () async {
        // Check condition and navigate accordingly
        if (await isLoggedIn) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>HomePage(),
            ),
                (Route<dynamic> route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => OnBoardingScreen1(),
            ),
                (Route<dynamic> route) => false,
          );
        }
      },
    );

  }
  Future<bool> checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? rememberMe = prefs.getBool('isLoggedIn');
    return rememberMe??false;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/splashscreen.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }}
class OnBoardingScreen1 extends StatefulWidget {
  const OnBoardingScreen1({super.key});

  @override
  _OnBoardingScreen1State createState() => _OnBoardingScreen1State();
}

class _OnBoardingScreen1State extends State<OnBoardingScreen1> {
  String deviceId = '';String deviceToken='';String deviceType='';


  Future<void> initPlatformState() async {
    String? deviceId_;    String? deviceName_;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {


      deviceId_ = await PlatformDeviceId.getDeviceId;
      if (Platform.isAndroid){
        deviceName_="android";
      }
      if (Platform.isIOS){
        deviceName_="ios";
      }
    } on PlatformException {
      deviceId_ = null;
    }


    if (!mounted) return;

    setState(() async {
      deviceId = deviceId_!;
      deviceType = deviceName_!;
      print("deviceId->$deviceId");
      print("device_type->$deviceType");
      print("device_type->${ prefs.getString('device_token')}");



      await prefs.setString('device_id', deviceId);
      await prefs.setString('device_type', deviceType);

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if(Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print('Running on ${androidInfo.id}'); // e.g. "Moto G (4)"
      }
      if(Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        print('Running on ${iosInfo.identifierForVendor}');
      }// e.g. "iPod7,1"

// WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
// print('Running on ${webBrowserInfo.userAgent}');  // e.g. "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:61.0) Gecko/20100101 Firefox/61.0"
    });
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // To position the Row at the vertical end
          children: [
            const SizedBox(height: 40,),
            Image.asset(
              'assets/onboardingperson1.png', // Replace this with your image path
              width:MediaQuery.of(context).size.width,
            ),
            SvgPicture.asset(
              'assets/unevenline.svg', // Replace this with your image path
              // width:MediaQuery.of(context).size.width,
            ),
            const SizedBox(height: 40,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Welcome to Eye Health Your Personal Eye Health Companion',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // SizedBox(height: 20,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0,vertical: 15),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'This screen can introduce the app and its purpose',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),




            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  const SizedBox(width: 4,),
                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4600A9),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                  const SizedBox(width: 4,),

                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCEB0FA),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                  const SizedBox(width: 4,),

                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCEB0FA),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  // getDeviceInfo();
                  initPlatformState();

                  Navigator.push(context,
                      CupertinoPageRoute(builder:
                          (context) =>
                          OnBoardingScreen2()//change this in final step  SecondScreen
                      )
                  ) ;               },
                child: Padding(
                  padding:  EdgeInsets.symmetric(vertical:20,horizontal: MediaQuery.of(context).size.width/9),
                  child: SizedBox(
                    // height:17 ,width: 31,
                    child: Text(
                      'Skip',
                      style: TextStyle(fontSize: 14, color: Color(0xFF4600A9),fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),

      ),

    );
  }
}

class OnBoardingScreen2 extends StatefulWidget {
  @override
  _OnBoardingScreen2State createState() => _OnBoardingScreen2State();
}

class _OnBoardingScreen2State extends State<OnBoardingScreen2> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // To position the Row at the vertical end
          children: [
            const SizedBox(height: 60,),
            Image.asset(
              'assets/onboardperson2.png', // Replace this with your image path
              width:MediaQuery.of(context).size.width,
              height: 250,
            ),
            SvgPicture.asset(
              'assets/unevenline.svg', // Replace this with your image path
              // width:MediaQuery.of(context).size.width,
            ),
            const SizedBox(height: 40,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Monitor Eye Fatigue and Reduce Digital Strain',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // SizedBox(height: 20,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0,vertical: 15),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'This screen can introduce the app and its purpose',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),




            Padding(
              padding: const EdgeInsets.fromLTRB(25,10,25,2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  const SizedBox(width: 4,),
                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCEB0FA),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                  const SizedBox(width: 4,),

                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4600A9),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                  const SizedBox(width: 4,),

                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCEB0FA),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4,),

            SvgPicture.asset(
              'assets/lines.svg', // Replace this with your image path
              // width:MediaQuery.of(context).size.width,
            ),
            const SizedBox(width: 4,),

            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      CupertinoPageRoute(builder:
                          (context) =>
                          OnBoardingScreen3()//change this in final step  SecondScreen
                      )
                  );               },
                child:  Padding(
                  padding:  EdgeInsets.symmetric(vertical:20,horizontal: MediaQuery.of(context).size.width/9),

                  // padding: EdgeInsets.only(right: 18.0,top: 20,bottom: 20),
                  child: SizedBox(
                    // height:17 ,width: 31,
                    child: Text(
                      'Skip',
                      style: TextStyle(fontSize: 14, color: Color(0xFF4600A9),fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),

      ),

    );
  }
}

class OnBoardingScreen3 extends StatefulWidget {
  @override
  _OnBoardingScreen3State createState() => _OnBoardingScreen3State();
}

class _OnBoardingScreen3State extends State<OnBoardingScreen3> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // To position the Row at the vertical end
          children: [
            const SizedBox(height: 40,),
            Image.asset(
              'assets/onboardingperson3.png', // Replace this with your image path
              width:MediaQuery.of(context).size.width,
            ),
            // Image.asset(
            //   'assets/unevenline.png', // Replace this with your image path
            //   // width:MediaQuery.of(context).size.width,
            // ),
            const SizedBox(height: 40,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Comprehensive Eye Tests at Your Fingertips',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // SizedBox(height: 20,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0,vertical: 15),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'This screen can introduce the app and its purpose',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),




            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  const SizedBox(width: 4,),
                  Container(
                    width: 26,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCEB0FA),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                  const SizedBox(width: 4,),

                  Container(
                    width: 26,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCEB0FA),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                  const SizedBox(width: 4,),

                  Container(
                    width: 26,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4600A9),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 45.0,bottom: 20),
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder:
                            (context) =>
                            OnBoardingScreen2()//change this in final step  SecondScreen
                        )
                    )  ;              },
                  child: Container(
                    child:   ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignIn()),
                        );

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4600A9),
                        // Text color
                        // padding: EdgeInsets.all(16),
                        minimumSize: const Size(270, 50),
                        // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                          // Button border radius
                        ),
                      ),
                      child: const Text('Get Started',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 16),),
                    ),

                  ),
                ),
              ),
            ),

          ],
        ),

      ),

    );
  }
}




























