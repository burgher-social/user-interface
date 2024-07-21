import 'dart:convert';
import 'package:burgher/src/Config/global.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import '../Profile/Auth.dart';

Future<Map<String, dynamic>> callApi(
    String path, bool useAuth, Map<String, dynamic>? body) async {
  var url = AppConstants.protocol(AppConstants.baseurl, path);
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
  print(response.body);
  final decoded = json.decode(response.body);
  if (decoded is List) {
    print("fixing list");
    return {"response": decoded};
  }
  return decoded;
}

Future<void> callFormData(String path, File file, bool useAuth) async {
  print(file);
  final bytes = file.readAsBytes();
  print(bytes);
  Map<String, String> headers = {"Content-Type": "multipart/form-data"};
  if (useAuth) {
    print(AppConstants.accessToken);
    headers["Authorization"] = (AppConstants.accessToken ?? await getToken())!;
    //TODO: if this returns null, redirect to sign in page.
  }
  var url = AppConstants.protocol(AppConstants.baseurl, path);
  var request = http.MultipartRequest("POST", url);
  print(bytes.asStream());
  final httpImage = http.MultipartFile.fromBytes('file', await bytes,
      filename: basename(file.path));
  // request.files.add(
  //   http.MultipartFile(
  //     'file',
  //     bytes.asStream(),
  //     file.lengthSync(),
  //   ),
  // );
  request.files.add(httpImage);
  request.headers.addAll(headers);
  print(request.files);
  print("Sending image on network");
  try {
    var resp = await request.send();
    print(utf8.decode(await resp.stream.toBytes()));
  } catch (e, stk) {
    print(e);
    print(stk);
  }
}
