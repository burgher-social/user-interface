import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Config/global.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const storage = FlutterSecureStorage();
Future<void> saveToken(String accessToken, String? refreshToken) async {
  try {
    if (refreshToken != null) {
      // const storage = FlutterSecureStorage();
// Read value
      // String? value = await storage.read(key: "refreshToken");
      // print(value);

// Read all values

// Delete value
      // await storage.delete(key: key);

// Delete all
      // await storage.deleteAll();

// Write value
      await storage.write(key: "refreshToken", value: refreshToken);
      await storage.write(key: "accessToken", value: accessToken);
      AppConstants.refreshToken = refreshToken;
      AppConstants.accessToken = accessToken;
      // print("written sage strefa");

      // Map<String, String> allValues = await storage.readAll();
      // print(allValues);
    }
  } catch (e) {
    print(e);
  }
}

bool isTokenValid(String token) {
  Codec<String, String> stringToBase64 = utf8.fuse(base64);
  var jsonToken = json.decode(stringToBase64.decode(token.split(".")[1]));
  DateTime now = DateTime.now();
  DateTime utcNow = now.toUtc(); // Convert local time to UTC
  int epochTime = (utcNow.millisecondsSinceEpoch / 1000).round();
  if (jsonToken["exp"] > epochTime) {
    print("TOKEN VALID!");
    return true;
  }
  return false;
}

Future<String?> getToken() async {
  String? tempAccessToken = AppConstants.accessToken;
  print("tempAccessToken");
  print(tempAccessToken);
  if (tempAccessToken != null && isTokenValid(tempAccessToken)) {
    print("returning temp access toklen");
    return tempAccessToken;
  }
  String? refreshToken = await storage.read(key: "refreshToken");
  String? accessToken = await storage.read(key: "accessToken");
  // String? existingToken = AppConstants.accessToken;
  // String? refreshToken = AppConstants.refreshToken;
  // if (existingToken == null) {
  print(refreshToken);
  print(accessToken);
  // print(refreshToken! + accessToken!);
  if (accessToken != null) {
    // Codec<String, String> stringToBase64 = utf8.fuse(base64);
    // var jsonToken =
    //     json.decode(stringToBase64.decode(accessToken.split(".")[1]));
    // DateTime now = DateTime.now();
    // DateTime utcNow = now.toUtc(); // Convert local time to UTC
    // int epochTime = utcNow.millisecondsSinceEpoch;
    if (isTokenValid(accessToken)) {
      print("valid tplem");
      print(accessToken);
      return accessToken;
    } else {
      if (refreshToken != null) {
        // var jsonToken =
        //     json.decode(stringToBase64.decode(refreshToken.split(".")[1]));
        // DateTime now = DateTime.now();
        // DateTime utcNow = now.toUtc(); // Convert local time to UTC
        // int epochTime = utcNow.millisecondsSinceEpoch;
        if (isTokenValid(refreshToken)) {
          print("valid refrest");
          print(refreshToken);
          var url = Uri.http('localhost:8080', '/token/refresh');
          print(url);
          var response = await http.post(
            url,
            headers: {
              "Content-Type": "application/json",
            },
            body: json.encode(
              {
                "refreshToken": refreshToken,
              },
            ),
          );
          if (response.statusCode == 401) return null;
          var resp = json.decode(response.body);
          print(resp);
          print("resp for token refresh");
          try {
            saveToken(resp["accessToken"], resp["refreshToken"]);
          } catch (e) {
            print(e);
          }

          return resp["accessToken"];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }
  return null;
  // if (refreshToken != null) {
  //   var url = Uri.http('localhost:8080', '/token/refresh');
  //   print(url);
  //   var response = await http.post(
  //     url,
  //     headers: {
  //       "Content-Type": "application/json",
  //     },
  //     body: json.encode(
  //       {
  //         "refreshToken": refreshToken,
  //       },
  //     ),
  //   );
  //   if (response.statusCode == 401) return null;
  //   var resp = json.decode(response.body);
  //   saveToken(resp["accessToken"], resp["refreshToken"]);
  //   return resp["refreshToken"];
  // }
  // return null;
}
