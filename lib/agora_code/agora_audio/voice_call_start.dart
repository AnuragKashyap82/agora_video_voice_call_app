import 'dart:async';

import 'package:agora_video_voice_call_app/agora_code/constants.dart';
import 'package:agora_video_voice_call_app/controllers/individual_chat_controller.dart';
import 'package:agora_video_voice_call_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceCallScrenn extends StatefulWidget {
  final String fname;
  final String imageUrl;
  final String userId;
  final bool receivecall;
  final String channelId;
  final String agoratoken;
  final String lname;

  VoiceCallScrenn(
      {required this.fname,
      required this.imageUrl,
      required this.userId,
      required this.receivecall,
      required this.channelId,
      required this.agoratoken,
      required this.lname});

  @override
  State<VoiceCallScrenn> createState() => _VoiceCallScrennState();
}

class _VoiceCallScrennState extends State<VoiceCallScrenn> {
  ///call duration
  late Timer _callDurationTimer;
  int _callDurationInSeconds = 0;

  String get formattedCallDuration {
    // Convert seconds to HH:mm:ss format
    int hours = _callDurationInSeconds ~/ 3600;
    int minutes = (_callDurationInSeconds % 3600) ~/ 60;
    int seconds = _callDurationInSeconds % 60;
    String formattedTime = '';

    if (hours > 0) {
      formattedTime += '$hours:';
    }

    formattedTime += '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  bool _isCalldisconnet = false;

  late RtcEngine agoraEngine;
  bool _isJoined = false;
  int? _remoteUid;
  List<int> _remoteUids = [];
  bool _isMuted = false;

  Map<int, bool> remoteUserMuteStates = {};
  Map<int, bool> remoteUserMuteVideoStates = {};
  bool isUserMuted(int userId) {
    return remoteUserMuteStates[userId] ?? false; // Return false if the user ID is not in the map
  }

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    setupVoiceSDKEngine();
  }

  void showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> setupVoiceSDKEngine() async {
    try {
      await [Permission.microphone].request();
      agoraEngine = createAgoraRtcEngine();
      await agoraEngine.initialize(const RtcEngineContext(appId: MyConstants.agoraAppId));
      agoraEngine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          if (mounted) {
            showMessage("Local user joined the channel");
            setState(() {
              _isJoined = true;
            });
          }
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          if (mounted) {
            showMessage("Remote user joined the channel");
            setState(() {
              _remoteUid = remoteUid;
              _remoteUids.add(remoteUid);
              _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                if (mounted) {
                  setState(() {
                    _callDurationInSeconds++;
                  });
                }
              });
            });
          }
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          if (mounted) {
            showMessage("Remote user left the channel");
            setState(() {
              _remoteUid = null;
              _remoteUids.remove(remoteUid);
              if (_remoteUids.isEmpty) {
                _callDurationTimer.cancel();
                _isCalldisconnet = false;
                leave();
                Get.off(() => HomePage());
              }
            });
          }
        },
        onUserMuteAudio: (RtcConnection connection, int remoteUid, bool muted) {
          if (mounted) {
            setState(() {
              remoteUserMuteStates[remoteUid] = muted;
            });
          }
        },
        onUserMuteVideo: (RtcConnection connection, int remoteUid, bool muted) {
          if (mounted) {
            setState(() {
              remoteUserMuteVideoStates[remoteUid] = muted;
            });
          }
        },
      ));
      join();
    } catch (e) {
      showMessage("An error occurred: $e");
    }
  }


  void join() async {
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await agoraEngine.joinChannel(
      token: widget.agoratoken,
      channelId: widget.channelId,
      options: options,
      uid: 0,
    );
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
     agoraEngine.leaveChannel();
    if (Get.isRegistered<IndividualChatController>()) {
      Get.delete<IndividualChatController>();
    }
  }

  @override
  void dispose() async {
    // Cancel the timer to avoid memory leaks
    _callDurationTimer.cancel();
    // Leave the Agora channel and release resources
    agoraEngine.leaveChannel();

    // Clean up any GetX controllers if applicable
    if (Get.isRegistered<IndividualChatController>()) {
      Get.delete<IndividualChatController>();
    }

    // Any other custom resource cleanup
    super.dispose();

  }

  void toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    agoraEngine.muteLocalAudioStream(_isMuted);
  }

  @override
  Widget build(BuildContext context) {
    print("CHANNEL CHANNEL CHANNEL===========");
    print(widget.channelId);
    return Scaffold(
      backgroundColor: Colors.grey.shade200, // Example background color
      body: SafeArea(
        child: Stack(
          children: [
            // Contact Information
            Align(
                alignment: Alignment.topCenter,
                child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: _buildContactInfo())),

            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Local user audio tile
                    _buildUserTile(uid: 0, isLocal: true),
                    // Remote user audio tile (show only if a remote user joins)
                    if (_remoteUid != null)
                      _buildUserTile(uid: _remoteUid!, isLocal: false),
                  ],
                ),
              ),
            ),

            // Call Controls
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 58.0),
                child: _buildCallControls(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage:
                NetworkImage('${widget.imageUrl}'),
          ),
          const SizedBox(height: 15),
          Text(
            '${widget.fname} ${widget.lname}',
          ),
          const SizedBox(
            height: 10,
          ),
          if (_callDurationInSeconds > 0)
          Text(
            formattedCallDuration,
          ),
          // Additional details (optional)
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: ()async{
             leave();

             Get.off(() => const HomePage());
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: const Icon(Icons.call_end),
        ),
        const SizedBox(width: 20),

        ElevatedButton(
          onPressed: () => {
            toggleMute()
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child:  _isMuted ? Icon(Icons.mic_off):Icon(Icons.mic),
        ),
        // Additional controls (speakerphone, etc.)
      ],
    );
  }
  Widget _buildUserTile({required int uid, required bool isLocal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[300],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isLocal ? 'Local User' : 'Remote User'),
            const SizedBox(height: 10),
            // Replace with appropriate widget that displays audio activity (e.g., mic icon with pulsating animation)
            isLocal? _isMuted ?
            Icon(Icons.mic_off, size: 40,):Icon(Icons.mic, size: 40,):  isUserMuted(_remoteUid!) ?Icon(Icons.mic_off, size: 40): Icon(Icons.mic, size: 40),
            // Replace with a more appropriate widget

          ],
        ),
      ),
    );
  }
}
