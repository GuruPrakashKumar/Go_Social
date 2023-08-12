// import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:user_authentication_flutter/Home_page.dart';

import 'package:user_authentication_flutter/uploadProfileImage.dart';
import 'config.dart';

class Signin_page extends StatefulWidget{
  const Signin_page({super.key});

  @override
  State<Signin_page> createState() => _SignInPageState();

}

class _SignInPageState extends State<Signin_page>{
  var loginEmailText = TextEditingController();
  var loginPassText = TextEditingController();
  // final storage = new FlutterSecureStorage();
  final storage = const FlutterSecureStorage(); //this const improves performance

  void loginUser() async{
    if(loginEmailText.text.isNotEmpty && loginPassText.text.isNotEmpty){
      var regBody = {
        "email":loginEmailText.text,
        "password":loginPassText.text
      };

      var response = await http.post(
          Uri.parse(loginUrl),
          headers: {"Content-Type":"application/json"}, //it is a request header that indicates request body is in json format
          body: jsonEncode(regBody)
      );
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData.containsKey("message") && responseData["message"] == "Invalid credentials") {
          print("login failed: Invalid credentials");
        } else {
          print("login successful");
          print(responseData["auth"]);
          await storage.write(key: "token", value: responseData["auth"]);

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => UploadProfileImage()),
          // );

          Get.to(()=>const UploadProfileImage());//used Get.to() to navigate to next page instead of Navigator.push() for increasing performance
        }
      } else {
        print("login failed: Server error");
      }
    } else {
      print("email or password is not provided");
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SignIn"),
      ),
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(

                controller: loginEmailText,
                // enabled: false,
                decoration: InputDecoration(
                  hintText: 'Email',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueAccent,width: 2)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueGrey,width: 2)
                  ),

                  prefixIcon: Icon(Icons.email,color:Colors.deepOrange),
                ),
              ),
              Container(height: 11,),
              TextField(
                // keyboardType: TextInputType.phone,
                controller: loginPassText,
                obscureText: true,
                obscuringCharacter: '*',
                decoration: InputDecoration(
                  hintText: 'password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueAccent,width: 2)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueGrey,width: 2)
                  ),
                ),
              ),
              ElevatedButton(onPressed: (){
                String uEmail = loginEmailText.text;
                String uPass = loginPassText.text;
                loginUser();


                // registerUser();
                print("Email: $uEmail, Pass: $uPass");
              }, child: Text('Login')),
            ],
          ),
        ),
      ),
    );
  }

}
