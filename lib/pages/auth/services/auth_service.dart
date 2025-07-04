import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "63428814218-8u0crvt3b63h8uj7roh5iq118r1e2k55.apps.googleusercontent.com",
  );
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Google Sign-In
  Future<void> googleSignIn(Function onSuccess, Function onError) async {
    try {
      await _googleSignIn.signOut(); // Ensure no existing session
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        onError("Sign-in canceled");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      
      if (user != null) {
        // Store user data in Firestore
        await firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        onSuccess();
      } else {
        onError("User not found after sign-in");
      }
    } catch (e) {
      log("Error during Google Sign-In: $e", name: "AuthService");
      print("Error during Google Sign-In: $e");
      onError(e.toString());
    }
  }

  // Sign Out
  Future<String> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      return "Success";
    } catch (e) {
      return e.toString();
    }
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}