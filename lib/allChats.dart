import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_authentication_flutter/individualChatPage.dart';
import 'package:http/http.dart' as http;
import 'package:user_authentication_flutter/newMessagePage.dart';

import 'config.dart';

class AllChats extends StatefulWidget {
  final String userEmailId;
  const AllChats({super.key, required this.userEmailId});

  @override
  State<StatefulWidget> createState() => _AllChatsState();
}

class _AllChatsState extends State<AllChats> {
  List<dynamic> arrTargetEmailIds = [];
  List<dynamic> arrNames = [];
  List<dynamic> arrIcons = [];
  List<dynamic> arrCurrMsgs = [];
  bool isLoading = false;
  // var arrCurrMsgs = ["this is the first message","this is the second message","this is the 3 message","4th message","5th message"];//still to be fetched

  Future<void> fetchBasicDetails(List<dynamic> targetEmails) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "token");
    final queryParams = {'targetEmails': targetEmails.join(',')};
    final uri =
        Uri.parse(getBasicDetailsUrl).replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> extractedNames =
          jsonResponse.map((item) => item['name']).toList();
      List<dynamic> extractedImgPaths =
          jsonResponse.map((item) => item['imgPath']).toList();

      setState(() {
        arrTargetEmailIds = jsonResponse;
        arrNames = extractedNames;
        arrIcons = extractedImgPaths;
        isLoading = false;
      });
    } else {
      //print("error");
      setState(() {
        isLoading = false;
      });
    }
  }

  fetchTargetEmails() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: "token");
    //print("token from chat section is $token");
    final response = await http.get(
      Uri.parse(fetchTargetEmailsUrl),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> extractedTargetEmails =
          jsonResponse.map((item) => item["targetEmail"]).toList();
      List<dynamic> extractedCurrMsgs = jsonResponse.map((item) {
        if (item["lastMessage"]["type"] == 'sentMsg') {
          return item['lastMessage']['text'].length > 26
              ? 'You: ${(item["lastMessage"]["text"]).substring(0, 27)}...'
              : 'You: ${item["lastMessage"]["text"]}';
        } else {
          return item["lastMessage"]["text"].length > 26
              ? '${(item["lastMessage"]["text"]).substring(0, 27)}...'
              : item["lastMessage"]["text"];
        }
      }).toList();
      setState(() {
        arrTargetEmailIds = extractedTargetEmails;
        arrCurrMsgs = extractedCurrMsgs;
      });
    } else {
      print("failed to fetch response");
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    fetchTargetEmails().then((_) {
      fetchBasicDetails(arrTargetEmailIds);
    });
  }

  Future<void> refreshData() async {
    setState(() {
      isLoading = true;
    });
    fetchTargetEmails().then((_) {
      fetchBasicDetails(arrTargetEmailIds);
    });
    // Called setState to rebuild the widget with the updated data
    setState(() {});
  }

  Future<void> _handleRefresh() async {
    Timer(Duration(milliseconds: 3200), () {
      setState(() {
        isLoading = true;
      });
      fetchTargetEmails().then((_) {
        fetchBasicDetails(arrTargetEmailIds);
      });
      // Called setState to rebuild the widget with the updated data
      setState(() {});
    });
    return await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Container(
              padding:
                  const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8),
              decoration: ShapeDecoration(
                // color: const Color(0xFF1E232C),
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: InkWell(
                onTap: () async {
                  bool atLeastOneMsgSent = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewMessagePage(),
                    ),
                  );
                  if (atLeastOneMsgSent) {
                    refreshData();
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message_rounded,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'New',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
          ]),
        ],
      ),
      body: isLoading
          ? ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 7.0),
                        child: Row(
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey.withOpacity(0.4),
                              highlightColor: Colors.white,
                              period: const Duration(seconds: 1),
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(35),
                                    color: Colors.grey.withOpacity(0.9)),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Colors.grey.withOpacity(0.4),
                                  highlightColor: Colors.white,
                                  period: const Duration(seconds: 1),
                                  child: Container(
                                    height: 14,
                                    width: 150,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(35),
                                        color: Colors.grey.withOpacity(0.9)),
                                  ),
                                ),
                                Shimmer.fromColors(
                                  baseColor: Colors.grey.withOpacity(0.4),
                                  highlightColor: Colors.white,
                                  period: const Duration(seconds: 1),
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    height: 10,
                                    width: 250,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(35),
                                        color: Colors.grey.withOpacity(0.9)),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              })
          : LiquidPullToRefresh(
              onRefresh: _handleRefresh,
              color: Colors.white,
              height: 200,
              backgroundColor: Colors.deepPurple[200],
              animSpeedFactor: 2.0,
              showChildOpacityTransition: false,
              child: arrNames.length!=0?
              ListView.builder(
                itemCount: arrNames.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 0.0),
                    child: Card(
                      surfaceTintColor: Colors.white,
                      elevation: 1,
                      child: ListTile(
                        onTap: () async {
                          final targetEmailId =
                              arrTargetEmailIds[index]['email'];
                          bool atLeastOneMsgSent = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IndividualChatPage(
                                name: arrNames[index],
                                icon: arrIcons[index],
                                targetEmailId: targetEmailId,
                                userEmailId: widget.userEmailId,
                                newMsg: false, //for skeleton ui
                              ),
                            ),
                          );
                          if (atLeastOneMsgSent) {
                            refreshData();
                          }
                        },
                        leading: CircleAvatar(
                          radius: 30.0,
                          backgroundImage: NetworkImage(arrIcons[index]),
                        ),
                        title: Text(
                          arrNames[index],
                          style: const TextStyle(
                            color: Color(0xFF161616),
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            // height: 0.08,
                          ),
                        ),
                        subtitle: Text(
                          arrCurrMsgs[index],
                          style: const TextStyle(
                            color: Color(0xFF5B5B5B),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            // height: 0.12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
                  :
              ListView(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset('assets/anims/sadEmojiAnim.json',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain),
                        const Text(
                          "No Conversations Yet !",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            // height: 0.12,
                          ),
                        ),
                        const Text(
                          "Tap on New button to message anyone",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            // height: 0.12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              )
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const NewMessagePage(),
      //       ),
      //     );
      //   },
      //   child: const Icon(Icons.message_rounded),
      // ),
    );
  }
}
