import 'package:burgher/src/Config/global.dart';
import 'package:burgher/src/Post/comments.dart';
import 'package:burgher/src/Utils/Location.dart';
import 'package:burgher/src/Utils/api.dart';
import 'package:flutter/material.dart';

import '../Profile/profile.dart';

class PostComponent extends StatefulWidget {
  const PostComponent({
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
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> {
  String? dist;
  int likes = 0;
  int comments = 0;

  bool likedPostByUser = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.recognizePost) {
      com = openComments;
    }
    likes = widget.likeCount ?? 0;
    comments = widget.commentCount ?? 0;
    likedPostByUser = widget.likedPostByUser ?? false;
    calculateDistanceHelper();
  }

  void updateLikeCount(int count) {
    likes += count;
  }

  void updateCommentCount(int count) {
    print("updating count");
    comments += count;
  }

  void setLikedByUser(bool likedByUserChild) {
    likedPostByUser = likedByUserChild;
  }

  Future<void> likePost() async {
    int count = 0;
    String path = "/insights/like/add";
    if (likedPostByUser) {
      likes += 1;
      count += 1;
      path = "/insights/like/add";
    } else {
      likes -= 1;
      count -= 1;
      path = "/insights/like/subtract";
    }

    likedPostByUser = !likedPostByUser;
    widget.updateParentLikePost != null &&
        widget.updateParentLikePost!(likedPostByUser);
    widget.updateParentLikeCount != null &&
        widget.updateParentLikeCount!(likes);
    setState(() {});
    callApi(
      path,
      true,
      {
        "count": count,
        "postId": widget.postId,
      },
      ctx: context,
    );
  }

  Future<void> calculateDistanceHelper() async {
    if (widget.latitude == null || widget.longitude == null) {
      return;
    }
    var lat = AppConstants.latitude;
    var lng = AppConstants.longitude;

    if (lat == null) {
      var pos = await determineLocation();
      lat = pos.latitude;
      lng = pos.longitude;
    }
    var di = calculateDistance(widget.latitude, widget.longitude, lat, lng);
    var mdi = di * 1000;
    if (mdi > 1.0) {
      dist = "${di.toStringAsFixed(1)}km";
    } else {
      dist = "${mdi.toStringAsFixed(0)}m";
    }
    setState(() {});
  }

  void Function()? com;
  Future<void> openComments() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Comments(
          content: widget.content,
          image: widget.image,
          postId: widget.postId,
          userId: widget.userId,
          username: widget.username,
          latitude: widget.latitude,
          longitude: widget.longitude,
          likeCount: widget.likeCount,
          commentCount: widget.commentCount,
          likedPostByUser: widget.likedPostByUser,
          updateParentCommentCount: updateCommentCount,
          updateParentLikeCount: updateLikeCount,
          updateParentLikePost: setLikedByUser,
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            onTap: com,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.username,
                ),
                Row(
                  children: [
                    if (dist != null) ...[
                      const Icon(
                        Icons.location_on,
                      ),
                      Text(dist!),
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
                  color: likedPostByUser
                      ? const Color.fromARGB(255, 145, 13, 3)
                      : Colors.black,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                likes.toString(),
              ),
              if (widget.recognizePost) ...[
                const SizedBox(width: 20),
                const Icon(
                  Icons.comment,
                  // color: Color.fromARGB(0, 0, 0, .0),
                ),
                const SizedBox(width: 3),
                Text(
                  comments.toString(),
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
