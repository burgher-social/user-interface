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

  bool loading = false;
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
  }

  Future<(UserCredential, String?)> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
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
    return (res, res2);
  }

  Future<void> signInWithGoogleHelper() async {
    setState(() {
      loading = true;
    });
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("API error"),
        ));
      }
      setState(() {
        loading = false;
      });
      print(e);
      return;
    }
    if (body.containsKey("refreshToken") && body["refreshToken"] != null) {
      await saveToken(body["accessToken"], body["refreshToken"]);
      await updateLocation();
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("DB error"),
          ));
        }
        setState(() {
          loading = false;
        });
        return;
      }
    } else {
      isNewUser = true;
    }

    isLoggedIn = true;
    checkedState = true;
    loading = false;
    setState(() {});
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
          child: loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
