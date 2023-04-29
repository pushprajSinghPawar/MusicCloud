// ignore_for_file: prefer_const_constructors, avoid_print
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'logn.dart';
import 'searcch.dart';
import 'musicplay.dart';
import 'uperexplore.dart';
import 'uploadd.dart';
import 'mylibrary.dart';

class Aoth {
  Future<void> _handleSignOut() async {
    await FirebaseAuth.instance.signOut();
  }

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _auth = Aoth();
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (_auth.loggedin()) {
      return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      );
    } else {
      return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LoginPage(),
      );
    }
  }
}

class ReusableDrawer extends StatelessWidget {
  final user = Aoth().getuser();
  final _auth = Aoth();
  ReusableDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 185, 211, 255),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.photoURL!),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(user.email!),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.my_library_music),
            title: const Text('My Uploaded songs '),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) =>  Mylibrary()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload_rounded),
            title: const Text('Upload song '),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const UploadPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout '),
            onTap: () async {
              await _auth._handleSignOut();
            },
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<List<String>> allSongs = [];
  final user = Aoth().getuser();

  // void _toLoginPage() {
  //   Navigator.push(
  //       context, MaterialPageRoute(builder: (context) => const LoginPage()));
  // }

  // void _logout() async {
  //   await Aoth()._handleSignOut();
  //   _toLoginPage();
  // }

  List<List<String>> getSongPlusImageList(List<List<String>> temp){
    List<List<String>> rt=[];
    for(var i in temp){
      rt.add([i[1], i[2], i[0]]);
      print(rt);
    }
    return rt;
  }



  void getallsongs() async {
    allSongs.clear();
    final CollectionReference songlistsRef =
        FirebaseFirestore.instance.collection('songlists');
    final snapshot = await songlistsRef.get();

    for (var doc in snapshot.docs) {
      String songname = doc['songname'].toString().trim();
      String songlink = doc['songlink'].toString().trim();
      String thumbnaillink = doc['thumbnaillink'].toString().trim();
      String userid = doc['userId'].toString().trim();
      List<String> song = [songname, songlink, thumbnaillink, userid];
      allSongs.add(song);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getallsongs();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('tuneWave'),
        actions: [
          // Navigate to the Search Screen
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const SearchPage())),
              icon: const Icon(Icons.search)),
          IconButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UploaderExplore())),
              icon: const Icon(Icons.explore_sharp)),
        ],

        // leading: Icon(Icons.person_3),
      ),
      drawer: ReusableDrawer(),
      body: ScrollWrapper(
        builder: (context, properties) => ListView.builder(
          itemCount: allSongs.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: TextButton(
                              onPressed: () async {
                                List<List<String>> songPlusImage = getSongPlusImageList(allSongs);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AudioPlayerUrl(urlList: songPlusImage, index:index),
                                    ),
                                  );
                              },
                              child: Text('${allSongs[index][0]} '))
                              ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getallsongs();
          setState(() {});
        },
        child: const Icon(Icons.restart_alt_outlined),
      ),
    );
  }
}

// https://www.megacartoons.net/