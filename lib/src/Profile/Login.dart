import 'package:burgher/src/Profile/auth.dart';
import 'package:flutter/material.dart';
import '../Location/location_helper.dart';
import '../Storage/user.dart';
import '../Feed/home_page.dart';
import 'create.dart';
import '../Utils/api.dart';
import 'login_handler.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

const List<String> scopes = <String>[
  'https://www.googleapis.com/auth/userinfo.email',
  "https://www.googleapis.com/auth/userinfo.profile",
];

// GoogleSignIn _googleSignIn = GoogleSignIn(
//   // Optional clientId
//   clientId:
//       '364535468864-0k1lni5d5p8gujjgceush368ed2iuljh.apps.googleusercontent.com',
//   scopes: scopes,
// );

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool checkedState = false;
  bool isLoggedIn = false;
  bool isNewUser = false;
  String? email;
  String? firebaseAuthToken;
  @override
  void initState() {
    super.initState();
    checkAlreadySignedIn();
  }

  Future<void> checkAlreadySignedIn() async {
    isLoggedIn = await checkAlreadySignedInHelper();
    checkedState = true;
    setState(() {});
    if (isLoggedIn) {
      await updateLocation();
    }
    return;
    // var user = await getUser();
    // print("EXISTING USER");
    // print(user);
    // if (user == null) {
    //   print("Sign in with google");
    //   setState(() {
    //     isLoggedIn = false;
    //     checkedState = true;
    //   });
    // } else {
    //   Codec<String, String> stringToBase64 = utf8.fuse(base64);
    //   var jsonToken =
    //       json.decode(stringToBase64.decode(user["token"].split(".")[1]));
    //   DateTime now = DateTime.now();
    //   DateTime utcNow = now.toUtc(); // Convert local time to UTC
    //   int epochTime = utcNow.millisecondsSinceEpoch;
    //   if (jsonToken["exp"] > epochTime) {
    //     setState(() {
    //       checkedState = true;
    //       isLoggedIn = false;
    //     });
    //     return false;
    //   }
    //   local_storage.token = user["token"];
    //   saveToken(user["token"], null);
    //   await updateLocation();
    //   setState(() {
    //     isLoggedIn = true;
    //     checkedState = true;
    //   });
    //   return true;
    // }
    // setState(() {
    //   isLoggedIn = false;
    //   checkedState = true;
    // });
    // return false;
  }

  Future<(UserCredential, String?)> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    print("GETTING LOGIN INFO");
    // print(res);
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    var res = await FirebaseAuth.instance.signInWithCredential(credential);
    var res2 = await FirebaseAuth.instance.currentUser?.getIdToken();
    print(res2);
    print("");
    print("");
    print("");
    print(res);

    return (res, res2);
  }

  Future<void> signInWithGoogleHelper() async {
    print("signed in with google");
    Map<String, dynamic> body = {};
    var (signInInfo, idtok) = await signInWithGoogle();
    firebaseAuthToken = idtok;
    email = signInInfo.additionalUserInfo?.profile?["email"];
    try {
      body = await callApi(
        "user/read/email",
        false,
        {
          "email": signInInfo.additionalUserInfo?.profile?["email"],
          "accessToken": signInInfo.credential?.accessToken,
          "profilePicture": signInInfo.additionalUserInfo?.profile?["picture"],
        },
      );
    } catch (e) {
      print(e);
      return;
    }
    print(body);
    if (body.containsKey("refreshToken") && body["refreshToken"] != null) {
      await saveToken(body["accessToken"], body["refreshToken"]);
      await updateLocation();
      // local_storage.token = body["accessToken"];
      // AppConstants.accessToken = body["accessToken"];
      // AppConstants.refreshToken = body["refreshToken"];
      // AppConstants.id = body["id"];
      // AppConstants.emailId = body["emailId"];
      // AppConstants.username = body["username"];
      // AppConstants.tag = body["tag"].toString();

      print(body);
      try {
        await createUser(
          body["username"],
          body["tag"],
          body["accessToken"],
          body["emailId"],
          body["name"],
          body["isVerified"],
          body["id"],
        );
      } catch (e) {
        print(e);
        return;
      }
    } else {
      // setState(() {
      isNewUser = true;
      // });
    }

    isLoggedIn = true;
    checkedState = true;
    setState(() {});
    // setState(() {
    // });
  }

  @override
  Widget build(BuildContext context) {
    if (!checkedState) {
      return const Placeholder();
    } else {
      if (isNewUser) {
        return Create(
          email: email,
          firebaseAuthToken: firebaseAuthToken,
        );
      }
      if (isLoggedIn) {
        return const Homepage();
      }
      return Scaffold(
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: signInWithGoogleHelper,
                child: const Text(
                  "Sign in with google",
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}
