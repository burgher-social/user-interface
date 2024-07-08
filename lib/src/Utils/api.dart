import 'dart:convert';
import 'package:http/http.dart' as http;

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
  var response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: json.encode(body),
  );
  return json.decode(response.body);
}
