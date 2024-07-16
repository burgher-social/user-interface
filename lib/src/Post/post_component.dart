import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class PostComponent extends StatefulWidget {
  const PostComponent({super.key, required this.content, required this.image});
  final String content;
  final String image;
  @override
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.content,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                widget.image,
                height: 40.0,
                width: 40.0,
                fit: BoxFit.fill,
              ),
            ),
            // CircleAvatar(
            //   // radius: 100,
            //   // borderRadius: BorderRadius.circular(100),
            //   child: SizedBox.fromSize(
            //     size: const Size.fromRadius(48), // Image radius
            //     child: Image.network(
            //       widget.image,
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),
            // subtitle:
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              SizedBox(width: 60),
              Icon(
                Icons.favorite,
              ),
              SizedBox(width: 20),
              Icon(
                Icons.comment,
              ),
              // Expanded(child: Container(child: ,))
            ],
          ),
          // const Spacer(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
