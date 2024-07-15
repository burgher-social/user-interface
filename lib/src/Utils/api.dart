import 'dart:convert';
import 'package:burgher/src/Config/global.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../Profile/Auth.dart';

Future<Map<String, dynamic>> callApi(
    String path, bool useAuth, Map<String, dynamic>? body) async {
  var url = Uri.http('localhost:8080', path);
  print(body);
  print(url);
  // var response = await http.post(url, body: {
  //   'email': 'shobhit@email.com',
  //   'tag': int.parse(_tagController.text),
  //   "username": _usernameController.text,
  //   "name": _nameController.text
  // });
  var headers = {
    "Content-Type": "application/json",
  };
  if (useAuth) {
    print(AppConstants.accessToken);
    headers["Authorization"] = (AppConstants.accessToken ?? await getToken())!;
    //TODO: if this returns null, redirect to sign in page.
  }
  var response = await http.post(
    url,
    headers: headers,
    body: json.encode(body),
  );
  return json.decode(response.body);
}

Future<void> callFormData(String path, File file) async {
  print(file);
  final bytes = file.readAsBytes();
  print(bytes);
  var url = Uri.http('localhost:8080', path);
  var request = http.MultipartRequest("POST", url);

  request.files.add(
    http.MultipartFile(
      'file',
      bytes.asStream(),
      file.lengthSync(),
    ),
  );
  var resp = await request.send();
  print(resp);
}
