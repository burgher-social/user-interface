import 'package:burgher/src/Post/post_component.dart';
import 'package:burgher/src/Utils/api.dart';
import 'package:flutter/material.dart';

import '../Config/global.dart';
import '../Utils/Location.dart';

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
    this.likedPostByUser,
    this.updateParentCommentCount,
    this.updateParentLikeCount,
    this.updateParentLikePost,
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

  final bool? likedPostByUser;

  final Function? updateParentLikeCount;
  final Function? updateParentCommentCount;
  final Function? updateParentLikePost;

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  String? content;
  bool loading = true;
  int likesCount = 0;
  int commentsCount = 0;
  var comments = [];
  bool likedPostByUser = false;
  final fieldText = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    likesCount = widget.likeCount ?? 0;
    commentsCount = widget.commentCount ?? 0;
    likedPostByUser = widget.likedPostByUser ?? false;

    getComments();
  }

  void submitPost() async {
    if (content == null || content == "") return;
    try {
      var tempContent = content;
      FocusManager.instance.primaryFocus?.unfocus();
      content = null;
      loading = true;
      print("TRYING TO INFORM PARENT");
      print(widget.updateParentCommentCount);
      widget.updateParentCommentCount?.call(1);
      // widget.updateParentCommentCount!(1);
      print("UPDATED PARENT");
      fieldText.clear();
      setState(() {});
      await callApi(
          "/post/create",
          true,
          {
            "content": tempContent,
            "parentId": widget.postId,
            "topics": ["test"],
          },
          ctx: context);
      var lat = AppConstants.latitude;
      var lng = AppConstants.longitude;

      if (lat == null) {
        var pos = await determineLocation();
        lat = pos.latitude;
        lng = pos.longitude;
      }
      comments.insert(
        0,
        PostComponent(
          content: tempContent!,
          image: widget.image,
          postId: widget.postId,
          recognizePost: false,
          username: widget.username,
          userId: widget.userId,
          latitude: lat,
          longitude: lng,
          likeCount: 0,
          commentCount: 0,
          likedPostByUser: false,
          updateParentCommentCount: widget.updateParentCommentCount,
          updateParentLikeCount: widget.updateParentLikeCount,
          updateParentLikePost: widget.updateParentLikePost,
        ),
      );
      commentsCount++;
      loading = false;
      // likesCount++;
      setState(() {});
      // print(resp);
    } catch (e) {
      print(e);
    }
    setState(() {});
  }

  Future<void> getComments() async {
    var res = await callApi(
      "/post/comments/read",
      true,
      {
        "postId": widget.postId,
      },
      ctx: context,
    );
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
          likedPostByUser: i["likes"]["postId"] == null ? false : true,
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
            likedPostByUser: widget.likedPostByUser,
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
