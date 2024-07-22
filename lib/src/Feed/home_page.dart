import 'package:burgher/src/Feed/feed_generate.dart';
import 'package:burgher/src/Location/location_helper.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import '../Config/global.dart';
import '../Post/post_component.dart';
import '../Storage/feed.dart';
import '../Post/new_post.dart';
import "../Profile/profile.dart";

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Widget> posts = [];
  List<Widget> postsTemp = [];
  @override
  void initState() {
    super.initState();
    // updateLocation();
    postsGenerate();
  }

  Future<void> postsGenerate() async {
    var postIds = await getRelevantPostIds();
    print(postIds);
    for (var i in postIds) {
      getPostContent(i, posts.length + postIds.length);
    }
  }

  Future<void> refreshFeed() async {
    posts = [];
    int tot = int.parse(localStorage.getItem("offset") ?? "0");
    await markSeenBatch(tot);
    localStorage.setItem("offset", "0");
    await refrestContent();
    postsGenerate();
    updateLocation();
  }

  Future<void> loadMore() async {
    print("TAPPED LOAD MORE ");
    await postsGenerate();
    // posts.removeLast();
  }

  // Future<Map<String, dynamic>> getContent(String postId) async {
  //   final res = await callApi(
  //     "/post/readOne",
  //     false,
  //     {
  //       "postId": postId,
  //     },
  //   );

  //   print(res);
  //   return res;
  // }

  Future<void> getPostContent(String postId, int totalPosts) async {
    await getContent(postId).then((value) {
      print("adding post - $postId");
      // postsTemp.add(ListTile(
      // title: Text(value["post"]["content"]),
      // leading: Text(postId),
      // ));
      // markSeen(postId);
      // print("Marked seeb");
      // print(postsTemp);
      posts.add(
        PostComponent(
          content: value["post"]["content"],
          image: value["user"]["imageUrl"],
          postId: value["post"]["id"],
          userId: value["post"]["userId"],
          username: value["user"]["username"],
          latitude: value["location"]["latitude"],
          longitude: value["location"]["longitude"],
          likeCount: value["insights"]?["likes"],
          commentCount: value["insights"]?["comments"],
        ),
      );
      // if (totalPosts == posts.length) {
      // posts.add(
      //   TextButton(
      //     onPressed: loadMore,
      //     child: const Text(
      //       "Load More",
      //     ),
      //   ),
      // );
      // }
    }).catchError((e) => print(e));
    setState(() {
      // print(posts);
      posts = posts;
    });
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
              },
              child: const Icon(Icons.person),
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: refreshFeed,
          child: Column(
            children: [
              // TextButton(
              //   onPressed: refreshFeed,
              //   child: const Text(
              //     "Refresh",
              //   ),
              // ),
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
                      return posts[index];
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
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewPost()),
            );
            setState(() {});
          },
        ),
      ),
    );
  }
}
