import 'package:agora_video_voice_call_app/login_scren.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'agora_code/makevideocall.dart';
import 'controllers/individual_chat_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<void> saveToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print("FCM Token: $token");
    Map<String, dynamic> userData = {
      'token': '$token',
    };
    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update(userData);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveToken();
  }

  var controller = Get.put(IndividualChatController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text("Home Page"),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(onPressed: ()async{
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> LoginScreen()));
          }, icon: Icon(Icons.login, color: Colors.black,))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while waiting for data
                  return Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.pinkAccent,));
                } else if (snapshot.hasError) {
                  // Show an error message if an error occurs
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // Show a message if no data is available
                  return Center(child: Text('No data available'));
                } else {
                  // Build a list of items from the snapshot data
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var document = snapshot.data!.docs[index];
                      var data = document.data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 42,
                                  width: 42,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade300
                                  ),
                                  child: Center(child: Icon(Icons.person, color: Colors.grey.shade200,)),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                      child: Text(data['email'] ?? 'No Field', overflow: TextOverflow.ellipsis, maxLines: 1,)),
                                ),

                                IconButton(onPressed: ()async{
                                  if(data['email'] == FirebaseAuth.instance.currentUser!.email){

                                  }else{
                                    DateTime time = DateTime.now();
                                    var channelid = '${time.millisecondsSinceEpoch}';
                                    controller.makeAudioCall(
                                        data['uid'],
                                        'Anurag',
                                        'https://plus.unsplash.com/premium_photo-1664536392896-cd1743f9c02c?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',//ImageUrl
                                        channelid,
                                        context,
                                        'Kashyap');
                                  }


                                }, icon: Icon(Icons.call_end_outlined,color: data['email'] == FirebaseAuth.instance.currentUser!.email?Colors.grey.shade200:Colors.green,)),
                                IconButton(onPressed: ()async{
                                  if(data['email'] == FirebaseAuth.instance.currentUser!.email){

                                  }else{
                                    DateTime time = DateTime.now();
                                    var channelid = '${time.millisecondsSinceEpoch}';
                                    controller.makeCall(
                                        data['uid'],
                                        'Anurag',
                                        'https://plus.unsplash.com/premium_photo-1664536392896-cd1743f9c02c?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',//ImageUrl
                                        channelid,
                                        context,
                                        'Kashyap');
                                  }


                                }, icon: Icon(Icons.video_call,color: data['email'] == FirebaseAuth.instance.currentUser!.email?Colors.grey.shade200:Colors.green,)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
            SizedBox(
              height: 16,
            ),
            // SizedBox(
            //   height: 16,
            // ),
            // GestureDetector(
            //   onTap: (){
            //     DateTime time = DateTime.now();
            //     var channelid =
            //         '${time.millisecondsSinceEpoch}';
            //     controller.makeCall(
            //         'w30aMhbMyxTmzsdJ5wroNPyYsEs2',
            //         'Shantanu Singh',
            //         '',
            //         channelid,
            //         context,
            //         'Singh');
            //   },
            //   child: Container(
            //     height: 60,
            //     width: MediaQuery.of(context).size.width,
            //     decoration: BoxDecoration(
            //       color: Colors.pinkAccent,
            //       borderRadius: BorderRadius.circular(10)
            //     ),
            //     child: Center(child: Text("Satrt Video Call")),
            //   ),
            // ),
            // SizedBox(
            //   height: 16,
            // ),
            // GestureDetector(
            //   onTap: (){
            //     DateTime time = DateTime.now();
            //     var channelid =
            //         '${time.millisecondsSinceEpoch}';
            //     controller.makeAudioCall(
            //         'w30aMhbMyxTmzsdJ5wroNPyYsEs2',
            //         'Shantanu Singh',
            //         '',
            //         channelid,
            //         context,
            //         'Singh');
            //   },
            //   child: Container(
            //     height: 60,
            //     width: MediaQuery.of(context).size.width,
            //     decoration: BoxDecoration(
            //         color: Colors.pinkAccent,
            //         borderRadius: BorderRadius.circular(10)
            //     ),
            //     child: Center(child: Text("Satrt Voice Call")),
            //   ),
            // ),
            // SizedBox(
            //   height: 16,
            // ),
            // GestureDetector(
            //   onTap: (){
            //     controller.sendNotificationToSelectedDriver("messagee", "channelid", "token", "userID", "name", "imageUrl", "calltype", "true", "false");
            //   },
            //   child: Container(
            //     height: 60,
            //     width: MediaQuery.of(context).size.width,
            //     decoration: BoxDecoration(
            //         color: Colors.green,
            //         borderRadius: BorderRadius.circular(10)
            //     ),
            //     child: Center(child: Text("Send Notification")),
            //   ),
            // ),
            // SizedBox(
            //   height: 16,
            // ),
            // GestureDetector(
            //   onTap: (){
            //     Get.to(CallReceiveScreen(
            //       imageUrl: "imageUrl",
            //       fname: "Shantanu",
            //       lname: "Singh",
            //       userId: "W45ZyYuidYWNrZEycq8ROIV13tZ2",
            //       receivecall: true,
            //       channelId: "1722249887696",
            //       receiverid: "w30aMhbMyxTmzsdJ5wroNPyYsEs2",
            //     ));
            //   },
            //   child: Container(
            //     height: 60,
            //     width: MediaQuery.of(context).size.width,
            //     decoration: BoxDecoration(
            //         color: Colors.green,
            //         borderRadius: BorderRadius.circular(10)
            //     ),
            //     child: Center(child: Text("Recieve Video Call")),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
