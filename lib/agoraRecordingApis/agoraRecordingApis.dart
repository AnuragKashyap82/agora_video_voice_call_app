import 'package:agora_video_voice_call_app/agora_code/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class RecordingApis{

  // Replace these values with your actual Agora credentials
   String appId = MyConstants.agoraAppId;
   String appCertificate = MyConstants.agoraCertificateId;

   String generateAuthHeader() {
     final credentials = '$appId:$appCertificate';
     final encodedCredentials = base64Encode(utf8.encode(credentials));
     return '$encodedCredentials';
   }

   Future<String> acquireResourceId(String channelName, String uid) async {
     try {
       final url = 'https://api.agora.io/v1/apps/$appId/cloud_recording/acquire';
       String auth = generateAuthHeader();
       final response = await http.post(
         Uri.parse(url),
         headers: {
           'Content-Type': 'application/json',
           'Authorization': auth,
         },
         body: jsonEncode({
           'cname': channelName,
           'uid': uid,
         }),
       );
       if (response.statusCode == 200) {
         final responseBody = jsonDecode(response.body);
         if (responseBody['resourceId'] != null) {
           return responseBody['resourceId'];
         } else {
           return 'Failed to acquire resource ID: No resourceId in response';
         }
       } else {
         return 'Failed to acquire resource ID: ${response.body}';
       }
     } catch (e) {
       return 'Exception occurred: $e';
     }
   }

  Future<void> startRecording(String resourceId, String channelName, String uid) async {
    final url = 'https://api.agora.io/v1/apps/$appId/cloud_recording/resourceid/$resourceId/mode/mix/start';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic ${base64Encode(utf8.encode('$appId:$appCertificate'))}',
      },
      body: jsonEncode({
        "cname": channelName,
        "uid": uid,
        "clientRequest": {
          "recordingFileConfig": {
            "avFormat": "mp4",
            "maxIdleTime": 120
          },
          "streamType": 0
        }
      }),
    );

    print('Start recording response: ${response.body}');
  }

  Future<void> stopRecording(String resourceId, String channelName, String uid) async {
    final url = 'https://api.agora.io/v1/apps/$appId/cloud_recording/resourceid/$resourceId/mode/mix/stop';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic ${base64Encode(utf8.encode('$appId:$appCertificate'))}',
      },
      body: jsonEncode({
        "cname": channelName,
        "uid": uid,
        "clientRequest": {}
      }),
    );

    print('Stop recording response: ${response.body}');
  }


}