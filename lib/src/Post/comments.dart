import 'package:burgher/src/Post/post_component.dart';
import 'package:burgher/src/Utils/api.dart';
import 'package:flutter/material.dart';

class Comments extends StatefulWidget {
  const Comments({
    super.key,
    required this.content,
    required this.image,
    required this.username,
    required this.userId,
    required this.postId,
    this.latitude,
    this.longitude,
    this.likeCount,
    this.commentCount,
  });
  final String content;
  final String image;
  final String postId;
  final String username;
  final String userId;

  final double? latitude;
  final double? longitude;

  final int? likeCount;
  final int? commentCount;
  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  String? content;
  bool loading = true;
  int likesCount = 0;
  int commentsCount = 0;
  var comments = [];
  final fieldText = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    likesCount = widget.likeCount ?? 0;
    commentsCount = widget.commentCount ?? 0;

    getComments();
  }

  void submitPost() async {
    if (content == null || content == "") return;
    try {
      var tempContent = content;
      FocusManager.instance.primaryFocus?.unfocus();
      content = null;
      loading = true;
      fieldText.clear();
      setState(() {});
      await callApi("/post/create", true, {
        "content": tempContent,
        "parentId": widget.postId,
        "topics": ["test"],
      });

      comments.insert(
        0,
        PostComponent(
          content: tempContent!,
          image: widget.image,
          postId: widget.postId,
          recognizePost: false,
          username: widget.username,
          userId: widget.userId,
          latitude: widget.latitude,
          longitude: widget.longitude,
          likeCount: 0,
          commentCount: 0,
        ),
      );
      loading = false;
      likesCount++;
      setState(() {});
      // print(resp);
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
    // print(content);
  }

  Future<void> getComments() async {
    var res = await callApi(
      "/post/comments/read",
      false,
      {
        "postId": widget.postId,
      },
    );
    // print(res);
    for (var i in res["response"]) {
      comments.add(
        PostComponent(
          content: i["post"]["content"],
          image: i["user"]["imageUrl"],
          postId: i["post"]["id"],
          recognizePost: false,
          username: i["user"]["username"],
          userId: i["post"]["userId"],
          latitude: i["location"]["latitude"],
          longitude: i["location"]["longitude"],
          likeCount: i["insights"]["likes"],
          commentCount: i["insights"]["comments"],
        ),
      );
    }
    loading = false;
    setState(() {});
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
            latitude: widget.latitude,
            longitude: widget.longitude,
            likeCount: likesCount,
            commentCount: commentsCount,
          ),
          const SizedBox(height: 8),
          const Divider(
            color: Colors.black,
          ),
          const SizedBox(height: 8),
          loading
              ? const CircularProgressIndicator()
              : Flexible(
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
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          10.0,
                        ),
                      ), // Optional: Adds rounded corners
                    ),
                  ),
                  controller: fieldText,
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
