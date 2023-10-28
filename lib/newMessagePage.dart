import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import 'config.dart';
import 'individualChatPage.dart';

class NewMessagePage extends StatefulWidget {
  const NewMessagePage({super.key});

  @override
  State<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  List<dynamic> arrEmails = [];
  List<dynamic> arrNames = [];
  List<dynamic> arrIcons = [];
  bool isLoading = false;
  var userEmail = '';
  bool atLeastOneMsgSent = false;
  void suggestedUsers() async {
    setState(() {
      isLoading = true;
    });
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "token");
    userEmail = (await storage.read(key: "userEmail"))!;
    // print('token is $token');
    final response = await http.get(
      Uri.parse(suggestedUsersUrl),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // print("suggested Users $jsonResponse");
      setState(() {
        arrNames = jsonResponse.map((item) => item["name"]).toList();
        arrEmails = jsonResponse.map((item) => item["email"]).toList();
        arrIcons = jsonResponse.map((item) => item['imgPath']).toList();
        // print(arrNames);
        // print(arrEmails);
        // print(arrIcons);
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    suggestedUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Message"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
            child: const Text(
              "Suggested People",
              style: TextStyle(
                color: Color(0xFF5B5B5B),
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                // height: 0.12,
              ),
            ),
          ),
          Expanded(
            // height:  MediaQuery.of(context).size.height-200,
            child: Card(
              margin: const EdgeInsets.only(top: 10, right: 15, left: 15),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: isLoading
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey.withOpacity(0.4),
                        highlightColor: Colors.white,
                        period: const Duration(seconds: 1),
                        child: ListView.builder(
                          itemCount: 10,
                            itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 5.0),
                                child: ListTile(
                                  leading: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(35),
                                        color: Colors.grey.withOpacity(0.9)),
                                  ),
                                  title: Container(
                                    height: 20,
                                    width: 200,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Colors.grey.withOpacity(0.9)),
                                  ),
                                ),
                              ),
                              const Divider(height: 2),
                            ],
                          );
                        }),
                      )
                    : arrNames.isNotEmpty ?
                        ListView.builder(
                        itemCount: arrNames.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 5.0),
                                child: ListTile(
                                  onTap: () async {
                                    final targetEmailId = arrEmails[index];
                                    atLeastOneMsgSent = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => IndividualChatPage(
                                          name: arrNames[index],
                                          icon: arrIcons[index],
                                          targetEmailId: targetEmailId,
                                          userEmailId: userEmail,
                                          newMsg: true,
                                        ),
                                      ),
                                    );
                                    if(atLeastOneMsgSent){
                                      Navigator.pop(context, atLeastOneMsgSent);
                                    }
                                  },
                                  leading: CircleAvatar(
                                    radius: 30.0,
                                    backgroundImage: NetworkImage(arrIcons[index]),
                                  ),
                                  title: Text(
                                    arrNames[index],
                                    style: const TextStyle(
                                      color: Color(0xFF5B5B5B),
                                      fontSize: 20,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      // height: 0.12,
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(height: 2),
                            ],
                          );
                        })
                    :
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/anims/notFoundAnim.json',
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain),
                          const Text(
                            "No New People Yet!",
                            style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            // height: 0.12,
                          ),
                          ),
                        ],
                      ),
                    )

              ),
            ),
          ),
        ],
      ),
    );
  }
}
