import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
//AudioPlayer audioPlayer = AudioPlayer();

void printHello() async {
  late AudioPlayer player;
  player = AudioPlayer();
  final DateTime now = DateTime.now();
  debugPrint("[$now] Hello, all of the world! function='$printHello'");
  await player.setAsset('assets/moo.mp3');
  player.play();
}

void main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
          onDidReceiveLocalNotification:
              (int id, String? title, String? body, String? payload) async {});
  const MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false);
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? string) => {debugPrint(string)});
  runApp(const MyApp());
}

void onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chronote',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Chronote!!!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _scheduleNotification() async {
    if (Platform.isIOS) {
      debugPrint('We called scheduleNotification');
      tz.initializeTimeZones();
      final String currentTimeZone =
          await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));

      var scheduledTime =
          tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
      await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          'Chronote chime!',
          'it is $scheduledTime',
          scheduledTime,
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  'your channel id', 'your channel name',
                  channelDescription: 'your channel description',
                  playSound: true,
                  enableVibration: false,
                  channelShowBadge: false,
                  sound: RawResourceAndroidNotificationSound('moo')),
              iOS: IOSNotificationDetails(sound: 'moo.mp3')),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    } else if (Platform.isAndroid) {
      debugPrint('we\'re innn them android, queueing a sound for that');
      const int alarmId = 0;
      const String localPath = 'moo.mp3';

      const int helloAlarmID = 0;
      /*
      await AndroidAlarmManager.periodic(
          const Duration(seconds: 5), helloAlarmID, printHello);
          */

      AndroidAlarmManager.oneShot(
          const Duration(minutes: 2), alarmId, printHello,
          wakeup: true, alarmClock: true, rescheduleOnReboot: true);
    }
  }

  Future<void> _allowNotifications() async {
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: false,
          badge: false,
          sound: true,
        );
    debugPrint('$result');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).

          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('First, allow notifications',
                style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _allowNotifications,
              child: const Icon(Icons.notification_add),
            ),
            const SizedBox(height: 20),
            Text('Then, schedule a chime',
                style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleNotification,
              child: const Icon(Icons.notifications_active),
            )
          ],
        ),
      ),
    );
  }
}
