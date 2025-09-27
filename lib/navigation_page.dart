import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:user_authentication_flutter/allChats.dart';
import 'package:user_authentication_flutter/blogs_page.dart';
import 'package:user_authentication_flutter/config.dart';
import 'package:user_authentication_flutter/notifications_services.dart';
import 'package:user_authentication_flutter/uploadProfileImage.dart';
import 'package:http/http.dart' as http;

class NavigationPage extends StatefulWidget {
  final String userEmailId;
  const NavigationPage({Key? key,required this.userEmailId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((deviceToken){
      // print("device token: ");
      updateDeviceToken(deviceToken);
      // print(deviceToken);
    });
  }
  void updateDeviceToken(String deviceToken) async{
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "token");
    var data={
      "deviceToken":deviceToken
    };
    var response = await http.post(Uri.parse(updateDeviceTokenUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabController.index,
        children: [
          const BlogsPage(),
          AllChats(userEmailId: widget.userEmailId,),
          const UploadProfileImage(),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
          child: GNav(
            rippleColor: const Color(0xFFF5F5F5), // tab button ripple color when pressed
            hoverColor: const Color(0xFFF5F5F5), // tab button hover color
            haptic: true, // haptic feedback
            backgroundColor: Colors.grey.shade100,
            color: Colors.black,
            activeColor: Colors.black,
            padding: const EdgeInsets.all(14),
            tabBorderRadius: 100,
            tabBorder: Border(
              top: BorderSide(width: 2.0, color: Colors.grey.shade100),
              bottom: BorderSide(width: 2.0, color: Colors.grey.shade100),
              left: BorderSide(width: 2.0, color: Colors.grey.shade100),
              right: BorderSide(width: 2.0, color: Colors.grey.shade100),

            ),
            tabActiveBorder: const Border(
              top: BorderSide(width: 2.0, color: Color(0xFF1E232C)),
              bottom: BorderSide(width: 2.0, color: Color(0xFF1E232C)),
              left: BorderSide(width: 2.0, color: Color(0xFF1E232C)),
              right: BorderSide(width: 2.0, color: Color(0xFF1E232C)),

            ),
            gap: 8,
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.chat,
                text: 'Chats',
              ),
              GButton(
                icon: Icons.person_rounded,
                text: 'Profile',
              ),
            ],
            selectedIndex: _tabController.index,
            onTabChange: (index) {
              setState(() {
                _tabController.index = index;
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
