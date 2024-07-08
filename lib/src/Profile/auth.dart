import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Config/global.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> saveToken(String accessToken, String? refreshToken) async {
  try {
    if (refreshToken != null) {
      const storage = FlutterSecureStorage();
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

Future<String?> getToken() async {
  // String? existingToken = AppConstants.accessToken;
  String? refreshToken = AppConstants.refreshToken;
  // if (existingToken == null) {
  if (refreshToken != null) {
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
    saveToken(resp["accessToken"], resp["refreshToken"]);
    return resp["refreshToken"];
  }
  return null;
}
