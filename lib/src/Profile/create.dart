import 'package:burgher/src/Feed/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth.dart';
import '../Location/location_helper.dart';

class Create extends StatefulWidget {
  const Create({super.key, @required this.email});
  final String? email;

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  var _createdUser = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.email);
    // a();
  }

  // void a() async {
  //   try {
  //     var url = Uri.http('localhost:8080', '/user/create');
  //     var response = await http
  //         .post(url,
  //             headers: {"Content-Type": "application/json"},
  //             body: json.encode({
  //               'email': 'shobhit@email.com',
  //               'tag': 123,
  //               "username": "sdfgdfg",
  //               "name": "sdgdfg"
  //             }))
  //         .then((value) => print(value.body))
  //         .catchError((e, stackTrace) {
  //       print(e);
  //       print(stackTrace);
  //     });
  //     // print('Response status: ${response.statusCode}');
  //     // print('Response body: ${response.body}');
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future<void> submitForm() async {
    print(_nameController.text);
    print(_tagController.text);
    print(_usernameController.text);
    print(int.parse(_tagController.text));
    try {
      var url = Uri.http('localhost:8080', '/user/create');
      print(url);
      // var response = await http.post(url, body: {
      //   'email': 'shobhit@email.com',
      //   'tag': int.parse(_tagController.text),
      //   "username": _usernameController.text,
      //   "name": _nameController.text
      // });
      var response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'email': widget.email,
            'tag': int.parse(_tagController.text),
            "username": _usernameController.text,
            "name": _nameController.text
          }));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      var jsonbpdy = json.decode(response.body);
      print(jsonbpdy);
      print(jsonbpdy["accessToken"]);
      await saveToken(jsonbpdy["accessToken"], jsonbpdy["refreshToken"]);
      await updateLocation();
      // print(await http.read(Ur i.https('example.com', 'foobar.txt')));
    } catch (e) {
      print(e);
    }

    setState(() {
      _createdUser = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_createdUser) {
      return Scaffold(
        body: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
              ),
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'UserName',
                hintText: 'User Name',
              ),
            ),
            TextFormField(
              controller: _tagController,
              decoration: const InputDecoration(
                labelText: 'Tag',
                hintText: 'Enter your tag',
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: submitForm,
                child: const Text(
                  'New User',
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const Homepage();
    }
  }
}
