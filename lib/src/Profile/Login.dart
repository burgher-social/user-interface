import 'package:burgher/src/Config/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../Storage/user.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:convert';
import '../Storage/local.dart' as local_storage;
import '../Feed/home_page.dart';
import 'create.dart';
import '../Utils/api.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool checkedState = false;
  bool isLoggedIn = false;
  bool isNewUser = false;
  String email = "email@flutter.com";
  @override
  void initState() {
    super.initState();
    checkAlreadySignedIn();
  }

  Future<bool> checkAlreadySignedIn() async {
    var user = await getUser();
    if (user == null) {
      print("Sign in with google");
      setState(() {
        isLoggedIn = false;
        checkedState = true;
      });
    } else {
      Codec<String, String> stringToBase64 = utf8.fuse(base64);
      var jsonToken =
          json.decode(stringToBase64.decode(user["token"].split(".")[1]));
      DateTime now = DateTime.now();
      DateTime utcNow = now.toUtc(); // Convert local time to UTC
      int epochTime = utcNow.millisecondsSinceEpoch;
      if (jsonToken["exp"] > epochTime) {
        setState(() {
          checkedState = true;
          isLoggedIn = false;
        });
        return false;
      }
      local_storage.token = user["token"];
      setState(() {
        isLoggedIn = true;
        checkedState = true;
      });
      return true;
    }
    setState(() {
      isLoggedIn = false;
      checkedState = true;
    });
    return false;
  }

  Future<void> signInWithGoogleHelper() async {
    print("signed in with google");
    var email = "email@email.com";
    Map<String, dynamic> body = {};
    try {
      body = await callApi(
        "user/read/email",
        false,
        {"email": email},
      );
    } catch (e) {
      print(e);
    }
    print(body);
    if (body.containsKey("refreshToken") && body["refreshToken"] != null) {
      local_storage.token = body["accessToken"];
      AppConstants.accessToken = body["accessToken"];
      AppConstants.refreshToken = body["refreshToken"];
    } else {
      setState(() {
        isNewUser = true;
      });
    }
    setState(() {
      isLoggedIn = true;
      checkedState = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!checkedState) {
      return const Placeholder();
    } else {
      if (isNewUser) {
        return Create(
          email: email,
        );
      }
      if (isLoggedIn) {
        return const Homepage();
      }
      return Scaffold(
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: signInWithGoogleHelper,
                child: const Text(
                  "Sign in with google",
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}
