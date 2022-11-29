// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../posts/typedefs/user_id.dart';
import '../constants/constants.dart';
import '../model/auth_result.dart';

class Authenticator {
  const Authenticator();

  UserId? get userId => FirebaseAuth.instance.currentUser?.uid;
  bool get isAlreadyLoggedIn => userId != null;
  String get displayName =>
      FirebaseAuth.instance.currentUser?.displayName ?? '';
  String? get email => FirebaseAuth.instance.currentUser?.email;

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }

  Future<AuthResult> loginWithFacebook() async {
    final loginResult = await FacebookAuth.instance.login();

    final loginToken = loginResult.accessToken?.token;
    if (loginToken == null) {
      return AuthResult.aborted;
    }
    final oauthCredential = FacebookAuthProvider.credential(loginToken);
    try {
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      final email = e.email;
      final credential = e.credential;
      if (e.code == Constants.accountExistsWithDifferentCredential &&
          email != null &&
          credential != null) {
        final providers =
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
        if (providers.contains(Constants.googleCom)) {
          await loginWithGoogle();
          FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
          return AuthResult.success;
        }
      }
    }
    return AuthResult.failure;
  }

  Future<AuthResult> loginWithGoogle() async {
    final GoogleSignIn googleSignin = GoogleSignIn(
      scopes: [
        Constants.emailScope,
      ],
    );

    final signInAccount = await googleSignin.signIn();
    if (signInAccount == null) {
      return AuthResult.aborted;
    }

    final googleAuth = await signInAccount.authentication;
    final oAuthCredentials = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(oAuthCredentials);
      return AuthResult.success;
    } on FirebaseAuthException {
      return AuthResult.failure;
    }
  }
}
