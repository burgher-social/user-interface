import './dbinit.dart';

Future<Map<String, dynamic>?> getUser() async {
  var thisdb = await getDb();
  var users = await thisdb?.rawQuery("SELECT * FROM users;");
  if (users == null || users.isEmpty) {
    return null;
  }
  return users[0];
}

Future<void> deleteUsers() async {
  var thisdb = await getDb();
  await thisdb?.rawQuery("DELETE FROM users;");
}

Future<void> updateUserToken(token, username, tag) async {
  var thisdb = await getDb();
  await thisdb?.rawQuery(
      "UPDATE users SET token = $token WHERE username = $username and tag = $tag;");
}

Future<void> createUser(username, tag, token, emailId, name, isVerfied) async {
  var thisdb = await getDb();
  await thisdb?.rawQuery(
      "INSERT INTO users (username, name, tag, email_id, is_verified, token) VALUES (?, ?, ?, ?, ?, ?);",
      [
        username,
        name,
        tag,
        emailId,
        isVerfied,
      ]);
}
