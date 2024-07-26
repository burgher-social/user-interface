// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:burgher/src/Post/post_component.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Post/post_component_udpated.dart';
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
  List<Map<String, dynamic>> posts = [];

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

  void updateLikeCount(int count, Map<String, dynamic> obj) {
    obj["likeCount"] += count;
    setState(() {});
  }

  void updateCommentCount(int count, Map<String, dynamic> obj) {
    obj["commentCount"] += count;
    setState(() {});
  }

  void setLikedByUser(bool likedByUserChild, Map<String, dynamic> obj) {
    obj["likedPostByUser"] = likedByUserChild;
    setState(() {});
  }

  updateUserImage(File image) async {
    try {
      await callFormData("/user/profile/image/upload", image, true);
    } catch (e) {
      print(e);
    }
  }

  getUser() async {
    print(widget.userId);
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
    var res = await callApi("/post/read", true, {
      "userId": widget.userId,
    });
    List<Map<String, dynamic>> rows =
        List<Map<String, dynamic>>.from(res["response"]);
    posts = [];
    for (var value in rows) {
      posts.add(
        {
          "content": value["post"]["content"],
          "image": value["user"]["imageUrl"],
          "postId": value["post"]["id"],
          "userId": value["post"]["userId"],
          "username": value["user"]["username"],
          "latitude": value["location"]["latitude"],
          "longitude": value["location"]["longitude"],
          "likeCount": value["insights"]?["likes"],
          "commentCount": value["insights"]?["comments"],
          "likedPostByUser":
              value["likes"]["postId"] == null || value["likes"]["postId"] == ""
                  ? false
                  : true,
        },
      );
    }
    if (rows.isNotEmpty) {
      // posts.add(
      //   TextButton(
      //     child: const Text(
      //       "Load More",
      //     ),
      //     onPressed: () {},
      //   ),
      // );
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: !profileFetched
          ? Container()
          : Column(
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
                      var posc = PostComponentUpdated(
                        content: posts[index]["content"],
                        image: posts[index]["image"],
                        postId: posts[index]["postId"],
                        userId: posts[index]["userId"],
                        username: posts[index]["username"],
                        latitude: posts[index]["latitude"],
                        longitude: posts[index]["longitude"],
                        likeCount: posts[index]["likeCount"],
                        commentCount: posts[index]["commentCount"],
                        likedPostByUser: posts[index]["likedPostByUser"],
                        updateParentLikeCount: (int count) =>
                            updateLikeCount(count, posts[index]),
                        updateParentCommentCount: (int count) =>
                            updateCommentCount(count, posts[index]),
                        updateParentLikePost: (bool v) =>
                            setLikedByUser(v, posts[index]),
                      );

                      return posc;
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
