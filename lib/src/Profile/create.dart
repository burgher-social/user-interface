import 'package:burgher/src/Feed/home_page.dart';
import 'package:burgher/src/Feed/home_page_updated.dart';
import 'package:burgher/src/Utils/api.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import '../Location/location_helper.dart';

class Create extends StatefulWidget {
  const Create(
      {super.key, @required this.email, @required this.firebaseAuthToken});
  final String? email;
  final String? firebaseAuthToken;

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  var _createdUser = false;
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // a();
  }

  Future<void> submitForm() async {
    // print(_nameController.text);
    // print(_tagController.text);
    // print(_usernameController.text);
    // print(int.parse(_tagController.text));
    if (_usernameController.text.trim() == "" ||
        _nameController.text.trim() == "") {
      return;
    }
    try {
      setState(() {
        loading = true;
      });
      var response = await callApi(
          '/user/create',
          false,
          {
            'email': widget.email?.trim(),
            'tag': 0000,
            "username": _usernameController.text.trim(),
            "name": _nameController.text.trim(),
            "firebaseAuthIdToken": widget.firebaseAuthToken
          },
          ctx: context);
      print(response);
      if (response["accessToken"] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Username not available"),
          ),
        );
        setState(() {
          loading = false;
        });
        return;
      }
      await saveToken(response["accessToken"], response["refreshToken"]);
      await updateLocation();
      // print(await http.read(Ur i.https('example.com', 'foobar.txt')));
      setState(() {
        loading = false;
        _createdUser = true;
      });
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("DB error"),
        ));
      }
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_createdUser) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                contentPadding: EdgeInsets.all(20.0),
              ),
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'UserName',
                hintText: 'User Name',
                contentPadding: EdgeInsets.all(20.0),
              ),
            ),
            // TextFormField(
            //   controller: _tagController,
            //   decoration: const InputDecoration(
            //     labelText: 'Tag',
            //     hintText: 'Enter your tag',
            //     contentPadding: EdgeInsets.all(20.0),
            //   ),
            // ),
            loading
                ? const CircularProgressIndicator()
                : Center(
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
      return const HomePageUpdated();
    }
  }
}
