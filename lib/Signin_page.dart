// import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:user_authentication_flutter/Home_page.dart';
import 'package:user_authentication_flutter/main.dart';
import 'package:user_authentication_flutter/navigation_page.dart';
import 'package:user_authentication_flutter/signUpInitPage.dart';

import 'package:user_authentication_flutter/uploadProfileImage.dart';
import 'config.dart';

class Signin_page extends StatefulWidget {
  const Signin_page({super.key});

  @override
  State<Signin_page> createState() => _SignInPageState();
}

class _SignInPageState extends State<Signin_page> {
  var loginEmailText = TextEditingController();
  var loginPassText = TextEditingController();
  // final storage = new FlutterSecureStorage();
  var errorTextVal = '';
  var errorLoginTextVal = '';
  var errorPassTextVal = '';
  bool isLoading = false;
  final storage =
      const FlutterSecureStorage(); //this const improves performance

  void loginUser() async {
    if (loginEmailText.text.isNotEmpty && loginPassText.text.isNotEmpty) {
      var regBody = {
        "email": loginEmailText.text.toLowerCase().trim(),
        "password": loginPassText.text
      };

      var response = await http.post(Uri.parse(loginUrl),
          headers: {
            "Content-Type": "application/json"
          }, //node for me : it is a request header that indicates request body is in json format
          body: jsonEncode(regBody));
      var responseData = jsonDecode(response.body);
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 404 ||
          response.statusCode == 401 ||
          response.statusCode == 500) {
        if (responseData.containsKey("message")) {
          setState(() {
            errorTextVal = responseData["message"];
          });
        }
      } else if (response.statusCode == 200) {
        await storage.write(key: "token", value: responseData["accessToken"]);
        await storage.write(key: "userEmail",value: loginEmailText.text.trim());
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NavigationPage(
                    userEmailId: loginEmailText.text,
                  )),
        );
        //   Get.to(() =>
        //       const UploadProfileImage()); //used Get.to() to navigate to next page instead of Navigator.push() for increasing performance
      }
    }
  }

  bool isValidEmail(String value) {
    const emailPattern = r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$';
    final regExp = RegExp(emailPattern);
    return regExp.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 40),
          child: Center(
            child: SizedBox(
              width: 331,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    child: Text(
                      'Welcome back! Glad to see you, Again!',
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
                    maxLines: 1,
                    onChanged: (value) {
                      setState(() {
                        if (value.contains(' ')) {
                          errorLoginTextVal = "Don't use blank spaces";
                        } else {
                          errorLoginTextVal = "";
                        }
                      });
                    },
                    textCapitalization: TextCapitalization.none,
                    controller: loginEmailText,
                    // enabled: false,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF7F8F9),
                      hintText: 'Email',
                      errorText:
                          errorLoginTextVal.isEmpty ? null : errorLoginTextVal,
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
                      prefixIcon: const Icon(Icons.email, color: Colors.grey),
                    ),
                  ),
                  Container(
                    height: 11,
                  ),
                  TextField(
                    // keyboardType: TextInputType.phone,
                    maxLines: 1,
                    onChanged: (value) {
                      setState(() {
                        errorPassTextVal = '';
                      });
                    },
                    controller: loginPassText,
                    obscureText: true,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF7F8F9),
                      hintText: 'Password',
                      errorText: errorPassTextVal.isEmpty ? null : errorPassTextVal,
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
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forgot Password?',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Color(0xFF6A707C),
                        fontSize: 14,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  StatefulBuilder(builder: (context, n) {
                    return InkWell(
                      onTap: isLoading
                          ? null
                          : () {
                              setState(() {
                                isLoading = true;
                                errorLoginTextVal = '';
                                errorPassTextVal = '';
                                errorTextVal = '';
                              });
                              if (loginEmailText.text.isEmpty &&
                                  loginPassText.text.isEmpty) {
                                setState(() {
                                  errorLoginTextVal = 'Please provide Email';
                                  errorPassTextVal = 'Please provide Password';
                                  isLoading = false;
                                });
                              } else if (loginEmailText.text.isEmpty) {
                                setState(() {
                                  errorLoginTextVal = 'Please provide Email';
                                  isLoading = false;
                                });
                              } else if (!isValidEmail(loginEmailText.text) &&
                                  loginPassText.text.isEmpty) {
                                setState(() {
                                  errorLoginTextVal = 'Please enter a valid Email';
                                  errorPassTextVal = 'Please provide Password';
                                  isLoading = false;
                                });
                              } else if (!isValidEmail(loginEmailText.text)) {
                                setState(() {
                                  errorLoginTextVal = 'Please enter a valid Email';
                                  isLoading = false;
                                });
                              } else if (loginPassText.text.isEmpty) {
                                setState(() {
                                  errorPassTextVal = 'Please provide Password';
                                  isLoading = false;
                                });
                              } else {
                                loginUser();
                              }
                            },
                      child: Hero(
                        tag: "loginButtonAnimation",
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
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: isLoading ? 30 : 138,
                                top: isLoading ? -28 : 18,
                                child: isLoading
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Lottie.asset(
                                              'assets/anims/truckShipAnim.json',
                                              width: 95,
                                              height: 95,
                                              fit: BoxFit.fitWidth),
                                          Container(
                                            margin: const EdgeInsets.only(top: 15),
                                            child: const Text('Logging you in..',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w600,
                                                )),
                                          )
                                        ],
                                      )
                                    : const Text(
                                        'Login',
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
                  }),
                  const SizedBox(
                    height: 11,
                  ),
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
                  const SizedBox(
                    height: 26,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpInitPage()));
                      // Get.off(()=>const MyHomePage());
                    },
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Don’t have an account? ',
                            style: TextStyle(
                              color: Color(0xFF24282C),
                              fontSize: 15,
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w500,
                              height: 1.40,
                              letterSpacing: 0.15,
                            ),
                          ),
                          TextSpan(
                            text: 'Register Now',
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
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
