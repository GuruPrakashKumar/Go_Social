import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:user_authentication_flutter/otpVerificationPage.dart';
import 'config.dart';

class SignUpInitPage extends StatefulWidget {
  const SignUpInitPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpInitPageState();
}

class _SignUpInitPageState extends State<SignUpInitPage> {
  var emailText = TextEditingController();
  var errorTextVal = '';
  bool isLoading = false;
  final storage = const FlutterSecureStorage();

  void signUpInit() async {
    print("executed");
    if (emailText.text.isNotEmpty) {
      //TODO: to Decapitalize email text
      var reqBody = {"email": emailText.text.toLowerCase().trim()};
      var response = await http.post(Uri.parse(signUpInitUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));
      var responseData = jsonDecode(response.body);
      setState(() {
        isLoading = false;
      });
      print("responseData=== $responseData");
      if (response.statusCode == 409) {
        if (responseData.containsKey("message")) {
          setState(() {
            errorTextVal = responseData["message"];
          });
        }
        print("Account Already Exists !");
      } else if (response.statusCode == 200) {
        await storage.write(key: "email", value: emailText.text);
        print("OTP sent to user email id");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const OtpVerificationPage()));
      } else {
        print("Internal Server Error");
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
          child: Center(
            child: SizedBox(
              width: 331,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
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
                    maxLines: 1,
                    onChanged: (value) {
                      setState(() {
                        if (value.contains(' ')) {
                          errorTextVal = "Don't use blank spaces";
                        } else {
                          errorTextVal = "";
                        }
                      });
                    },
                    textCapitalization: TextCapitalization.none,
                    controller: emailText,
                    // enabled: false,
                    decoration: InputDecoration(
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: Colors.red, width: 1.2)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.2)),
                      errorText: errorTextVal.isEmpty ? null : errorTextVal,
                      filled: true,
                      fillColor: const Color(0xFFF7F8F9),
                      hintText: 'Email',
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
                  const SizedBox(
                    height: 30,
                  ),
                  StatefulBuilder(
                    builder: (context, n) {
                      return InkWell(
                        onTap: isLoading
                            ? null
                            : () {
                                setState(() {
                                  isLoading = true;
                                });
                                print("tapped");
                                if (emailText.text.isEmpty) {
                                  setState(() {
                                    print("errorText = $errorTextVal");
                                    errorTextVal = 'Please enter your Email';
                                    isLoading = false;
                                  });
                                } else if (!isValidEmail(emailText.text)) {
                                  setState(() {
                                    print("errorTextval = $errorTextVal");
                                    errorTextVal = 'Please enter a valid Email';
                                    isLoading = false;
                                  });
                                } else {
                                  signUpInit();
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
                                  left: isLoading ? 100 : 128,
                                  top: isLoading ? 0 : 19,
                                  child: isLoading
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Lottie.asset(
                                                'assets/anims/emailIcon2Anim.json',
                                                width: 35,
                                                height: 35,
                                                fit: BoxFit.fitWidth),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 15),
                                              child: const Text('Sending..',
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
                                          'Send OTP',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                                // Positioned(
                                //   left: 100,
                                //     top: 0,
                                //     child: Lottie.asset('assets/anims/emailIcon2Anim.json',
                                //     width: 35,
                                //     height: 40,fit: BoxFit.fitWidth
                                //     ))
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
