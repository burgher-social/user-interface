import 'package:burgher/src/Feed/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  var _createdUser = false;
  Future<void> submitForm() async {
    print(_nameController.text);
    print(_tagController.text);
    print(_usernameController.text);

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
