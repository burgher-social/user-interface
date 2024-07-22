// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:burgher/src/Post/post_component.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Utils/api.dart';

class Profile extends StatefulWidget {
  const Profile({
    super.key,
    @required this.userId,
  });
  final String? userId;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? image;
  List<Widget> posts = [];
  String? username;
  String? tag;
  String? imageUrl;
  bool profileFetched = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserPosts();
    getUser();
  }

  updateUserImage(File image) async {
    try {
      await callFormData("/user/profile/image/upload", image, true);
    } catch (e) {
      print(e);
    }
  }

  getUser() async {
    var res = await callApi("/user/read", false, {
      "userId": widget.userId,
    });
    imageUrl = res["imageUrl"];
    username = res["username"];
    tag = res["tag"].toString();
    profileFetched = true;
    setState(() {});
  }

  getUserPosts() async {
    var res = await callApi("/post/read", false, {
      "userId": widget.userId,
    });
    List<Map<String, dynamic>> rows =
        List<Map<String, dynamic>>.from(res["response"]);
    posts = [];
    for (var i in rows) {
      posts.add(
        PostComponent(
          content: i["post"]["content"],
          image: i["user"]["imageUrl"],
          postId: i["post"]["id"],
          username: i["user"]["username"],
          userId: i["post"]["userId"],
          latitude: i["location"]["latitude"],
          longitude: i["location"]["longitude"],
          likeCount: i["insights"]["likes"],
          commentCount: i["insights"]["comments"],
        ),
      );
    }
    if (rows.isNotEmpty) {
      posts.add(
        TextButton(
          child: const Text(
            "Load More",
          ),
          onPressed: () {},
        ),
      );
    }
    setState(() {});
  }

  openImagePicker() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final file = File(image.path);
      setState(() {
        this.image = file;
      });
      updateUserImage(file);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        // title: const Text(
        //   "New Post",
        // ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: !profileFetched
          ? Container()
          : Column(
              // crossAxisAlignment: CrossAxisAlignment.end,2
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 20.0,
                          right: 20.0,
                        ),
                        // padding: EdgeInsets.all(0.2), // Border width
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SizedBox.fromSize(
                            size: const Size.fromRadius(48), // Image radius
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    bottom: 10.0,
                    top: 10.0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        username!,
                      ),
                      Text(
                        "#",
                      ),
                      Text(
                        tag!,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return posts[index];
                    },
                  ),
                ),
                // TextButton(
                //   child: const Text(
                //     "Load More",
                //   ),
                //   onPressed: () {},
                // ),
              ],
            ),
    );
  }
}
