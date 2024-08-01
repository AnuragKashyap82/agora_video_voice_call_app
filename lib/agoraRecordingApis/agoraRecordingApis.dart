import 'package:agora_video_voice_call_app/agora_code/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class RecordingApis{

  // Replace these values with your actual Agora credentials
   String key = "8e47a98b86c74bddaed7d68afaef4c18";
   String secret = "48a9724bf55f4505a7e3f3c040e9b735";

   String generateAuthHeader() {
     final credentials = '$key:$secret';
     final encodedCredentials = base64Encode(utf8.encode(credentials));
     return '$encodedCredentials';
   }

   Future<String> acquireResourceId(String channelName, String uid) async {
     try {
       final url = Uri.https(
         'api.agora.io',
         'v1/apps/${MyConstants.agoraAppId}/cloud_recording/acquire',
         {
           'cname': channelName,
           'uid': uid,
         },
       );

       String auth = generateAuthHeader();
       final response = await http.get(
         url,
         headers: {
           'Content-Type': 'application/json',
           'Authorization': "Basci $auth",
         },
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
    final url = 'https://api.agora.io/v1/apps/${MyConstants.agoraAppId}/cloud_recording/resourceid/$resourceId/mode/mix/start';
    String auth = generateAuthHeader();
    final response = await http.post(
      Uri.parse(url),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Basci $auth",
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
    final url = 'https://api.agora.io/v1/apps/${MyConstants.agoraAppId}/cloud_recording/resourceid/$resourceId/mode/mix/stop';
    String auth = generateAuthHeader();
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Basci $auth",
      },
      body: jsonEncode({
        "cname": channelName,
        "uid": uid,
      }),
    );

    print('Stop recording response: ${response.body}');
  }


}