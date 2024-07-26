import 'package:burgher/src/Storage/feed.dart';
import 'package:flutter/material.dart';
import '../Utils/api.dart';

class NewPost extends StatefulWidget {
  const NewPost({super.key});

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  String? content;
  @override
  Widget build(BuildContext context) {
    void submitPost() async {
      if (content == null || content == "") return;
      try {
        var resp = await callApi("/post/create", true, {
          "content": content,
          "parentId": null,
          "topics": ["test"],
        });
        print(resp);
        // generateFeed([
        //   {
        //     "postId": resp["id"],
        //     "score": 0,
        //     "timestamp": DateTime.now().millisecondsSinceEpoch
        //   }
        // ]);
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
      if (context.mounted) Navigator.pop(context);
      print(content);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "New Post",
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(children: [
        const SizedBox(height: 100),
        TextField(
          decoration: const InputDecoration(
            labelText: "What's on your mind?",
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(
                  Radius.circular(10.0)), // Optional: Adds rounded corners
            ),
          ),
          onChanged: (value) {
            setState(() {
              content = value;
            });
          },
        ),
        if (content != null && content != "")
          ElevatedButton(
            onPressed: submitPost,
            child: const Icon(Icons.send),
          )
      ]),
      // floatingActionButton: FloatingActionButton(
      //   elevation: 0.0,
      //   backgroundColor: const Color(0xFFE57373),
      //   onPressed: () {
      //     print("Hello");
      //   },
      //   child: const Icon(
      //     Icons.add,
      //   ),
      // ),
    );
  }
}
