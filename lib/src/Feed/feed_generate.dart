import 'package:flutter/cupertino.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/material.dart';

import '../Storage/feed.dart';
import '../Utils/api.dart';

List<Widget> posts = [];
List<Widget> postsTemp = [];
int lim = 5;

Future<List<String>> getRelevantPostIds() async {
  int offs = int.parse(localStorage.getItem("offset") ?? "0");
  List<String> postsfromDb = await getPostIds(offs, offs + lim);
  localStorage.setItem("offset", (offs + lim).toString());
  if (postsfromDb.isEmpty) {
    try {
      await refrestContent();
      postsfromDb = await getPostIds(offs, offs + lim);
    } catch (e) {
      print(e);
    }
  }
  return postsfromDb;
}

Future<void> refrestContent() async {
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
  await generateFeed(rows);
}

Future<Map<String, dynamic>> getContent(String postId) async {
  final res = await callApi(
    "/post/readOne",
    true,
    {
      "postId": postId,
    },
  );

  print(res);
  return res;
}
