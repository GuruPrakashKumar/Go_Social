import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:user_authentication_flutter/Home_page.dart';
import 'package:user_authentication_flutter/Signin_page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'config.dart';

void main() {
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // var emailText = TextEditingController();
  var passText = TextEditingController();
  var nameText = TextEditingController();
  final storage = const FlutterSecureStorage();
  var errorTextVal = '';
  bool isLoading = false;

  void _capitalizeName() {
    //To capitalize the first character of name
    final currentText = nameText.text;
    if (currentText.isNotEmpty) {
      nameText.text = currentText.toLowerCase().split(' ').map((word) {
        return word[0].toUpperCase() + word.substring(1);
      }).join(' ');
      nameText.selection = TextSelection.fromPosition(//not needed to check
          TextPosition(offset: nameText.text.length));
    }
  }

  void registerUser() async {
    _capitalizeName();
    final token = await storage.read(key: "token");
    if (passText.text.isNotEmpty && nameText.text.isNotEmpty) {
      //TODO: don't send imgPath set it from backend
      var regBody = {
        "name": nameText.text,
        "password": passText.text,
        "imgPath":
            'https://res.cloudinary.com/dvmjj1jwt/image/upload/v1698135020/default_dp.jpg'
      };

      var response = await http.post(Uri.parse(registration),
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(regBody));
      var responseData = jsonDecode(response.body);
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 404 ||
          response.statusCode == 400 ||
          response.statusCode == 409) {
        if (responseData.containsKey("message")) {
          setState(() {
            errorTextVal = responseData["message"];
          });
        }
        print("registration not successful");
      } else if (response.statusCode == 401) {
        setState(() {
          errorTextVal = 'Session Expired, Verify Email again';
        });
        print("registration failed");
        print("401 status code from signup");
      } else if (response.statusCode == 500) {
        setState(() {
          errorTextVal = 'Internal Server Error';
        });
        print("registration failed");
        print("500 status code from signup");
      } else if (response.statusCode == 200) {
        Navigator.pop(context);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const Signin_page()));
      }
    } else {
      setState(() {
        errorTextVal = 'Please Enter Your Name and Password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      //i removed the app bar for now to check if it looks better
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
            child: SizedBox(
                width: 331,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 331,
                      child: Text(
                        'Hello! Register to get started',
                        style: TextStyle(
                          color: Color(0xFF1E232C),
                          fontSize: 30,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w700,
                          height: 1.30,
                          letterSpacing: -0.30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      //name text field
                      controller: nameText,
                      // enabled: false,
                      maxLength: 30,
                      maxLines: 1,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF7F8F9),
                        hintText: 'Name',
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            const BorderSide(color: Colors.red, width: 1.2)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            const BorderSide(color: Colors.red, width: 1.2)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF1E232C), width: 1.2)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1)),
                        prefixIcon: const Icon(Icons.person_rounded,
                            color: Colors.grey),
                      ),
                    ),
                    Container(
                      height: 11,
                    ),
                    TextField(
                      maxLines: 1,
                      // keyboardType: TextInputType.phone,
                      controller: passText,
                      obscureText: true,
                      obscuringCharacter: '*',
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF7F8F9),
                        hintText: 'Password',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF1E232C), width: 1.2)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1)),
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 30),
                    StatefulBuilder(
                      builder: (context, n) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              isLoading = true;
                            });
                            if (nameText.text.trim() == '') {
                              setState(() {
                                errorTextVal = 'Please Enter Your Name';
                                isLoading = false;
                              });
                            } else {
                              registerUser();
                            }
                          },
                          child: Hero(
                            tag: "registerButtonAnimation",
                            child: SizedBox(
                              width: 331,
                              height: 56,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Container(
                                      width: 331,
                                      height: 56,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF1E232C),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: isLoading ? 90 : 138,
                                    top: isLoading ? 0 : 19,
                                    child: isLoading
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.only(
                                                        right: 10, top: 10),
                                                child: Lottie.asset(
                                                    'assets/anims/registeringAnim.json',
                                                    width: 28,
                                                    height: 28,
                                                    fit: BoxFit.fitHeight),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 15),
                                                child: const Text(
                                                    'Registering..',
                                                    textAlign:
                                                        TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontFamily: 'Urbanist',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    )),
                                              )
                                            ],
                                          )
                                        : const Text(
                                            'Register',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontFamily: 'Urbanist',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 11),
                    Container(
                      child: errorTextVal != ''
                          ? Text(
                              errorTextVal,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : const Text(""),
                    ),
                    const SizedBox(height: 26),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Signin_page()));
                            // Get.to(()=>const Signin_page());
                          },
                          child: const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(
                                    color: Color(0xFF032426),
                                    fontSize: 15,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w500,
                                    height: 1.40,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Login Now',
                                  style: TextStyle(
                                    color: Color(0xFF34C2C1),
                                    fontSize: 15,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w700,
                                    height: 1.40,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ],
                ))),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
