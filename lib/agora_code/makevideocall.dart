import 'dart:convert';
import 'package:agora_video_voice_call_app/agora_code/video_call_start.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../controllers/individual_chat_controller.dart';
import '../home_page.dart';
import 'constants.dart';

class CallReceiveScreen extends StatefulWidget {
  final String fname;
  final String imageUrl;
  final String userId;
  final bool receivecall;
  final String channelId;
  final String lname;
  final String receiverid;

  CallReceiveScreen(
      {required this.fname,
      required this.imageUrl,
      required this.userId,
      required this.receivecall,
      required this.channelId,
      required this.lname,
      required this.receiverid});

  @override
  State<CallReceiveScreen> createState() => _CallReceiveScreenState();
}

class _CallReceiveScreenState extends State<CallReceiveScreen> {
  var userToken = "";
  var controller = Get.find<IndividualChatController>();

  void fetchDatareceiver(channelName) async {
    // URL and request body
    const String url =
        'https://api.vegansmeetdaily.com/api/v1/users/create_agora_token';
    final Map<String, String> body = {
      'channel_name': channelName,
      'appId': MyConstants.agoraAppId,
      'appCertificate': MyConstants.agoraCertificateId,
    };

    // Make the HTTP POST request
    final response = await http.post(Uri.parse(url), body: body);

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Access the data field
      String token = responseData['data'];
      setState(() {
        userToken = responseData['data'];
      });

      // Handle the token as needed
      print('Token: $token');
    } else {
      // Handle errors
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDatareceiver(widget.channelId);
    controller.getCallDetails();
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      body: GetBuilder<IndividualChatController>(builder: (controller) {
        return
          Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            controller.callactiveornotstatus == true
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60.0),
                       Text(
                        'Incoming Video Call',
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${widget.fname} ${widget.lname}',
                        style:
                             TextStyle(fontSize: 16, color: Colors.grey.shade300, fontWeight: FontWeight.bold),
                      ),
                      Expanded(child  : const SizedBox(height: 40.0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade300
                            ),
                            child: Center(
                              child: IconButton(
                                icon: const Icon(
                                  Icons.call_end,
                                  color: Colors.red,
                                  size: 24.0,
                                ),
                                onPressed: () {
                                  Get.off(HomePage());
                                },
                              ),
                            ),
                          ),
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade300
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.call,
                                color: Colors.green,
                                size: 24.0,
                              ),
                              onPressed: () {
                                // Add logic for accepting the call
                                Get.to(VideoCallScreen(
                                    imageUrl: widget.imageUrl,
                                    fname: widget.fname,
                                    userId: widget.userId,
                                    receivecall: true,
                                    channelId: widget.channelId,
                                    agoratoken: userToken,
                                    lname: ''));
                                print('Call Accepted');
                              },
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 80.0)
                    ],
                  )
                : const Center(
                    child: Text(
                      "Call disconnect",
                      style: TextStyle(color: Colors.black, fontSize: 12.0),
                    ),
                  ),
            const SizedBox(height: 20),
          ],
        );
      }),
          );
  }
}
