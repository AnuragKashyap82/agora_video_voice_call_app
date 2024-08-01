import 'package:agora_video_voice_call_app/login_scren.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'agora_code/agora_audio/voicecall_receve.dart';
import 'agora_code/makevideocall.dart';
import 'controllers/individual_chat_controller.dart';
import 'home_page.dart';

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications',
  importance: Importance.high,
  enableVibration: true,
  playSound: true
);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  showNotification(message);
  handleVideoCallNotification(message);
}

void showNotification(RemoteMessage message, {bool isVideoCall = false}) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification?.title,
    notification?.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        playSound: true,
        icon: "@mipmap/ic_launcher",
      ),
    ),
  );
}

void handleVideoCallNotification(RemoteMessage message) {
  var videoChannelId = message.data?['channelid'];
  var fname = message.data?['fname'];
  var calleruserId = message.data?['userid'];
  var imageUrl = message.data?['imageurl'];
  var lname = message.data?['lname'];
  var receiverId = message.data?['receiverid'];

  var myController = Get.isRegistered<IndividualChatController>()
      ? Get.find<IndividualChatController>()
      : Get.put(IndividualChatController());

  var userlist = [receiverId, calleruserId]..sort();
  var userJoin = userlist.join('-');
  print("IN NOTIFICATION CALLING STATUS UPDATE  ${userJoin}");
  var isvideocall = message.data?['videocall'];
  var isaudiocall = message.data?['voicecall'];

  if (isvideocall == "true") {
    myController.callringingornot(userJoin);
    myController.getCallDetails();
    Get.to(CallReceiveScreen(
      imageUrl: imageUrl,
      fname: fname,
      lname: lname,
      userId: calleruserId,
      receivecall: true,
      channelId: videoChannelId,
      receiverid: receiverId,
    ));
  } else if (isaudiocall == "true") {
    myController.audiocallringingornot(userJoin);
    myController.getAudioCallDetails(receiverId);
    Get.to(MakeVoiceCall(
      imageUrl: imageUrl,
      fname: fname,
      lname: lname,
      userId: calleruserId,
      receivecall: true,
      channelId: videoChannelId,
      receiverid: receiverId,
    ));
  }

  showNotification(message, isVideoCall: true);
}

void handleRegularNotification(RemoteMessage message) {
  showNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data?['videocall'] == "true" ||
        message.data?['voicecall'] == "true") {
      handleVideoCallNotification(message);
    } else {
      showNotification(message, isVideoCall: false);
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
    if (message?.data?['videocall'] == "true" ||
        message?.data?['voicecall'] == "true") {
      handleVideoCallNotification(message!);
    } else {
      handleRegularNotification(message!);
    }
  });

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Agora Voice and Video Call',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return HomePage();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
