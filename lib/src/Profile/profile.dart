// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Utils/api.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? image;
  List<Widget> posts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserPosts();
  }

  updateUserImage(File image) async {
    try {
      if (image != null) {
        await callFormData("/user/profile/image/upload", image);
      }
    } catch (e) {
      print(e);
    }
  }

  getUserPosts() async {
    var res = await callApi("post/read", false, {
      "userId": ".O1JafnACwuLr3xxTJ6",
    });
    List<Map<String, dynamic>> rows =
        List<Map<String, dynamic>>.from(res["response"]);
    posts = [];
    for (var i in rows) {
      posts.add(
        ListTile(
          title: Text(i["post"]["content"]),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox.fromSize(
              size: const Size.fromRadius(48), // Image radius
              child: Image.network(
                'https://miro.medium.com/v2/resize:fit:720/format:webp/1*EOOeLlRAPdk2k4krTI5HIg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "New Post",
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.end,2
        children: [
          Row(
            children: [
              InkWell(
                onTap: () async {
                  try {
                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (image == null) return;
                    // final imageTemp = File(imag, .e. ,image.path);
                    final file = File(image.path);
                    setState(() {
                      this.image = file;
                    });
                    print(image);
                    updateUserImage(file);
                  } catch (e) {
                    print(e);
                  }
                },
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
                        'https://miro.medium.com/v2/resize:fit:720/format:webp/1*EOOeLlRAPdk2k4krTI5HIg.png',
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
                  "UserHandle",
                ),
                Text(
                  "#",
                ),
                Text(
                  "1000",
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
        ],
      ),
    );
  }
}
