import 'package:burgher/src/Feed/feed_generate.dart';
import 'package:burgher/src/Location/location_helper.dart';
import 'package:burgher/src/Utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../Post/post_component.dart';
import '../Storage/feed.dart';
import '../Post/new_post.dart';
import '../Utils/Location.dart';
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

  void postsGenerate({bool loadSeen = true}) async {
    var postIds = await getRelevantPostIds(loadSeen: loadSeen);
    print(postIds);
    for (var i in postIds) {
      getPostContent(i, posts.length + postIds.length);
    }
  }

  Future<void> loadMore() async {
    posts.removeLast();
    print("TAPPED LOAD MORE ");
    postsGenerate(loadSeen: false);
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
      markSeen(postId);
      print("Marked seeb");
      print(posts);
      // print(postsTemp);
      setState(() {
        // print(posts);
        posts.add(
          PostComponent(
            content: value["post"]["content"],
            image:
                "https://miro.medium.com/v2/resize:fit:720/format:webp/1*EOOeLlRAPdk2k4krTI5HIg.png",
          ),
        );

        if (totalPosts == posts.length) {
          posts.add(
            TextButton(
              onPressed: loadMore,
              child: const Text(
                "Load More",
              ),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // postsGenerate();
    print("building");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Application",
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
              child: const Icon(Icons.person),
            )
          ],
        ),
        body: Column(
          children: [
            TextButton(
              onPressed: () {},
              child: const Text(
                "Refresh",
              ),
            ),
            Flexible(
              child: Scaffold(
                body: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return posts[index];
                    }),
              ),
            ),
          ],
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
              print("running setstate");
              setState(() {});
            }),
      ),
    );
  }
}
