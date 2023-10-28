import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:user_authentication_flutter/Home_page.dart';
import 'package:user_authentication_flutter/navigation_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final storage = const FlutterSecureStorage();
  var isLoggedIn = '';
  var userEmail = '';

  @override
  void initState() {
    super.initState();
    void loginStatus() async {
      isLoggedIn = (await storage.read(key:"loggedIn"))!;
      userEmail = (await storage.read(key: "userEmail"))!;
    }
    loginStatus();
    Timer(const Duration(seconds: 2),(){
      if(isLoggedIn.isNotEmpty){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> NavigationPage(userEmailId: userEmail)));
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const HomePage()));
      }
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey.shade100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/splashIcon.png",),
              const SizedBox(height: 20,),
              const Text("Go Social", style: TextStyle(
                fontSize: 34,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: Colors.black
              ),)
            ],
          ),
        ),
      ),
    );
  }
}
