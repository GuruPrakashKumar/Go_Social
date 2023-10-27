import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:user_authentication_flutter/blogs_page.dart';
import 'package:user_authentication_flutter/config.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:user_authentication_flutter/navigation_page.dart';
import 'package:user_authentication_flutter/view_image_page.dart';

class AddBlog extends StatefulWidget {
  const AddBlog({super.key});

  @override
  State<AddBlog> createState() => _AddBlogState();
}

class _AddBlogState extends State<AddBlog> {
  var blogText = TextEditingController();
  var blogOnChange;
  var correctedText = '';
  bool isCorrecting = false;
  File? selectedImage;
  bool isLoading = false;
  var errorTextVal = '';
  bool textAreaEnabled = false;
  void pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        errorTextVal = '';
        selectedImage = File(pickedImage.path);
      });
    }
  }

  void correctGrammar() async {
    setState(() {
      isCorrecting = true;
      correctedText = '';
    });

    try {
      var reqBody = {"blog": blogText.text.trim()};
      // print(reqBody);
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");

      if (blogText.text.isNotEmpty) {
        final response = await http.post(
          Uri.parse(correctGrammarUrl),
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(reqBody),
        );

        // print("Response status code: ${response.statusCode}");
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          // print("Response data: $responseData");

          if (responseData.containsKey("message")) {
            setState(() {
              correctedText =
                  responseData["message"].toString().replaceAll('\n', '');
              isCorrecting = false;
            });
          } else {
            setState(() {
              isCorrecting = false;
              errorTextVal = "Response does not contain 'message'.";
            });
          }
        } else {
          setState(() {
            // errorTextVal = "Request failed with status: ${response.statusCode}";
            isCorrecting = false;
            errorTextVal = "Correcting Grammar isn't available. Try after some time";
          });
        }
      }
    } catch (error) {
      print("Error: $error");
      setState(() {
        // errorTextVal = "An error occurred: $error";
        isCorrecting = false;
      });
    }
  }

  void postBlog() async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");
      if (blogText.text.isNotEmpty) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(uploadBlogUrl),
        );
        request.headers['Authorization'] = 'Bearer $token';
        print('-----Bearer $token');
        request.fields['blog'] = blogText.text.trim();

        if (selectedImage != null) {
          request.files.add(
            await http.MultipartFile.fromPath('image', selectedImage!.path),
          );
        }

        var response = await request.send();
        setState(() {
          isLoading = false;
        });
        // var responseData = jsonDecode(response.body);
        // print('responseData------------------$responseData');
        if (response.statusCode == 200) {
          print("blog uploaded");
          // Navigator.pushReplacement(context,
          //     MaterialPageRoute(builder: (context) => const BlogsPage()));
          Navigator.pop(context, "New Blog Added");
        } else if (response.statusCode == 500) {
          print("blog upload failed");
          setState(() {
            errorTextVal = 'Internal Server Error';
          });
        }
      }
    } catch (error) {
      print("error in upload blog $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write Blog"),
        actions: [
          InkWell(
            onTap: isLoading
                ? null
                : () {
                    if (selectedImage != null || blogText.text.isNotEmpty) {
                      setState(() {
                        isLoading = true;
                        errorTextVal = '';
                      });
                      postBlog();
                    }
                    // Get.off(()=>const BlogsPage());
                  },
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                padding: isLoading
                    ? const EdgeInsets.only(
                        left: 8, right: 30, top: 3, bottom: 3)
                    : const EdgeInsets.only(
                        left: 30, right: 30, top: 8, bottom: 8),
                decoration: ShapeDecoration(
                  color: (selectedImage != null || blogText.text.isNotEmpty)
                      ? const Color(0xFF1E232C)
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isLoading)
                      Lottie.asset('assets/anims/upAnim.json',
                          width: 35, height: 35, fit: BoxFit.fitWidth),
                    Text(
                      isLoading ? 'Posting..' : 'Post',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ]),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(
                  top: 20, left: 10, right: 10, bottom: 5),
              child: TextField(
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Urbanist',
                ),
                controller: blogText,
                onChanged: (value) {
                  setState(() {
                    errorTextVal = '';
                    blogOnChange = blogText.text;
                    correctedText = '';
                  });
                },
                minLines: 3,
                maxLines: 7,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(20.0),
                  hintText: selectedImage != null
                      ? 'Write something about this photo'
                      : "What's on your mind ?",
                  hintStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Urbanist',
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1.3)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.blueGrey, width: 1)),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(
                          color: Colors.black,
                          width: 0.2,
                        ),
                      ),
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                    ),
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                    label: Text(
                      selectedImage != null ? 'Change Image' : 'Add Image    ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      selectedImage != null
                          ? InkWell(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Timer(const Duration(milliseconds: 70), () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ViewImagePage(
                                              selectedImage: selectedImage)));
                                });
                              },
                              child: Hero(
                                tag: "pickedImage",
                                child: SizedBox(
                                  // width: 310,
                                  // height: 310,
                                  child: Image.file(
                                    selectedImage!,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      if (selectedImage != null)
                        Positioned(
                          top: -15,
                          right: -15,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: -12,
                                  blurRadius: 3,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.cancel_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  errorTextVal = '';
                                  selectedImage = null;
                                });
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: InkWell(
                onTap: blogText.text == '' ? null : () => correctGrammar(),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: isCorrecting
                            ? "Correcting Your Grammar"
                            : 'Want to Correct Your Grammar? ',
                        style: const TextStyle(
                          color: Color(0xFF24282C),
                          fontSize: 16,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w500,
                          height: 1.40,
                          letterSpacing: 0.15,
                        ),
                      ),
                      TextSpan(
                        text: isCorrecting ? "..." : 'Try Now',
                        style: TextStyle(
                          color: blogText.text == ''
                              ? Colors.grey
                              : const Color(0xFF34C2C1),
                          fontSize: 17,
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
            const SizedBox(height: 10),
            correctedText != ''
                ? Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                child: Text(
                                  "Corrected Blog: ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton.outlined(
                                  color: Colors.black,
                                  onPressed: () {
                                    setState(() {
                                      blogText.text = correctedText;
                                    });
                                  },
                                  icon: const Icon(
                                      Icons.content_paste_go_rounded)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey), // Border color
                              borderRadius:
                                  BorderRadius.circular(10), // Circular shape
                            ),
                            child: SizedBox(
                              child: Text(
                                correctedText,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        ]),
                  )
                : const SizedBox.shrink(),
            Positioned(
              left: isLoading ? 90 : 138,
              top: isLoading ? 0 : 19,
              child: isLoading
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(right: 10, top: 4),
                          child: Lottie.asset('assets/anims/otpVerifyAnim.json',
                              width: 35, height: 35, fit: BoxFit.fitHeight),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 15),
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
            //TODO: button for pasting blog
            Container(
              margin: const EdgeInsets.only(left: 10),
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
          ],
        ),
      ),
    );
  }
}
