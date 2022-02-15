import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class signinServices {
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  FirebaseAuth auth = FirebaseAuth.instance;
  late User fireUser;

  Future<User> googSignIn(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      fireUser = userCredential.user!;
    }
    return fireUser;
  }

  signOut() {
    auth.currentUser != null
        ? auth.signOut()
        : print("User not signed in Firebase");
    googleSignIn.isSignedIn().then((onValue) => onValue == true
        ? googleSignIn.disconnect()
        : print("User not signed in Google"));
  }
}
