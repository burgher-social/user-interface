import 'package:burgher/src/Profile/auth.dart';

Future<bool> checkAlreadySignedInHelper() async {
  var tok = await getToken();
  if (tok == null) {
    return false;
  }
  return true;
}
