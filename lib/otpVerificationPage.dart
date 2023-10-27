import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pinput/pinput.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:user_authentication_flutter/config.dart';
import 'package:user_authentication_flutter/main.dart';
import 'package:user_authentication_flutter/signUpInitPage.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({Key? key}) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  bool isLoading = false;
  var enteredOtp;
  var errorTextVal = '';
  final storage = const FlutterSecureStorage();

  void otpVerification() async {
    //print("executing verification");
    if (enteredOtp != null || enteredOtp.length == 6) {
      final email = await storage.read(key: "email");
      //print("storage email $email");
      var reqBody = {"email": email, "otp": enteredOtp};
      var response = await http.post(Uri.parse(otpVerificationUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));
      var responseData = jsonDecode(response.body);
      setState(() {
        isLoading = false;
      });
      //print("responseData=== $responseData");
      if (response.statusCode == 404) {
        //user not found
        if (responseData.containsKey("message")) {
          setState(() {
            errorTextVal = responseData["message"];
          });
        }
      }
      if (response.statusCode == 400) {
        //Incorrect Otp
        if (responseData.containsKey("message")) {
          setState(() {
            errorTextVal = responseData["message"];
          });
        }
        //print("Incorrect OTP !");
      } else if (response.statusCode == 410) {
        //expired otp
        if (responseData.containsKey("message")) {
          setState(() {
            errorTextVal = responseData["message"];
          });
        }
        //print("Expired OTP !");
      } else if (response.statusCode == 200) {
        //otp validation success
        await storage.write(key: "token", value: responseData["accessToken"]);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const MyHomePage()));
      } else {
        //print("Internal Server Error");
        setState(() {
          errorTextVal = "Internal Server Error";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        // color: Colors.green.shade100,
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 1),
      ),
    );
    final errorPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        // color: Colors.green.shade100,
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red, width: 1.2),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: SizedBox(
            width: 331,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OTP Verification',
                  style: TextStyle(
                    color: Color(0xFF1E232C),
                    fontSize: 30,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    height: 0.04,
                    letterSpacing: -0.30,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30, bottom: 40),
                  child: const SizedBox(
                    width: 331,
                    child: Text(
                      'Enter the verification code we just sent on\nyour email address.',
                      style: TextStyle(
                        color: Color(0xFF838BA1),
                        fontSize: 16,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Pinput(
                  errorText: errorTextVal.isNotEmpty
                      ? errorTextVal
                      : null, //TODO: no use, to remove after checking
                  errorPinTheme: defaultPinTheme.copyWith(
                      //TODO: no use, to remove after checking
                      decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: Colors.red, width: 1.2))),
                  length: 6,
                  defaultPinTheme:
                      errorTextVal == '' ? defaultPinTheme : errorPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    width: 62,
                    height: 66,
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(
                          color: const Color(0xFF1E232C), width: 1.2),
                    ),
                  ),
                  onCompleted: (pin) {
                    //TODO: no use, to remove after checking
                    enteredOtp = pin;
                    //print("enteredOtp====$enteredOtp");
                  },
                  onChanged: (pin) {
                    enteredOtp = pin;
                    setState(() {
                      errorTextVal = '';
                    });
                    //print("enteredOtp====$enteredOtp");
                  },
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
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  child: StatefulBuilder(
                    builder: (context, n) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            isLoading = true;
                          });
                          if (enteredOtp == null || enteredOtp.length != 6) {
                            setState(() {
                              errorTextVal = 'Please enter OTP';
                              //print("errorText = $errorTextVal");
                              isLoading = false;
                            });
                          } else {
                            // setState(() {//TODO: no use, to remove after checking
                            //   errorTextVal = '';
                            // });
                            otpVerification();
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
                                // Positioned(
                                //   left: 100,
                                //     child: Lottie.asset('assets/emailLoadingAnim.json',
                                //       )
                                // ),
                                Positioned(
                                  left: isLoading ? 90 : 138,
                                  top: isLoading ? 0 : 19,
                                  child: isLoading
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  right: 10, top: 4),
                                              child: Lottie.asset(
                                                  'assets/anims/otpVerifyAnim.json',
                                                  width: 35,
                                                  height: 35,
                                                  fit: BoxFit.fitHeight),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 15),
                                              child: const Text('Verifying..',
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
                                          'Verify',
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
                ),
                Container(
                  margin: const EdgeInsets.only(top: 26, bottom: 40),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpInitPage()));
                        // Get.off(()=>const MyHomePage());
                      },
                      child: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Didn’t received code? ',
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
                              text: 'Resend',
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
