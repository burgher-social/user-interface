import 'package:burgher/src/Location/location_helper.dart';
import 'package:burgher/src/Utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
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
    // generateFeed();
    // generateFeed([
    //   {
    //     'post_id': '123',
    //     'score': 120,
    //     'is_seen': false,
    //     'created_at': DateTime.now().millisecondsSinceEpoch
    //   },
    //   {
    //     'post_id': '124',
    //     'score': 122,
    //     'is_seen': false,
    //     'created_at': DateTime.now().millisecondsSinceEpoch
    //   },
    //   {
    //     'post_id': '12',
    //     'score': 10,
    //     'is_seen': false,
    //     'created_at': DateTime.now().millisecondsSinceEpoch
    //   }
    // ]);
    // determineLocation();
    updateLocation();
    postsGenerate();
  }

  void postsGenerate() async {
    List<String> postsfromDb = await getPostIds(0, 20);
    print("POST IDS from DB");
    print(postsfromDb);
    if (postsfromDb.isEmpty) {
      print("POSTS FETCHING");
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
        print(resp);
      } catch (e) {
        print(e);
      }
    }
    for (var i in postsfromDb) {
      getPostContent(i);
    }
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

  void getPostContent(String postId) async {
    getContent(postId).then((value) {
      postsTemp.add(ListTile(
        leading: Text(value["content"]),
        title: Text(postId),
      ));
      markSeen(postId);
      print("Marked seeb");
      print(posts);
      setState(() {
        posts = postsTemp;
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
        body: Column(children: [
          Flexible(
            child: Scaffold(
              body: ListView(children: posts),
            ),
          )
        ]),
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
