import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_authentication_flutter/CustomUI/OwnMessageCard.dart';
import 'package:user_authentication_flutter/CustomUI/ReplyCard.dart';
import 'package:user_authentication_flutter/Models/ChatModel.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:user_authentication_flutter/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'Models/MessageModel.dart';

class IndividualChatPage extends StatefulWidget {
  final String name;
  final String icon;
  final String targetEmailId;
  final String userEmailId;
  bool newMsg;

  IndividualChatPage(
      {super.key,
      required this.name,
      required this.icon,
      required this.targetEmailId,
      required this.userEmailId,
      required this.newMsg});

  @override
  State<StatefulWidget> createState() => _IndividualChatPageState();
}

class _IndividualChatPageState extends State<IndividualChatPage> {
  late IO.Socket socket;
  final TextEditingController _sendMessageController = TextEditingController();
  List<MessageModel> messageList = [];
  bool atLeastSentOneMsg = false;
  bool isLoading = false;
  // ScrollController _scrollController = ScrollController();
  FocusNode _messageFieldFocus = FocusNode();
  late KeyboardVisibilityController _keyboardVisibilityController;
  void socketConnect() {
    socket = IO.io(url, <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": "false",
    });
    socket.connect();
    socket.emit('signin', widget.userEmailId);
    socket.onConnect((data) {
      print("socket connected");
      socket.on("message", (msg) {
        print("received msg" + msg.toString());
        setMessage("receivedMsg", msg["message"]);
      });
    });
  }

  Future<void> fetchMessages() async {
    //to test this
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "token");
    var toSend = {
      "targetEmail": widget.targetEmailId,
    };
    var response = await http.post(Uri.parse(getChatHistoryUrl),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(toSend));
    // print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> messagesJson = jsonDecode(response.body);
      List<MessageModel> fetchedMessages = messagesJson.map((message) {
        return MessageModel(
          type: message['type'],
          message: message['text'],
        );
      }).toList();
      setState(() {
        messageList = fetchedMessages;
        isLoading = true;
        // print("msg list = ");
        // print(messageList);
      });
    } else {
      print("Failed to fetch chat history");
      setState(() {
        isLoading = true;
      });
    }
  }

  void setMessage(String type, String message) {
    // print('executing set message');
    MessageModel messageModel = MessageModel(type: type, message: message);
    setState(() {
      // messageList.add(messageModel);
      atLeastSentOneMsg = true;
      messageList.insert(0, messageModel);
      widget.newMsg = false;
    });
  }

  void sendMessage(String message, String senderEmail, String targetEmail) {
    setMessage("sentMsg", message);
    socket.emit(
      "message",
      {
        "message": message,
        "senderEmail": senderEmail,
        "targetEmail": targetEmail
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchMessages();
    socketConnect();
    // _scrollController = ScrollController();
    // _keyboardVisibilityController = KeyboardVisibilityController();
    // _keyboardVisibilityController.onChange.listen((bool visible) {
    //   if (visible) {
    //     _scrollController.animateTo(
    //       _scrollController.position.maxScrollExtent,
    //       duration: const Duration(milliseconds: 200),
    //       curve: Curves.easeOut,
    //     );
    //   }
    // });

    // Scroll to the bottom of the list when the chat page is opened
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   _scrollController.animateTo(
    //     _scrollController.position.maxScrollExtent,
    //     duration: const Duration(milliseconds: 200),
    //     curve: Curves.easeOut,
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(
          children: [
            CircleAvatar(
              // this is for user profile picture
              backgroundImage: NetworkImage(widget.icon),
            ),
            const SizedBox(width: 8),
            Text(
              widget.name,
              style: const TextStyle(
                color: Color(0xFF1E232C),
                fontSize: 24,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, atLeastSentOneMsg);
          return true;
        },
        child: SizedBox(
          //this is for chat Background
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          // color: Colors.grey.shade100,
          child: Stack(
            children: [
              Image.asset(
                "assets/images/chat-bg2.jpg",
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              Column(
                children: [
                  widget.newMsg
                      ? Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                color: Colors.white,
                                child: Center(
                                  child: Column(
                                    children: [
                                      Lottie.asset(
                                          'assets/anims/helloAnim.json',
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.fitHeight),
                                      const Text(
                                        "Say Hi !",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          // height: 0.12,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : isLoading
                          ? Expanded(
                              child: ListView.builder(
                                reverse: true,
                                // controller: _scrollController,
                                itemCount: messageList.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  if (messageList[index].type == "sentMsg") {
                                    return OwnMessageCard(
                                        message: messageList[index].message);
                                  } else {
                                    return ReplyCard(
                                        message: messageList[index].message);
                                  }
                                },
                              ),
                            )
                          : Expanded(
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.withOpacity(0.4),
                                highlightColor: Colors.white,
                                period: const Duration(seconds: 1),
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: 15, top: 10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color:
                                                  Colors.grey.withOpacity(0.9)),
                                          height: 40,
                                          width: 200,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              right: 15, top: 20),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color:
                                                  Colors.grey.withOpacity(0.9)),
                                          height: 40,
                                          width: 250,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              right: 15, top: 8),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color:
                                                  Colors.grey.withOpacity(0.9)),
                                          height: 40,
                                          width: 100,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              right: 15, top: 8),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color:
                                                  Colors.grey.withOpacity(0.9)),
                                          height: 40,
                                          width: 150,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: 15, top: 20),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color:
                                                  Colors.grey.withOpacity(0.9)),
                                          height: 40,
                                          width: 150,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: 15, top: 8),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color:
                                                  Colors.grey.withOpacity(0.9)),
                                          height: 40,
                                          width: 100,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              right: 15, top: 8),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color:
                                                  Colors.grey.withOpacity(0.9)),
                                          height: 40,
                                          width: 120,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              right: 15, top: 8),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color:
                                                  Colors.grey.withOpacity(0.9)),
                                          height: 80,
                                          width: 250,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: 15, top: 20),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color:
                                                  Colors.grey.withOpacity(0.9)),
                                          height: 40,
                                          width: 180,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: 15, top: 8),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color:
                                                  Colors.grey.withOpacity(0.9)),
                                          height: 40,
                                          width: 50,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 66,
                          child: Card(
                            margin: const EdgeInsets.only(
                                left: 6, right: 6, bottom: 8, top: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                              side: const BorderSide(
                                // Add this to set border properties
                                color: Colors.black, // Border color
                                width: 1.0, // Border width
                              ),
                            ),
                            child: Center(
                              child: TextFormField(
                                focusNode: _messageFieldFocus,
                                controller: _sendMessageController,
                                style: const TextStyle(fontSize: 19),
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                minLines: 1,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Type a message",
                                  contentPadding: EdgeInsets.all(15),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 8, right: 5, left: 2, top: 6),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 28,
                              child: IconButton(
                                icon: const Icon(Icons.send_rounded),
                                onPressed: () {
                                  // _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200),curve: Curves.easeOut);
                                  sendMessage(
                                      _sendMessageController.text.trim(),
                                      widget.userEmailId,
                                      widget.targetEmailId);
                                  _sendMessageController.clear();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
