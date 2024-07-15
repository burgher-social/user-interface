import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Storage/feed.dart';
import '../Utils/api.dart';

List<Widget> posts = [];
List<Widget> postsTemp = [];
Future<List<String>> getRelevantPostIds() async {
  List<String> postsfromDb = await getPostIds(0, 20);
  if (postsfromDb.isEmpty) {
    try {
      var resp = await callApi(
        "/feed/read",
        true,
        {
          "offset": 0,
          "limit": 100,
        },
      );
      List<Map<String, dynamic>> rows =
          List<Map<String, dynamic>>.from(resp["response"]);
      print(rows);
      await generateFeed(rows);
      postsfromDb = await getPostIds(0, 20);
      if (postsfromDb.isEmpty) {
        postsfromDb = await getPostIds(0, 20, isSeen: true);
      }
      print(resp);
    } catch (e) {
      print(e);
    }
  }
  return postsfromDb;
  // for (var i in postsfromDb) {
  //   getPostContent(i);
  // }
  // List<Widget> postst = [];
  // for (int i = 0; i < postsfromDb.length; ++i) {
  //   postst.add(const ListTile(
  //     leading: Text("icon"),
  //     title: Text("title"),
  //   ));
  // }

  // setState(() {
  //   posts = postst;
  // });
}

Future<Map<String, dynamic>> getContent(String postId) async {
  final res = await callApi(
    "/post/readOne",
    false,
    {
      "postId": postId,
    },
  );

  print(res);
  return res;
}

// void getPostContent(String postId) async {
//   getContent(postId).then((value) {
//     postsTemp.add(ListTile(
//       title: Text(value["post"]["content"]),
//       leading: Text(postId),
//     ));
//     markSeen(postId);
//     print("Marked seeb");
//     print(posts);
//     print(postsTemp);
//     // setState(() {
//     print(posts);
//     posts = postsTemp;
//     // });
//   });
// }
