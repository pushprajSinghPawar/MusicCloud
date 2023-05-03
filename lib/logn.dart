// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class Aoth {
  Future<void> _handleSignOut() async {
    await FirebaseAuth.instance.signOut();
  }
  
  Future<void> _handleSignIn() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    registerToDatabase();
  }

  bool loggedin() {
    if (FirebaseAuth.instance.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  dynamic getuser() {
    if (FirebaseAuth.instance.currentUser != null) {
      return FirebaseAuth.instance.currentUser;
    } else {
      return null;
    }
  }

  void registerToDatabase() async {
    // Get the current user
    final User user = FirebaseAuth.instance.currentUser!;

    // Create a reference to the users collection
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    // Create a document reference for the current user
    final DocumentReference userDocument = usersCollection.doc(user.uid);

    // Check if the user already exists in the users collection
    userDocument.get().then((docSnapshot) {
      if (docSnapshot.exists) {
        return;
        // print('User already exists in Firestore database');
      } else {
        // Add the user's information to the document
        userDocument.set({
          'name': user.displayName,
          'email': user.email,
          'photoUrl': user.photoURL,
          'userid': user.uid,
        }).then((value) {
          return;
        }).catchError((error) {
          return;
        });
      }
    }).catchError((error) {
      return;
    });
  }
}



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = Aoth();

  void _tohomepage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MyHomePage()));
  }

  void _login() async {
    await _auth._handleSignIn();
    if (_auth.loggedin() == true) {
      _tohomepage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            width: MediaQuery.of(context).size.width,
            child: const Image(
              image: AssetImage('assets/upimage.png'),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.1,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Background color
              ),
              onPressed: () async {
                _login();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(left: 24, right: 8),
                      child: Text(
                        'Sign in with ',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Image(
                      image: AssetImage("assets/google.png"),
                      height: 60.0,
                      width: 100,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
