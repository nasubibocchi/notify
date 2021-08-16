import 'dart:convert';
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'addPush.dart';


/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message ${message.messageId}");
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
  enableVibration: true,
  playSound: true,
);

/// Initalize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(ProviderScope(child: MessagingExampleApp()));
}

/// Entry point for the example application.
class MessagingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messaging Example App',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => Application(),
        '/addPush': (context) => AddPush(),
      },
      // home: Application(),
    );
  }
}


// Crude counter to make messages unique
int _messageCount = 0;

/// push通知送信で送る内容
String constructFCMPayload(String token) {
  _messageCount++;
  return jsonEncode({
    'token': token,
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': _messageCount.toString(),
    },
    'priority': 'high',
    'notification': {
      'title': 'Hello FlutterFire!',
      'body': 'This notification (#$_messageCount) was created via FCM!',
    },
  });
}

///grobal変数としてexportedToken（トークンを代入したもの）を作っておく
String? exportedToken;

/// Renders the example application.＠stateful widget
class Application extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {
  String? _token;

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
    ///tokenの取得
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //       print('A new onMessageOpenedApp event was published!');
    //       Navigator.pushNamed(context, '/message',
    //           arguments: MessageArguments(message, true));
    //     });

    // String token = FirebaseMessaging.instance.getToken().toString();
    FirebaseMessaging.instance.getToken().then((token){
      assert(token != null);
          setState(() {
        _token = token!;
        exportedToken = token;
      });
      print('-------------token: $token');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('A new onMessageOpenedApp event was published!');
      print(message);
      Navigator.push(
        context,
        MaterialPageRoute(
          //TODO: 通知をタップしたときに開くページを設定する
          builder: (context) => Application(),
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cloud Messaging"),
      ),
      body: SingleChildScrollView(
        child: TextButton(
          onPressed: () => Navigator.of(context).pushNamed('/addPush'),
          child: Text('Push通知設定へ'),),
      ),
    );
  }
}






