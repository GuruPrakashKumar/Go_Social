import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user_authentication_flutter/blogs_page.dart';

import 'config.dart';

class UploadProfileImage extends StatefulWidget {
  const UploadProfileImage({super.key});

  @override
  State<UploadProfileImage> createState() => _UploadProfileImageState();
}

class _UploadProfileImageState extends State<UploadProfileImage> {
  File?
      pickedImage; //note for me: this ? represents that pickedImage is nullable means we will store image later
  dynamic imgPath;
  bool imgLoading = false;
  dynamic fetchImage() async {
    try {
      setState(() {
        imgLoading = true;
      });
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");
      var response = await http.get(
        Uri.parse(getProfilePhotoUrl),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          imgPath = responseData; // Assigning the image URL
          imgLoading = false;
        });
      } else {
        print("response error");
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchImage();
  }

  uploadImage(File image) async {
    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(imgUploadUrl),
      );
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          image.path,
        ),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Image upload failed');
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  void imagePickerOption() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          child: Container(
            color: Colors.white,
            height: 250,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Pick Image From",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pickImage(ImageSource.camera);
                      // Navigator.pop(context);
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text("CAMERA"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pickImage(ImageSource.gallery);
                      // Navigator.pop(context);
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("GALLERY"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("CANCEL"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  pickImage(ImageSource imageType) async {
    try {
      final photo = await ImagePicker().pickImage(source: imageType); //see docs
      if (photo == null) return; //if photo is null then it will return else---
      final tempImage = File(
          photo.path); //returns the path of the uploaded file(from the user)

      setState(() {
        pickedImage = tempImage;
      });
      uploadImage(
          tempImage); //this uploads i have to upload this with a name so that it can be found again
      Navigator.pop(context);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile'),

      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 50,
          ),
          Align(
            alignment: Alignment.center,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100),
                    ),
                  ),
                  child: ClipOval(
                    child: pickedImage != null
                        ? Image.file(
                            pickedImage!,
                            width: 170,
                            height: 170,
                            fit: BoxFit.cover,
                          )
                        : imgLoading
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey.withOpacity(0.4),
                                highlightColor: Colors.white,
                                period: const Duration(seconds: 1),
                                child: Container(
                                  height: 170,
                                  width: 170,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors.grey.withOpacity(0.9)),
                                ),
                              )
                            : Image.network(
                                '$imgPath', // Use imageUrl here
                                width: 170,
                                height: 170,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 5,
                  child: IconButton(
                    //this is the icon button overlayed with profile photo
                    onPressed: imagePickerOption,
                    icon: const Icon(
                      Icons.add_a_photo_outlined,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: ElevatedButton.icon(
          //       onPressed: imagePickerOption,
          //       icon: const Icon(Icons.add_a_photo_sharp),
          //       label: const Text('UPLOAD IMAGE')),
          // ),
          const SizedBox(
            height: 20,
          ),
          // ElevatedButton(
          //     onPressed: () {
          //       Navigator.push(context,
          //           MaterialPageRoute(builder: (context) => const BlogsPage()));
          //     },
          //     child: const Text("Go to Blogs")),
          SizedBox(
              child: Card(
                margin: const EdgeInsets.only(top: 10, right: 15, left: 15),
                elevation: 2,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                color: Colors.grey[50],
                child: const Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(top: 10,bottom: 10, right: 10, left: 10),
                            child: ListTile(
                               leading: Icon(Icons.settings),
                                title: Text(
                                  "Account Settings",
                                style: TextStyle(
                                  color: Color(0xFF5B5B5B),
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  ),
                                ),
                                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                          ),
                        ),
                    Divider(height: 2,),
                    Padding(
                        padding: EdgeInsets.only(top: 10,bottom: 10, right: 10, left: 10),
                            child: ListTile(
                               leading: Icon(Icons.privacy_tip_outlined),
                                title: Text(
                                  "Privacy Settings",
                                style: TextStyle(
                                  color: Color(0xFF5B5B5B),
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  ),
                                ),
                                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                          ),
                        ),
                    Divider(height: 2,),
                    Padding(
                        padding: EdgeInsets.only(top: 10,bottom: 10, right: 10, left: 10),
                            child: ListTile(
                               leading: Icon(Icons.report_problem_outlined),
                                title: Text(
                                  "Report a problem",
                                style: TextStyle(
                                  color: Color(0xFF5B5B5B),
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  ),
                                ),
                                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                          ),
                        ),
                    Divider(height: 2,),
                    Padding(
                        padding: EdgeInsets.only(top: 10,bottom: 10, right: 10, left: 10),
                            child: ListTile(
                               leading: Icon(Icons.help_outline),
                                title: Text(
                                  "Help",
                                style: TextStyle(
                                  color: Color(0xFF5B5B5B),
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  ),
                                ),
                                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                          ),
                        ),
                    Divider(height: 2,),
                    Padding(
                        padding: EdgeInsets.only(top: 10,bottom: 10, right: 10, left: 10),
                            child: ListTile(
                               leading: Icon(Icons.logout_rounded),
                                title: Text(
                                  "Log Out",
                                style: TextStyle(
                                  color: Color(0xFF5B5B5B),
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  ),
                                ),
                                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                          ),
                        ),
                  ],
                ),
          ))
        ],
      ),
    );
  }
}
