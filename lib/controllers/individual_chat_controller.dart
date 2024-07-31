import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import '../agora_code/agora_audio/voice_call_start.dart';
import '../agora_code/video_call_start.dart';
import '../agora_code/videocall_pojo.dart';

class IndividualChatController extends GetxController {

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getCallDetails();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    getCallDetails();
  }

  FirebaseAuth  _auth = FirebaseAuth.instance;

  /// call calling or ringing
  final _callringingornotstatus = "".obs;

  String get callringingornotstatus => _callringingornotstatus.value;

  set callringingornotstatus(String status) {
    _callringingornotstatus.value = status;
    update();
  }

  /// call active or disconnect
  final _callactiveornotstatus = true.obs;

  bool get callactiveornotstatus => _callactiveornotstatus.value;

  set callactiveornotstatus(bool status) {
    _callactiveornotstatus.value = status;
    update();
  }

  /// audio call active or disconnect
  final _audiocallactiveornotstatus = true.obs;

  bool get audiocallactiveornotstatus => _audiocallactiveornotstatus.value;

  set audiocallactiveornotstatus(bool status) {
    _audiocallactiveornotstatus.value = status;
    update();
  }

  /// audio call calling or ringing
  final _audiocallringingornotstatus = "".obs;

  String get audiocallringingornotstatus => _audiocallringingornotstatus.value;

  set audiocallringingornotstatus(String status) {
    _audiocallringingornotstatus.value = status;
    update();
  }

  final _userToken = "".obs;

  String get userToken => _userToken.value;

  set userToken(String flag) {
    _userToken.value = flag;
    update();
  }

  var chatIdd = "";

  String formatMillisecondsSinceEpoch(
      {String millisecondsSinceEpochString = "1693917692239"}) {
    // Convert the string back to an integer
    int millisecondsSinceEpoch = int.parse(millisecondsSinceEpochString);

    // Create a DateTime object from the milliseconds since epoch
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

    // Format the DateTime object to 'hh:mm' format
    String formattedTime = DateFormat('HH:mm').format(dateTime);

    return formattedTime;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      final format = DateFormat.jm();
      return format.format(dateTime);
    } else if (dateTime.year == now.year) {
      final format = DateFormat('MMM d');
      return format.format(dateTime);
    } else {
      final format = DateFormat('MMM d, y');
      return format.format(dateTime);
    }
  }

  ///agora setup start form here==============.
  void makeCall(userId, fname, imageUrl, channelId, context, lname) async {
    print("MAKE CALL RUNNING HERE");

    var userlist = [];
    userlist.add(userId);
    userlist.add(FirebaseAuth.instance.currentUser!.uid);
    userlist.sort();
    print(userlist.join('-'));
    Map<String, dynamic> userData = {
      "receiverid": userId,
      "receiverfname": fname,
      "receiverlname": lname,
      "receiverimage": imageUrl,
      "sendername": "Shantanu Singh",
      "senderimage": imageUrl,
      "senderid": FirebaseAuth.instance.currentUser!.uid,
      "channelid": channelId,
      'commonusers': [userId, FirebaseAuth.instance.currentUser!.uid],
      'activecall': true,
      'callingstatus': "calling",
      'calldisconnectby': '',
    };
    await FirebaseFirestore.instance.collection('Videocall').doc(userlist.join('-')).set(userData);
    print("CHAT CREATED HEREEE ${channelId}");
    await fetchDataforcreater(
        channelId, context, userId, fname, imageUrl, lname,"video");
    await getFirebaseTokenforcall(userId, channelId, fname, imageUrl,"video",true,false);
  }

  ///call ring ho raha ya nahi ye update krne k liye
  callringingornot(callid) async {
    Map<String, dynamic> userData = {
      'callingstatus': "ringing",
    };
    await FirebaseFirestore.instance.collection('Videocall').doc(callid).update(userData);
  }


  ///call disconnect
  leaveDisconnectCall(userId,context) async {
    Map<String, dynamic> userData = {
      'activecall': false,
      'calldisconnectby': FirebaseAuth.instance.currentUser!
    };
    await FirebaseFirestore.instance.collection('Videocall').doc(userId).update(userData);
    Navigator.pop(context);
  }

  fetchDataforcreater(
      channelName, context, userId, name, imageUrl, lname,calltype) async {
    // URL and request body
    const String url =
        'https://api.vegansmeetdaily.com/api/v1/users/create_agora_token';
    final Map<String, String> body = {
      'channel_name': channelName,
      'appId': '2b0bdd0de9f14d84bcff8fb037e452c3',
      'appCertificate': '18aaec564fbb4443a8d1f5d8345f205a',
    };

    // Make the HTTP POST request
    final response = await http.post(Uri.parse(url), body: body);

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Access the data field
      String token = responseData['data'];
if(calltype=="video"){
  Get.to(VideoCallScreen(
    imageUrl: imageUrl,
    fname: name,
    lname: lname,
    userId: userId,
    receivecall: true,
    channelId: channelName,
    agoratoken: responseData['data'],
  ));
}else {
  Get.to(VoiceCallScrenn(
    imageUrl: imageUrl,
    fname: name,
    lname: lname,
    userId: userId,
    receivecall: true,
    channelId: channelName,
    agoratoken: responseData['data'],
  ));
}

      // Handle the token as needed
      print('Token: $token');
    } else {
      // Handle errors
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  Future<String?> getFirebaseTokenforcall(
      userID, channelidd, name, imageUrl,calltype,isvideocall,isvoicecall) async {
    try {
      DocumentSnapshot docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc('${userID}').get();

      if (docSnapshot.exists) {
        Map<String, dynamic> userData =
            docSnapshot.data() as Map<String, dynamic>;
        String token = userData['token'];
        userToken = token;
        update();
        await sendNotificationToSelectedDriver("Video call", channelidd, userData['token'],
            userID, name, imageUrl,calltype,isvideocall,isvoicecall);
        return "";
      } else {
        print('Document does not exist for $userID');
      }
    } catch (e) {
      print('Error retrieving data: $e');
      return null;
    }
    return null;
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "agoravideocallapp-9c3c6",
      "private_key_id": "0876aeea5396f58ab556b5016b910376dc90ce2c",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCwq0I2DyGJMECw\nwyvxnWtIbqzc6lE76zY5IX9tQzq3SmdCxYSYZ469ucy/oDRzJbBzM+J6M4D7kqMi\nSDxPbuhAsFiLorT2DU3U3MIivfZSsyZ+kxZi/R+wg2fwjITfMg+ORPycln/3pSiC\nZRl3D558cZO4YtR6Cm0ek0rjFHMGa4zKf97ONOPLwaIER/yozzNs33ewKaKSYmAe\naBJgNe35FgfaV/keDeAy6VE6faTUgibLLiRFD6RLczR4J1keh2mc2Y61J+qaAv+z\nzK30Ufb3A/oWtbfJEqElFgqhYXrbzoc5it+/PvDFBKSbUiLAKR+WvcQQF/LDLle6\niRvn6HlXAgMBAAECggEAKa1VEtSx+B+yeyCnyrl0uCMn03vRix2bbpHY8kk0Xk4G\nmylmdN+lPFvLEf+0r99Zx2ubh3GEAZUft/Qrih+jWbNgSByrrQoJbOhhQfnnVK4f\nrCd91f9ZzPXK/OPhapfwNINQxo34hU7ohg5cmgpMvJW8n/hsoJe6E0bzGSvXUNGE\nWVSB1kZeLeiGlo1zK+9QNOG+hqVEdFvmGU++baShtFuNzqTr8o/1Rg+pZ9gN6+Sd\nPUNUYGalVAeEDygUfJ1x58Zj8jiE4zAfdBBbtcj3MKnSpXOY5ZZBCxC4CWv6sD7h\ncpQFVvkxKsd/xv6+TdrwhvZy3CNrK7SAgFR9EHT4ZQKBgQDvkC+APRTIBS0TcF+d\n7/4lrFEAm1KXTbzna7jwDrRCxfQQ3v9nqVvxwp4PIEdCmXTlCds4KBsdk99WQ0q9\nuHQatzmd7M7KrrA7I+U2d2xbTNAScyoOo7sMJwtUFRI22V8jeu0+reHGWluMXTND\nsVuSQhHYuJTYHejGpsYawFYSuwKBgQC8yl2QSXDn1gBAmnKWQI/gt/SMfCBBR4FP\nDOFCqr0ELROKLHy/Idr1FiSracrbmqR0/zfBjeyKlKAk/66wO/Gi8YI9UlZoRpN5\ntQXUhth2DwrxVEbdB0DNyleobgYxIzguU/9Ig5UuIE134BgC3zGXVWaI2fqVdwV/\nxspf7VPQFQKBgQCnYVivAv5oGqW59UP5d9tcux8Fi4CTUq9wCiX3JG7yUJkMyKIu\n7XfeXRpOe0EO2WWBOfe/LtZzPgRHo1CvahdFK0vIedKqbo+XYqcd/SbqS6r9mRWD\nkQZ5oTYbE3XceNguVA87QgaDrlJUqjHNVDgk4qDRiXYF4i/nzFKSElyRTQKBgGhB\nHGAUnlv4ipUidUrSBmIjU9HMrgc+lILx6udk4BKRTewM2yq1aHPVsZRTTKnvAQh2\n8/RYCpsQrksgQvihcbP4yGJSuNLGvqQEOl79xEWV0wYn8yYV3kyGg9fIQnUaLOkw\ni5Ygy934Cq+7OadEV99pUsEaFs45Nvkz7wgASDttAoGAciT9KdxjDzAjxMCe0CqN\nLToIq3KsNDLHL1hP8Nwbeli32a6BkpHLv79UEXN0cdFmkPolG504bBIcCCv4YPOL\nrCE8UcrfXlPfmU1PY8J+C81/uBN7ArlJbAqCyRuizmD0JmKekYxtOYJy5482WSNf\nZx1aGowlfsP6jBfIV9iBzVA=\n-----END PRIVATE KEY-----\n",
      "client_email": "agoranotification@agoravideocallapp-9c3c6.iam.gserviceaccount.com",
      "client_id": "102075755689445165570",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/agoranotification%40agoravideocallapp-9c3c6.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );
    // get the access token
    auth.AccessCredentials credentials =
    await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client);
    client.close();
    return credentials.accessToken.data;
  }

  Future<void> sendNotificationToSelectedDriver(
      messagee, channelid, token, userID, name, imageUrl,calltype,isvideocall,isvoicecall) async {
    final String serverAccessTokenKey = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/agoravideocallapp-9c3c6/messages:send';
    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {
          'title': "Agora",
          'body': "Join with Consultant",
        },
        "data": {
          "title": "Consultant",
          "body": messagee,
          "custom_key": "videocall",
          "videocall": isvideocall.toString(),
          "voicecall": isvoicecall.toString(),
          "channelid": channelid,
          "userid": _auth.currentUser!.uid,
          "receiverid": userID,
          "fname": name,
          "lname": name,
          "imageurl": imageUrl,
          "calltype":calltype
        },
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey'
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification Sent');
    } else {
      print('Notification Failed ${response.body}');
    }
  }

  // void sendNotificationforcall(
  //     message, channelid, token, userID, name, imageUrl,calltype,isvideocall,isvoicecall) async {
  //   // Define the FCM server URL and your server key
  //   const String url = 'https://fcm.googleapis.com/fcm/send';
  //   const String serverKey =
  //       'AAAANcFY6wc:APA91bGdR-KzHpXAzGitxe38XO_3WkO8m1aBwmY5jQ5WsiFhVOHyY1l5kfF7oPloUURyIVrE-LGKIGGxcpyc1Ujsh4DuzFXMrizpR0IL2E1FuzqtgHZGAjFmoCLfAat8Se3qdLKzz5JU'; // Replace with your actual server key
  //
  //   // Define the JSON payload to send
  //   final Map<String, dynamic> payload = {
  //     //
  //
  //     "data": {
  //       "title": "Video Call",
  //       "body": message,
  //       "custom_key": "videocall",
  //       "videocall": isvideocall,
  //       "voicecall":isvoicecall,
  //       "channelid": channelid,
  //       "userid": FirebaseAuth.instance.currentUser!, //ye jo call krega uska id hai,
  //       "receiverid": userID,
  //       "fname": "Anurag",
  //       "lname": "Kashyap",
  //       "imageurl": "",
  //       "calltype":calltype
  //     },
  //     "to": "$token"
  //   };
  //   print(payload);
  //
  //   // Define the headers, including the Authorization header with your server key
  //   final Map<String, String> headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'key=$serverKey',
  //   };
  //
  //   try {
  //     // Send the POST request to FCM
  //     final http.Response response = await http.post(
  //       Uri.parse(url),
  //       headers: headers,
  //       body: jsonEncode(payload),
  //     );
  //
  //     // Check the response status code
  //     if (response.statusCode == 200) {
  //       print("Notification sent successfully ${response.body}");
  //     } else {
  //       print(
  //           "Failed to send notification. Status code: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Error sending notification: $e");
  //   }
  // }

  Future<void> getCallDetails() async {

    var chatsCollection = FirebaseFirestore.instance
        .collection('Videocall')
        .where('commonusers', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .where('activecall', isEqualTo: true);
    Stream<QuerySnapshot> chatStream = chatsCollection.snapshots();

    chatStream.listen((QuerySnapshot chatQuerySnapshot) {
      if (chatQuerySnapshot.docs.isEmpty) {
        // No documents found
        print("No active calls found");
        _callactiveornotstatus(false);
        _callringingornotstatus("");
      }else{
        for (QueryDocumentSnapshot document in chatQuerySnapshot.docs) {
          Map<String, dynamic> chatData = document.data() as Map<String, dynamic>;
          VideoCallData videoCallData = VideoCallData.fromMap(chatData);
          print("CALL STATUS RUNNING");
          print(videoCallData.channelId);
          print(videoCallData.receiverfname);
          print(videoCallData.senderName);
          print(videoCallData.activeCall);
          _callactiveornotstatus(videoCallData.activeCall);
          _callringingornotstatus(videoCallData.callingstatus);
          update();
        }
      }
    });
  }





  ///agora audio call------------------audio call-----------------------audio call------------
  void makeAudioCall(userId, fname, imageUrl, channelId, context, lname) async {
    print("MAKE CALL RUNNING HERE");

    var userlist = [];
    userlist.add(userId);
    userlist.add(FirebaseAuth.instance.currentUser!.uid);
    userlist.sort();
    print(userlist.join('-'));
    Map<String, dynamic> userData = {
      "receiverid": userId,
      "receiverfname": fname,
      "receiverlname": lname,
      "receiverimage": imageUrl,
      "sendername": "Shantanu Singh",
      "senderimage": imageUrl,
      "senderid": FirebaseAuth.instance.currentUser!.uid,
      "channelid": channelId,
      'commonusers': [userId, FirebaseAuth.instance.currentUser!.uid],
      'activecall': true,
      'callingstatus': "calling",
      'calldisconnectby': '',

    };
    await FirebaseFirestore.instance.collection('Audiocall').doc(userlist.join('-')).set(userData);
    print("CHAT CREATED HEREEE ${channelId}");
    await fetchDataforcreater(
        channelId, context, userId, fname, imageUrl, lname,"audio");
    getFirebaseTokenforcall(userId, channelId, fname, imageUrl,"audio",false,true);
  }


  Future<void> getAudioCallDetails(String userId) async {

    var chatsCollection = FirebaseFirestore.instance
        .collection('Audiocall')
        .where('commonusers', arrayContains: userId)
        .where('activecall', isEqualTo: true);
    Stream<QuerySnapshot> chatStream = chatsCollection.snapshots();

    chatStream.listen((QuerySnapshot chatQuerySnapshot) {
      if (chatQuerySnapshot.docs.isEmpty) {
        // No documents found
        print("No active calls found");
        _audiocallactiveornotstatus(false);
        _audiocallringingornotstatus("");

      }else{
        for (QueryDocumentSnapshot document in chatQuerySnapshot.docs) {
          Map<String, dynamic> chatData = document.data() as Map<String, dynamic>;
          VideoCallData videoCallData = VideoCallData.fromMap(chatData);
          print("CALL STATUS RUNNING");
          print(videoCallData.channelId);
          print(videoCallData.receiverfname);
          print(videoCallData.senderName);
          print(videoCallData.activeCall);
          _audiocallactiveornotstatus(videoCallData.activeCall);
          _audiocallringingornotstatus(videoCallData.callingstatus);
          update();
        }
      }

    });
  }

  audiocallringingornot(callid) async {
    Map<String, dynamic> userData = {
      'callingstatus': "ringing",
    };
    await FirebaseFirestore.instance.collection('Audiocall').doc(callid).update(userData);
  }
}
