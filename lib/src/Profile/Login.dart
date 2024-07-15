import 'package:burgher/src/Config/global.dart';
import 'package:burgher/src/Profile/auth.dart';
import 'package:burgher/src/Utils/Location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../Location/location_helper.dart';
import '../Storage/user.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:convert';
import '../Storage/local.dart' as local_storage;
import '../Feed/home_page.dart';
import 'create.dart';
import '../Utils/api.dart';
import 'login_handler.dart';

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

  Future<void> checkAlreadySignedIn() async {
    isLoggedIn = await checkAlreadySignedInHelper();
    checkedState = true;
    setState(() {});
    if (isLoggedIn) {
      await updateLocation();
    }
    return;
    // var user = await getUser();
    // print("EXISTING USER");
    // print(user);
    // if (user == null) {
    //   print("Sign in with google");
    //   setState(() {
    //     isLoggedIn = false;
    //     checkedState = true;
    //   });
    // } else {
    //   Codec<String, String> stringToBase64 = utf8.fuse(base64);
    //   var jsonToken =
    //       json.decode(stringToBase64.decode(user["token"].split(".")[1]));
    //   DateTime now = DateTime.now();
    //   DateTime utcNow = now.toUtc(); // Convert local time to UTC
    //   int epochTime = utcNow.millisecondsSinceEpoch;
    //   if (jsonToken["exp"] > epochTime) {
    //     setState(() {
    //       checkedState = true;
    //       isLoggedIn = false;
    //     });
    //     return false;
    //   }
    //   local_storage.token = user["token"];
    //   saveToken(user["token"], null);
    //   await updateLocation();
    //   setState(() {
    //     isLoggedIn = true;
    //     checkedState = true;
    //   });
    //   return true;
    // }
    // setState(() {
    //   isLoggedIn = false;
    //   checkedState = true;
    // });
    // return false;
  }

  Future<void> signInWithGoogleHelper() async {
    print("signed in with google");
    var email = "email@flutter.com";
    Map<String, dynamic> body = {};
    try {
      body = await callApi(
        "user/read/email",
        false,
        {
          "email": email,
        },
      );
    } catch (e) {
      print(e);
      return;
    }
    print(body);
    if (body.containsKey("refreshToken") && body["refreshToken"] != null) {
      await saveToken(body["accessToken"], body["refreshToken"]);
      await updateLocation();
      // local_storage.token = body["accessToken"];
      // AppConstants.accessToken = body["accessToken"];
      // AppConstants.refreshToken = body["refreshToken"];
      // AppConstants.id = body["id"];
      // AppConstants.emailId = body["emailId"];
      // AppConstants.username = body["username"];
      // AppConstants.tag = body["tag"].toString();

      print(body);
      try {
        await createUser(
          body["username"],
          body["tag"],
          body["accessToken"],
          body["emailId"],
          body["name"],
          body["isVerified"],
          body["id"],
        );
      } catch (e) {
        print(e);
        return;
      }
    } else {
      // setState(() {
      isNewUser = true;
      // });
    }

    isLoggedIn = true;
    checkedState = true;
    setState(() {});
    // setState(() {
    // });
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
