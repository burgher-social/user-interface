import 'package:burgher/src/Post/post_component_udpated.dart';
import 'package:flutter/material.dart';

import '../Config/global.dart';
import '../Utils/Location.dart';
import '../Utils/api.dart';

class CommentsUpdated extends StatefulWidget {
  const CommentsUpdated({
    super.key,
    required this.postId,
    required this.postComponent,
    this.updateParentCommentCount,
    this.updateParentLikeCount,
    this.updateParentLikePost,
  });
  final Widget postComponent;
  final String postId;
  final Function? updateParentLikeCount;
  final Function? updateParentCommentCount;
  final Function? updateParentLikePost;
  @override
  State<CommentsUpdated> createState() => _CommentsUpdatedState();
}

class _CommentsUpdatedState extends State<CommentsUpdated> {
  Widget? post;
  var comments = [];
  String? content;

  bool loading = false;
  final fieldText = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    post = widget.postComponent;
    print("INSTALLING COMMENRS UPDATED");
    getComments();
  }

  Future<void> getComments() async {
    var res = await callApi(
        "/post/comments/read",
        true,
        {
          "postId": widget.postId,
        },
        ctx: context);
    for (var value in res["response"]) {
      comments.add(
        {
          "content": value["post"]["content"],
          "image": value["user"]["imageUrl"],
          "postId": value["post"]["id"],
          "userId": value["post"]["userId"],
          "username": value["user"]["username"],
          "latitude": value["location"]["latitude"],
          "longitude": value["location"]["longitude"],
          "likeCount": value["insights"]?["likes"],
          "commentCount": value["insights"]?["comments"],
          "likedPostByUser":
              value["likes"]["postId"] == null || value["likes"]["postId"] == ""
                  ? false
                  : true,
        },
      );
    }
    loading = false;
    setState(() {});
  }

  void submitPost() async {
    if (content == null || content == "") return;
    try {
      var tempContent = content;
      FocusManager.instance.primaryFocus?.unfocus();
      content = null;
      loading = true;
      print("TRYING TO INFORM PARENT");
      PostComponentUpdated postComponent = post as PostComponentUpdated;
      widget.updateParentCommentCount?.call(1);
      // widget.updateParentCommentCount!(1);
      print("UPDATED PARENT");
      fieldText.clear();
      // PostComponentUpdated p = widget.postComponent as PostComponentUpdated;

      // post = widget.postComponent;
      setState(() {});
      var resfrompostcreate = await callApi(
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
      // PostComponentUpdated postComponent = post as PostComponentUpdated;
      PostComponentUpdated newPostComponent = PostComponentUpdated(
        content: postComponent.content,
        image: postComponent.image,
        username: postComponent.username,
        userId: postComponent.userId,
        postId: postComponent.postId,
        likeCount: postComponent.likeCount,
        latitude: postComponent.latitude,
        longitude: postComponent.longitude,
        commentCount: postComponent.commentCount! + 1,
        likedPostByUser: postComponent.likedPostByUser,
        updateParentLikeCount: postComponent.updateParentLikeCount,
        updateParentCommentCount: postComponent.updateParentCommentCount,
        updateParentLikePost: postComponent.updateParentLikePost,
      );
      post = newPostComponent;
      comments.insert(
        0,
        {
          "content": tempContent!,
          "image": postComponent.image,
          "postId": postComponent.postId,
          "recognizePost": false,
          "username": "username", // resfrompostcreate[""]
          "userId": resfrompostcreate["userId"],
          "latitude": lat,
          "longitude": lng,
          "likeCount": 0,
          "commentCount": 0,
          "likedPostByUser": false,
          "updateParentCommentCount": widget.updateParentCommentCount,
          "updateParentLikeCount": widget.updateParentLikeCount,
          "updateParentLikePost": widget.updateParentLikePost,
        },
      );
      // commentsCount++;
      loading = false;
      // likesCount++;
      setState(() {});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Comment posted"),
        ));
      }
      if (context.mounted) Navigator.pop(context);
      // print(resp);
    } catch (e) {
      print(e);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          post!,
          const SizedBox(height: 8),
          const Divider(
            color: Colors.black,
          ),
          const SizedBox(height: 8),
          const Text(
            "Comments:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          loading
              ? const CircularProgressIndicator()
              : Flexible(
                  child: Scaffold(
                    body: ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (BuildContext context, int index) {
                        return PostComponentUpdated(
                          content: comments[index]["content"],
                          image: comments[index]["image"],
                          username: comments[index]["username"],
                          userId: comments[index]["userId"],
                          postId: comments[index]["postId"],
                          likeCount: comments[index]["likeCount"],
                          latitude: comments[index]["latitude"],
                          longitude: comments[index]["longitude"],
                          commentCount: comments[index]["commentCount"],
                          likedPostByUser: comments[index]["likedPostByUser"],
                          updateParentLikeCount: widget.updateParentLikeCount,
                          updateParentCommentCount:
                              widget.updateParentCommentCount,
                          updateParentLikePost: widget.updateParentLikePost,
                          recognizePost: false,
                        );
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
