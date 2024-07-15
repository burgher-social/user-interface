import 'dart:convert';

import 'package:burgher/src/Profile/auth.dart';

import '../Storage/user.dart';

Future<bool> checkAlreadySignedInHelper() async {
  // var user = await getUser();
  // print("EXISTING USER");
  // print(user);
  // if (user == null) {
  //   print("Sign in with google");
  //   return false;
  //   // setState(() {
  //   //   isLoggedIn = false;
  //   //   checkedState = true;
  //   // });
  // } else {
  //   // Codec<String, String> stringToBase64 = utf8.fuse(base64);
  //   // var jsonToken =
  //   //     json.decode(stringToBase64.decode(user["token"].split(".")[1]));
  //   // DateTime now = DateTime.now();
  //   // DateTime utcNow = now.toUtc(); // Convert local time to UTC
  //   // int epochTime = utcNow.millisecondsSinceEpoch;
  var tok = await getToken();
  print("Existing token");
  print(tok);
  if (tok == null) {
    return false;
  }
  return true;
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
  // }
}
