import 'package:burgher/src/Post/comments_updated.dart';
import 'package:flutter/material.dart';

import '../Profile/profile.dart';
import '../Utils/Location.dart';
import '../Utils/api.dart';
import 'comments.dart';

void updateLikeCount(int count, Map<String, dynamic> obj) {
  obj["likes"] += count;
}

void updateCommentCount(int count, Map<String, dynamic> obj, Function? par) {
  par?.call(count);
  obj["comments"] += count;
  print("NEW OBJECT");
  print(obj);
}

void setLikedByUser(bool likedByUserChild, Map<String, dynamic> obj) {
  obj["likedByUser"] = likedByUserChild;
}

class PostComponentUpdated extends StatefulWidget {
  const PostComponentUpdated({
    super.key,
    this.recognizePost = true,
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
  final bool recognizePost;
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
  State<PostComponentUpdated> createState() => _PostComponentUpdatedState();
}

class _PostComponentUpdatedState extends State<PostComponentUpdated> {
  Map<String, dynamic> obj = {};
  String? dista;
  @override
  void initState() {
    super.initState();
    obj["likes"] = widget.likeCount;
    obj["comments"] = widget.commentCount;
    obj["likedByUser"] = widget.likedPostByUser;
    print(obj);
    print("POSTS IN UPDATED COMPONENR");
    distanceCalculator();
  }

  @override
  void didUpdateWidget(oldwidget) {
    super.didUpdateWidget(oldwidget);
    print("DID UPDATE CALLED");
    // print(this.widget.likeCount);
    obj["likedByUser"] = widget.likedPostByUser;
    obj["likes"] = widget.likeCount;
    // print(oldwidget.likeCount);
    // this.widget.likeCount = setState(() {});
  }

  Future<void> distanceCalculator() async {
    dista = await calculateDistanceHelper(widget.latitude, widget.longitude);
    setState(() {});
  }

  Future<void> openComments() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsUpdated(
          // content: widget.content,
          postComponent: widget,
          // image: widget.image,
          postId: widget.postId,
          // userId: widget.userId,
          // username: widget.username,
          // latitude: widget.latitude,
          // longitude: widget.longitude,
          // likeCount: widget.likeCount,
          // commentCount: widget.commentCount,
          // likedPostByUser: widget.likedPostByUser,
          updateParentLikeCount: (int count) => updateLikeCount(count, obj),
          updateParentCommentCount: (int count) =>
              updateCommentCount(count, obj, widget.updateParentCommentCount),
          updateParentLikePost: (bool v) => setLikedByUser(v, obj),
        ),
      ),
    );
    // widget?.updateParentCommentCount?.call(1);
    setState(() {});
  }

  Future<void> likePost() async {
    int count = 0;
    String path = "/insights/like/add";
    if (!obj["likedByUser"]) {
      obj["likes"] += 1;
      count += 1;
      path = "/insights/like/add";
    } else {
      obj["likes"] -= 1;
      count -= 1;
      path = "/insights/like/subtract";
    }

    obj["likedByUser"] = !obj["likedByUser"];
    widget.updateParentLikePost?.call(obj["likedByUser"]);
    widget.updateParentLikeCount?.call(count);
    setState(() {});
    // print(count);
    // print(widget.postId);
    // print("LOGGING LIKE");
    callApi(
      path,
      true,
      {
        "count": count,
        "postId": widget.postId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // obj["likes"] = widget.likeCount;
    obj["comments"] = widget.commentCount;
    // obj["likedByUser"] = widget.likedPostByUser;
    return Card(
      child: Column(
        children: [
          ListTile(
            onTap: widget.recognizePost ? openComments : null,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.username,
                ),
                Row(
                  children: [
                    if (dista != null) ...[
                      const Icon(
                        Icons.location_on,
                      ),
                      Text(dista!),
                    ],
                  ],
                ),
              ],
            ),
            subtitle: Text(
              widget.content,
              style: TextStyle(
                fontWeight:
                    !widget.recognizePost ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            leading: GestureDetector(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  widget.image,
                  height: 40.0,
                  width: 40.0,
                  fit: BoxFit.fill,
                ),
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(
                      userId: widget.userId,
                    ),
                  ),
                );
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 60),
              GestureDetector(
                onTap: likePost,
                child: Icon(
                  Icons.favorite,
                  color: obj["likedByUser"]
                      ? const Color.fromARGB(255, 145, 13, 3)
                      : Colors.black,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                obj["likes"].toString(),
              ),
              if (widget.recognizePost) ...[
                const SizedBox(width: 20),
                const Icon(
                  Icons.comment,
                  // color: Color.fromARGB(0, 0, 0, .0),
                ),
                const SizedBox(width: 3),
                Text(
                  obj["comments"].toString(),
                ),
              ]
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
