import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:user_authentication_flutter/config.dart';

class AddBlog extends StatefulWidget{
  const AddBlog({super.key});



  @override
  State<AddBlog> createState() => _AddBlogState();
}

class _AddBlogState extends State<AddBlog> {
  var blogText = TextEditingController();

  void postBlog() async{
    try{
      const storage = FlutterSecureStorage();
      final token = await storage.read(key:"token");
      if(blogText.text.isNotEmpty){
        final blogBody = {
          "blog":blogText.text
        };
        var response = await http.post(
          Uri.parse(uploadBlog),
          headers: {'Authorization':'Bearer $token'},
          body: blogBody
        );
        if(response.statusCode==200){
          print("blog uploaded");
        }else{
          print("blog upload failed");
        }
      }
    }catch(error){
      print("error in upload blog $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Write Blog"),
      ),
      body:Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: blogText,
                // enabled: false,
                maxLines: null,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(20.0),
                  hintText: 'Enter Your Blog',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueAccent,width: 2)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueGrey,width: 2)
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            // ElevatedButton(onPressed: (){Get.back();}, child: const Text("Post"))
            ElevatedButton(
              onPressed: () {
                postBlog();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF385C), // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Post Blog',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ) ,
    );
  }
}