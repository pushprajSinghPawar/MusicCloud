
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Aoth {
  // Future<void> _handleSignOut() async {
  //   await FirebaseAuth.instance.signOut();
  // }

  // Future<void> _handleSignIn() async {
  //   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //   final GoogleSignInAuthentication? googleAuth =
  //       await googleUser?.authentication;
  //   final credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth?.accessToken,
  //     idToken: googleAuth?.idToken,
  //   );
  //   await FirebaseAuth.instance.signInWithCredential(credential);
  //   registerToDatabase();
  // }

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

class Mylibrary extends StatefulWidget {
  const Mylibrary({super.key});

  @override
  State<Mylibrary> createState() => _MylibraryState();
}

class _MylibraryState extends State<Mylibrary> {
  final user = Aoth().getuser();
  // final _auth = Aoth();
  List<String> poollinkList = [];
  List<String> userlpayList = [];
  List<List<String>> songnamesplusid = [];


  void getallmysongs() async {
    songnamesplusid.clear();
    poollinkList.clear();
    userlpayList.clear();

    final CollectionReference songReflist = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('playlist');
    final QuerySnapshot snapshot = await songReflist.get();
    for (var snaps in snapshot.docs) {
      poollinkList.add(snaps['poollink']);
      userlpayList.add(snaps.id);
    }
    for (var i in poollinkList) {
      final DocumentReference songrefl =
          FirebaseFirestore.instance.collection('songlists').doc(i);
      final DocumentSnapshot snapshotn = await songrefl.get();
      final List<String> temp1 = [];
      temp1.add(snapshotn['songlink'] ?? "");
      temp1.add(snapshotn['thumbnaillink'] ?? "");
      temp1.add(snapshotn['userId'] ?? "");
      temp1.add(snapshotn['songname'] ?? "");
      temp1.add(snapshotn.id);
      songnamesplusid.add(temp1);
    }
    setState(() {});
  }

  void deletefromeverywhere(String docid, int poollinkindex) async{

    String songpath = 'music/${songnamesplusid[poollinkindex][3]}';
    String imagepath = 'image/${songnamesplusid[poollinkindex][3]}thumbnail';
    
    try {
    await FirebaseStorage.instance.ref(songpath).delete();
    await FirebaseStorage.instance.ref(imagepath).delete();
    // print('Files deleted successfully.');
  } catch (e) {
    // print('Error deleting files: $e');
  }




    //to be deleted from songlist table ...
    // print(poollinkList[poollinkindex]);
    try {
    await FirebaseFirestore.instance
        .collection('songlists')
        .doc(poollinkList[poollinkindex])
        .delete();
    // print('Document ${poollinkList[poollinkindex]} deleted successfully.');
  } catch (e) {
    // print('Error deleting document: $e');
  }

    //to be deleted from user->playlist table 
    // print(userlpayList[poollinkindex]);
    try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('playlist')
        .doc(userlpayList[poollinkindex])
        .delete();
    // print('Document ${userlpayList[poollinkindex]} deleted successfully.');
  } catch (e) {
    // print('Error deleting document: $e');
  }
  getallmysongs();

  setState(() {
    
  });
  }

  @override
  void initState() {
    super.initState();
    getallmysongs();
  }

  @override
  Widget build(BuildContext context) {
    
    if(songnamesplusid.isNotEmpty)
    {return Scaffold(
      appBar: AppBar(),
      body: ScrollWrapper(
        builder: (context, properties) => ListView.builder(
          itemCount: songnamesplusid.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                height: 70,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text((songnamesplusid[index][3]).toString()),
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Delete ',
                                  ),
                                  content: Text(
                                    'Confirm Deleting !!  ${songnamesplusid[index][3].toString()}  !!  ',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        deletefromeverywhere(songnamesplusid[index][4].toString(), index);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              });
                        },
                        icon:const  Icon(Icons.delete_forever),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );}
    else{
    return Scaffold(
      appBar: AppBar(),
      body: const Text('You have not uploaded anything'),
    );}
  }
}
