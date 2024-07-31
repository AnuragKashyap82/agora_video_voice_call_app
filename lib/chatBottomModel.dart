import 'package:flutter/material.dart';

class ChatBottomModel extends StatefulWidget {
  final List<String> messages;
  final VoidCallback sendMessage;
  final TextEditingController controller;
  const ChatBottomModel({super.key, required this.messages, required this.sendMessage, required this.controller});

  @override
  State<ChatBottomModel> createState() => _ChatBottomModelState();
}

class _ChatBottomModelState extends State<ChatBottomModel> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: MediaQuery.of(context).size.width),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              height: 18,
                              width: 18,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                  Border.all(color: Colors.black, width: 2)),
                              child: const Center(
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: 14,
                                  ))),
                          const SizedBox(
                            width: 8,
                          ),
                          const Text(
                            "Messages",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                fontFamily: "Bold"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
        const Divider(
          color: Color(0xffE5E5E5),
        ),
        const SizedBox(
          height: 16,
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.69,
          child: ListView.builder(
            itemCount: widget.messages.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(widget.messages[index]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,

                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(26)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: widget.controller,
                      decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "Enter your messsage"
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(onPressed: (){
                widget.sendMessage;
              }, icon: Icon(Icons.done_all, color: Colors.blue,))
            ],
          ),
        )
      ],
    );
  }
}
