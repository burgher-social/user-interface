import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Config/global.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const storage = FlutterSecureStorage();
Future<void> saveToken(String accessToken, String? refreshToken) async {
  try {
    if (refreshToken != null && isTokenValid(refreshToken)) {
      await storage.write(key: "refreshToken", value: refreshToken);
      await storage.write(key: "accessToken", value: accessToken);
      AppConstants.refreshToken = refreshToken;
      AppConstants.accessToken = accessToken;
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
    AppConstants.userId = jsonToken["userId"];
    return true;
  }
  return false;
}

Future<String?> getToken() async {
  String? tempAccessToken = AppConstants.accessToken;
  // print("tempAccessToken");
  // print(tempAccessToken);
  if (tempAccessToken != null && isTokenValid(tempAccessToken)) {
    return tempAccessToken;
  }
  String? refreshToken = await storage.read(key: "refreshToken");
  String? accessToken = await storage.read(key: "accessToken");
  // String? existingToken = AppConstants.accessToken;
  // String? refreshToken = AppConstants.refreshToken;
  // if (existingToken == null) {
  // print(refreshToken);
  // print(accessToken);
  // print(refreshToken! + accessToken!);
  if (accessToken != null) {
    // Codec<String, String> stringToBase64 = utf8.fuse(base64);
    // var jsonToken =
    //     json.decode(stringToBase64.decode(accessToken.split(".")[1]));
    // DateTime now = DateTime.now();
    // DateTime utcNow = now.toUtc(); // Convert local time to UTC
    // int epochTime = utcNow.millisecondsSinceEpoch;
    if (isTokenValid(accessToken)) {
      // print("valid tplem");
      // print(accessToken);
      return accessToken;
    } else {
      if (refreshToken != null) {
        // var jsonToken =
        //     json.decode(stringToBase64.decode(refreshToken.split(".")[1]));
        // DateTime now = DateTime.now();
        // DateTime utcNow = now.toUtc(); // Convert local time to UTC
        // int epochTime = utcNow.millisecondsSinceEpoch;
        if (isTokenValid(refreshToken)) {
          var url =
              AppConstants.protocol(AppConstants.baseurl, '/token/refresh');
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
          try {
            await saveToken(resp["accessToken"], resp["refreshToken"]);
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
}
