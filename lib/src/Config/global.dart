class AppConstants {
  static String? accessToken;
  static String? refreshToken;
  static String? userId;
  static String? username;
  static String? tag;
  static String? emailId;
  static String baseurl = "192.168.0.112:8080";
  static Uri Function(String, [String, Map<String, dynamic>?]) protocol =
      Uri.http;
}
