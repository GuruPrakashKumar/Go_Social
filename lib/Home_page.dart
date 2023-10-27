import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user_authentication_flutter/Signin_page.dart';
import 'package:user_authentication_flutter/main.dart';
import 'package:user_authentication_flutter/signUpInitPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/welcomeimg.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ), // Background image
          Positioned(
            left: 0,
            right: 0,
            bottom: 94, // Bottom margin of 94
            child: SizedBox(
              width: 331,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpInitPage())
                      );
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
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 0.50, color: Color(0xFF1E232C)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 139,
                              top: 19,
                              child: Text(
                                'Register',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF1E232C),
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
                  ), //register button
                  const SizedBox(height: 15), // Spacing between buttons

                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Signin_page()));
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
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 148,
                              top: 19,
                              child: Text(
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
                  ),
                  //login button
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
