import 'package:burgher/src/Post/post_component.dart';
import 'package:burgher/src/Utils/api.dart';
import 'package:flutter/material.dart';

class Comments extends StatefulWidget {
  const Comments(
      {super.key,
      required this.content,
      required this.image,
      required this.username,
      required this.userId,
      required this.postId});
  final String content;
  final String image;
  final String postId;
  final String username;
  final String userId;

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  String? content;
  var comments = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComments();
  }

  void submitPost() async {
    if (content == null || content == "") return;
    try {
      var resp = await callApi("/post/create", true, {
        "content": content,
        "parentId": widget.postId,
        "topics": ["test"],
      });
      print(resp);
    } catch (e) {
      print(e);
    }
    // await generateFeed([
    //   {
    //     "post_id": DateTime.now().millisecondsSinceEpoch + 1,
    //     "is_seen": false,
    //     "created_at": DateTime.now().millisecondsSinceEpoch,
    //     "score": 10,
    //   }
    // ]);
    // localPosts.add();
    setState(() {});
    // if (context.mounted) Navigator.pop(context);
    print(content);
  }

  Future<void> getComments() async {
    var res = await callApi(
      "/post/comments/read",
      false,
      {
        "postId": widget.postId,
      },
    );
    print(res);
    for (var i in res["response"]) {
      comments.add(
        PostComponent(
          content: i["post"]["content"],
          image: i["user"]["imageUrl"],
          postId: i["post"]["id"],
          recognizePost: false,
          username: i["user"]["username"],
          userId: i["post"]["userId"],
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          PostComponent(
            content: widget.content,
            image: widget.image,
            postId: widget.postId,
            userId: widget.userId,
            username: widget.username,
          ),
          Flexible(
            child: Scaffold(
              body: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (BuildContext context, int index) {
                  return comments[index];
                },
              ),
            ),
          ),
          Row(
            children: [
              Flexible(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "Comment...",
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(
                          10.0)), // Optional: Adds rounded corners
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      content = value;
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: submitPost,
                child: const Icon(
                  Icons.send,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
