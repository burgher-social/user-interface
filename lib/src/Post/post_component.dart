import 'package:burgher/src/Config/global.dart';
import 'package:burgher/src/Post/comments.dart';
import 'package:burgher/src/Utils/Location.dart';
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
  });
  final String content;
  final String image;
  final String postId;
  final bool recognizePost;
  final String username;
  final String userId;

  final double? latitude;
  final double? longitude;
  @override
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> {
  String? dist;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.recognizePost) {
      com = openComments;
    }
    calculateDistanceHelper();
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
      dist = "${mdi.toStringAsFixed(1)}km";
    } else {
      dist = "${(mdi * 1000).toStringAsFixed(0)}m";
    }
    setState(() {});
  }

  void Function()? com;
  Future<void> openComments() async {
    Navigator.push(
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
        ),
      ),
    );
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
                dist == null ? Container() : Text(dist!)
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 60),
              Icon(
                Icons.favorite,
              ),
              SizedBox(width: 20),
              Icon(
                Icons.comment,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
