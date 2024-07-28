import 'package:burgher/src/Post/post_component.dart';
import 'package:burgher/src/Post/post_component_udpated.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import '../Config/global.dart';
import '../Location/location_helper.dart';
import '../Post/new_post.dart';
import '../Profile/profile.dart';
import '../Storage/feed.dart';
import 'feed_generate.dart';
import 'dart:developer';

class HomePageUpdated extends StatefulWidget {
  const HomePageUpdated({super.key});

  @override
  State<HomePageUpdated> createState() => _HomePageUpdatedState();
}

class _HomePageUpdatedState extends State<HomePageUpdated> {
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    // updateLocation();
    postsGenerate();
  }

  Future<void> postsGenerate() async {
    var postIds = await getRelevantPostIds();
    // print(postIds);
    for (var i in postIds) {
      getPostContent(i, posts.length + postIds.length);
    }
  }

  Future<void> getPostContent(String postId, int totalPosts) async {
    await getContent(postId).then((value) {
      inspect(value);

      posts.add(
        {
          "content": value["post"]["content"],
          "image": value["user"]["imageUrl"] ?? "",
          "postId": value["post"]["id"],
          "userId": value["post"]["userId"],
          "username": value["user"]["username"],
          "latitude": value["location"]["latitude"] ?? 0.0,
          "longitude": value["location"]["longitude"] ?? 0.0,
          "likeCount": value["insights"]?["likes"],
          "commentCount": value["insights"]?["comments"],
          "likedPostByUser":
              value["likes"]["postId"] == null || value["likes"]["postId"] == ""
                  ? false
                  : true,
        },
      );
      setState(() {});

      print("GENERATED POSTS");
      print(posts);
      inspect(posts);
    }).catchError((e) => print(e));
    setState(() {
      posts = posts;
    });
  }

  Future<void> refreshFeed() async {
    // setState(() {});
    int tot = int.parse(localStorage.getItem("offset") ?? "0");
    await markSeenBatch(tot);
    localStorage.setItem("offset", "0");
    posts = [];
    setState(() {});
    await refrestContent();
    postsGenerate();
    updateLocation();
  }

  Future<void> loadMore() async {
    print("TAPPED LOAD MORE ");
    await postsGenerate();
    // posts.removeLast();
  }

  void updateLikeCount(int count, Map<String, dynamic> obj) {
    obj["likeCount"] += count;
    setState(() {});
  }

  void updateCommentCount(int count, Map<String, dynamic> obj) {
    print("UPDATING COMMENT COUNT IN HOMEPAGE");
    obj["commentCount"] += count;
    setState(() {});
  }

  void setLikedByUser(bool likedByUserChild, Map<String, dynamic> obj) {
    print("HOME PAGE LIKED BY USER IN HOMEPAGE");
    print(likedByUserChild);
    obj["likedPostByUser"] = likedByUserChild;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Feed",
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(
                      userId: AppConstants.userId,
                    ),
                  ),
                );
                setState(() {});
              },
              child: const Icon(Icons.person),
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: refreshFeed,
          child: Column(
            children: [
              Flexible(
                child: Scaffold(
                  body: ListView.builder(
                    itemCount: posts.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (posts.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      if (posts.length == index) {
                        return TextButton(
                          onPressed: loadMore,
                          child: const Text(
                            "Load More",
                          ),
                        );
                      }
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
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          backgroundColor: const Color(0xFFE57373),
          child: const Icon(Icons.add),
          onPressed: () async {
            var resp = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewPost()),
            );
            if (resp == "refresh") {
              await refreshFeed();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("New post created"),
                  ),
                );
              }
            }
            setState(() {});
          },
        ),
      ),
    );
  }
}
