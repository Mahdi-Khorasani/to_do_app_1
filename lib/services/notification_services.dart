import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:to_do_app/ui/models/task.dart';
import 'package:to_do_app/ui/notified_page.dart';
class NotifyHelper{
  FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin(); //

  initializeNotification() async {
    _confiqureLocalTimezone();
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings("appicon");

    final InitializationSettings initializationSettings =
    InitializationSettings(
      iOS: initializationSettingsDarwin,
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  displayNotification({required String title, required String body}) async {
    print("doing test");
    var androidPlatformChannelSpecifics =
    new AndroidNotificationDetails(
        'your channel id', 'your channel name',
        importance: Importance.max, priority: Priority.high);

    var iOSPlatformChannelSpecifics = new DarwinNotificationDetails();
// ignore: unnecessary_new its for androids
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: title,
    );
  }

  scheduledNotification( int hour, int minutes, Task task) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id!.toInt(),
        task.title,
        task.note,
        _convertTime(hour, minutes)
,       // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails('your channel id',
                'your channel name', )),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: "${task.title}|"+"${task.note}|"
    );

  }

  tz.TZDateTime _convertTime(int hour, int minutes){
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime schedulDate =
        tz.TZDateTime(tz.local, now.year, now.month, hour, minutes);

    if(schedulDate.isBefore(now)){

      schedulDate = schedulDate.add(const Duration(days: 1));
    }
    return schedulDate;
  }

  Future<void> _confiqureLocalTimezone() async {
    tz.initializeTimeZones();
    final String timezone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone));
  }
  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    } else {
      debugPrint("Notification Done");
    }

    if(payload=="Theme Changed"){
      print("Nothing to navigate here get out");
    }else{
      Get.to(() =>NotifiedPage(label:payload));
    }


  }

/*Future selectNotification(String? payload) async {
if (payload != null) {
  print('notification payload: $payload');
} else {
  print("Notification Done");
}
Get.to(() => Container(
      color: Colors.white,
    ));
}*/

  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
// display a dialog with the notification details, tap ok to go to another page
/*showDialog(
  //context: context,
  builder: (BuildContext context) => CupertinoAlertDialog(
    title: Text(title),
    content: Text(body),
    actions: [
      CupertinoDialogAction(
        isDefaultAction: true,
        child: Text('Ok'),
        onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SecondScreen(payload),
            ),
          );
        },
      )
    ],
  ),
);*/
    Get.dialog(const Text("Wellcome"));
  }
}