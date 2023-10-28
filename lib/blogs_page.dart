import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:user_authentication_flutter/view_image_page.dart';

import 'add_blog_page.dart';
import 'config.dart';

class BlogsPage extends StatefulWidget {
  const BlogsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return BlogPageState();
  }
}

class BlogPageState extends State<BlogsPage> {
  Future<List<Map<String, dynamic>>> getAllBlogs() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "token");
    var response = await http.get(
      Uri.parse(getAllBlogsUrl),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      return jsonData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch the blogs');
    }
  }

  Future<void> _handleRefresh() async {
    Timer(Duration(milliseconds: 3200), () {
      setState(() {
        getAllBlogs();
      });
    });
    return await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    var allBlogs = [];
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Blogs"),
        actions: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Container(
              padding:
                  const EdgeInsets.only(left: 18, right: 20, top: 8, bottom: 8),
              decoration: ShapeDecoration(
                // color: const Color(0xFF1E232C),
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: InkWell(
                onTap: () async {
                  final result = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AddBlog()));
                  if (result != null) {
                    setState(() {
                      getAllBlogs();
                    });
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'New',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
          ]),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getAllBlogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //Shimmer effect will be shown while loading the blogs
            return ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: double.infinity,
                    child: Card(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey.withOpacity(0.4),
                                highlightColor: Colors.white,
                                period: const Duration(seconds: 1),
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(left: 15, top: 10),
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors.grey.withOpacity(0.9)),
                                ),
                              ),
                              Shimmer.fromColors(
                                baseColor: Colors.grey.withOpacity(0.4),
                                highlightColor: Colors.white,
                                period: const Duration(seconds: 1),
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(left: 15, top: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 12,
                                        width: 200,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color:
                                                Colors.grey.withOpacity(0.9)),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        height: 12,
                                        width: 100,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color:
                                                Colors.grey.withOpacity(0.9)),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Shimmer.fromColors(
                            baseColor: Colors.grey.withOpacity(0.4),
                            highlightColor: Colors.white,
                            period: const Duration(seconds: 1),
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 20),
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.grey.withOpacity(0.9)),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading blogs'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No blogs available'),
            );
          } else {
            allBlogs = snapshot.data!;
            // print(allBlogs);
            return LiquidPullToRefresh(
              onRefresh: _handleRefresh,
              color: Colors.white,
              height: 200,
              backgroundColor: Colors.deepPurple[200],
              animSpeedFactor: 2.0,
              showChildOpacityTransition: false,
              child: ListView.builder(
                itemCount: allBlogs.length,
                itemBuilder: (context, index) {
                  final blog = allBlogs[index];
                  return SizedBox(
                    width: double.infinity,
                    child: Card(
                      margin: const EdgeInsets.only(left: 8, right: 8, top: 10),
                      // surfaceTintColor: Colors.white,//TODO: decide this colour
                      elevation: 2,
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      blog['imgPath'],
                                    ),
                                    radius: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          blog['name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              fontFamily: 'Poppins'),
                                        ),
                                        Text(
                                          blog['datePublished'],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Poppins'),
                                        )
                                      ]),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                blog['blog'],
                                style: const TextStyle(
                                    fontSize: 18, fontFamily: 'Poppins'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: blog['blogImagePath'] != "null"
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewImagePage(
                                                        selectedImageUrl: blog[
                                                            'blogImagePath'],
                                                      )));
                                        },
                                        child: Hero(
                                          tag: blog['blogImagePath'],
                                          child: Image.network(
                                            blog['blogImagePath'],
                                            width: double.infinity,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            LikeDislikeButtons(
                              blogId: blog['_id'],
                              likes: blog['likes'],
                              dislikes: blog['dislikes'],
                              isLiked: blog['isLiked'],
                              isDisliked: blog['isDisliked'],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(context,
      //         MaterialPageRoute(builder: (context) => const AddBlog()));
      //     // Get.to(() => const AddBlog());
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

class LikeDislikeButtons extends StatefulWidget {
  final String blogId;
  var likes;
  var dislikes;
  var isLiked;
  var isDisliked;
  LikeDislikeButtons(
      {super.key,
      required this.blogId,
      required this.likes,
      required this.dislikes,
      required this.isLiked,
      required this.isDisliked});

  @override
  State<StatefulWidget> createState() => _LikeDislikeButtonsState();
}

class _LikeDislikeButtonsState extends State<LikeDislikeButtons> {
  // List<bool> isSelected = [false, false];
  bool isAnimating = false;

  void likeBlog(String blogId) async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: "token");
    var toSendBlogId = {
      "blogId": blogId,
    };
    var response = await http.post(Uri.parse(likeBlogUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(toSendBlogId));
    if (response.statusCode == 200) {
      print("Liked the blog");
    } else {
      print("Like failed");
    }
  }

  void dislikeBlog(String blogId) async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: "token");
    var toSendBlogId = {
      "blogId": blogId,
    };
    var response = await http.post(Uri.parse(dislikeBlogUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(toSendBlogId));
    if (response.statusCode == 200) {
      print("disLiked the blog");
    } else {
      print("disLike failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(8.0),
              transform: isAnimating
                  ? Matrix4.translationValues(0, -5, 0)
                  : Matrix4.translationValues(0, 0, 0),
              child: IconButton(
                icon: Icon(
                  widget.isLiked
                      ? Icons.thumb_up_alt
                      : Icons.thumb_up_alt_outlined,
                  color: widget.isLiked ? Colors.deepPurpleAccent : Colors.grey,
                ),
                onPressed: () {
                  likeBlog(widget.blogId);
                  setState(() {
                    if (widget.isDisliked) {
                      widget.isLiked = true;
                      widget.isDisliked = false;
                      widget.likes++;
                      widget.dislikes--;
                    } else if (widget.isLiked) {
                      widget.isLiked = false;
                      widget.likes--;
                    } else {
                      //checks if previously not liked and not disliked
                      widget.isLiked = true;
                      widget.likes++;
                    }
                  });
                },
              ),
            ),
            Text(
              '${widget.likes} Likes',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            IconButton(
              icon: Icon(
                widget.isDisliked
                    ? Icons.thumb_down_alt
                    : Icons.thumb_down_alt_outlined,
                color:
                    widget.isDisliked ? Colors.deepPurpleAccent : Colors.grey,
              ),
              onPressed: () {
                dislikeBlog(widget.blogId);
                setState(() {
                  if (widget.isLiked) {
                    widget.isLiked = false;
                    widget.isDisliked = true;
                    widget.likes--;
                    widget.dislikes++;
                  } else if (widget.isDisliked) {
                    widget.dislikes--;
                    widget.isDisliked = false;
                  } else {
                    widget.dislikes++;
                    widget.isDisliked = true;
                  }
                });
              },
            ),
            Text(
              '${widget.dislikes} Dislikes',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
          ],
        ),
      ],
    );
  }
}
