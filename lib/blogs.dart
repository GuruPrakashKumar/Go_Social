import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user_authentication_flutter/addBlog.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class BlogsPage extends StatefulWidget{
  const BlogsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return BlogPageState();
  }

}
class BlogPageState extends State<BlogsPage>{
  // var arrNames = ['Guru Prakash','Sony Kumari', 'Sandeep Kumar'];
  // var arrBlogs = ['hi this is guru prakash i am studying','hi i am teaching','hi i am riding bike'];

  Future<List<Map<String, dynamic>>> getAllBlogs() async {
    var response = await http.get(Uri.parse(getAllBlogsUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print(jsonData);
      return jsonData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch the blogs');
    }
  }

  List<String> arrNames = [];
  List<String> arrBlogs = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final allBlogs = await getAllBlogs();
      print("all blogs are: $allBlogs");
      for (final blog in allBlogs) {
        arrNames.add(blog['name']);
        arrBlogs.add(blog['blog']);
      }
      setState(() {}); // Update the UI
    } catch (e) {
      // Handle error
    }
  }


  @override
  Widget build(BuildContext context) {

    arrNames = arrNames.reversed.toList();
    arrBlogs = arrBlogs.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Blogs"),
      ),
      body: Container(
        child: Column(
          children:[
            Expanded(
              child: ListView.builder(itemBuilder: (context,index){
                return Card(
                  elevation: 3,
                  child: ListTile(
                    title: Text(arrNames[index]),
                    subtitle: Text(arrBlogs[index]),
                  ),
                );
              }, itemCount: arrNames.length),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed:(){Get.to(()=>AddBlog());} ,child: const Icon(Icons.add),),


    );
  }

}