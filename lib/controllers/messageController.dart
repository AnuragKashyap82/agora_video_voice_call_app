import 'package:get/get.dart';

class MessageController extends GetxController {
  var messages = <String>[].obs;

  void addMessage(String message) {
    messages.add(message);
  }
}
