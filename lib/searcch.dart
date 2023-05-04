// ignore_for_file: prefer_const_constructors, unused_local_variable, avoid_print, await_only_futures, dead_code, unused_element, prefer_const_literals_to_create_immutables, must_be_immutable, avoid_unnecessary_containers
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'logn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'musicplay.dart';

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

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController a = TextEditingController();
  String url =
      "https://firebasestorage.googleapis.com/v0/b/musikloud-19c61.appspot.com/o/music%2Ftyop?alt=media&token=87ef81bb-61db-493c-a81b-399771a8fd1a";

  bool mag = false;
  bool show = false;
  bool nothing = true;

  List<List<String>> allSongs = [];
  final user = Aoth().getuser();

  void _toLoginPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _logout() async {
    await Aoth()._handleSignOut();
    _toLoginPage();
  }

  void getallsongsby(String element) async {
    if (element == "") {
      return;
    }
    allSongs.clear();
    HashMap dictPerm = HashMap<String, int>();
    for (int i = 0; i < element.length; i++) {
      if (dictPerm.containsKey(element[i])) {
        dictPerm[element[i]] = dictPerm[element[i]] + 1;
      } else {
        dictPerm[element[i]] = 1;
      }
    }
    final CollectionReference songlistsRef =
        FirebaseFirestore.instance.collection('songlists');
    final snapshot = await songlistsRef.get();

    for (var doc in snapshot.docs) {
      String songname = doc['songname'].toString().trim();
      String songlink = doc['songlink'].toString().trim();
      String thumbnaillink = doc['thumbnaillink'].toString().trim();
      String userid = doc['userId'].toString().trim();
      List<String> song = [songname, songlink, thumbnaillink, userid];
      double score = 0;
      for (int i = 0; i < songname.length; i++) {
        if (songname[i] == " ") {
          continue;
        }
        if (dictPerm.containsKey(songname[i])) {
          score += 1;
        }
      }
      double matchscore = (score.toDouble() / songname.length.toDouble()) * 100;
      if (matchscore > 45) {
        allSongs.add(song);
      }
      if (allSongs.isEmpty) {
        nothing = true;
      } else {
        nothing = false;
      }
      setState(() {});
    }
  }

  List<List<String>> getSongPlusImageList(List<List<String>> temp) {
    List<List<String>> rt = [];
    for (var i in temp) {
      rt.add([i[1], i[2], i[0]]);
    }
    return rt;
  }

  @override
  void initState() {
    super.initState();
    getallsongsby("");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: nothing
          ? Center(
              child: Container(
                child: Text('Nothing to show here .  .   . . . . . '),
              ),
            )
          : ScrollWrapper(
              builder: (context, properties) => ListView.builder(
                itemCount: allSongs.length,
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 30000,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromARGB(255, 72, 67, 67)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Image.network(
                                  allSongs[index][2].toString(),
                                  width: MediaQuery.of(context).size.width *
                                      0.5, // set the width of the image
                                  height: 250, // set the height of the image
                                  fit: BoxFit
                                      .fill, // adjust how the image is fit within the widget
                                ),
                              ),
                              Center(
                                  child: TextButton(
                                      onPressed: () async {
                                        List<List<String>> songPlusImageList =
                                            getSongPlusImageList(allSongs);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AudioPlayerUrl(
                                                    urlList: songPlusImageList,
                                                    index: 0),
                                          ),
                                        );
                                      },
                                      child: Text('${allSongs[index][0]} '))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                // print('object');
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
          // The search area here
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: TextField(
                controller: a,
                decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        a.text = "";
                      },
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        getallsongsby(a.text.toString());
                        setState(() {});
                      },
                    ),
                    hintText: 'search by name...',
                    border: InputBorder.none),
              ),
            ),
          )),
    );
  }
}
