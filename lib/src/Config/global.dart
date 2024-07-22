class AppConstants {
  static String? accessToken;
  static String? refreshToken;
  static String? userId;
  static String? username;
  static String? tag;
  static String? emailId;
  static double? latitude;
  static double? longitude;
  static String baseurl =
      // "192.168.0.112:8080";
      "feed-tuq4sgj4pa-el.a.run.app";
  static Uri Function(String, [String, Map<String, dynamic>?]) protocol =
      // Uri.http;
      Uri.https;
}
