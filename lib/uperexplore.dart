import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'package:musicloud/specificuserlibrary.dart';
import 'musicplay.dart';

class UploaderExplore extends StatefulWidget {
  const UploaderExplore({super.key});

  @override
  State<UploaderExplore> createState() => _UploaderExploreState();
}

class _UploaderExploreState extends State<UploaderExplore> {
  List<List<String>> allUsers = [];
  bool multiple = true;
  int seletedindex = 0;
  List<List<String>> allsongs = [];

  // email
  // "pushprajsinghpawar7@gmail.com"
  // name
  // "085Pushpraj Singh Pawar"
  // photoUrl
  // "https://lh3.googleusercontent.com/a/AGNmyxZ0oGhiR5K83TbXmMnMDc5CN2ljlVRasfB_DT0BCw=s96-c"
  // userid
  // "vO4R2ssx2ib5IsRkJhAJFhbV5gc2"

  // void getsongsfromlist(List<String> li) async {
  //   allsongs.clear();
  //   for (String i in li) {
  //     List<String> temp = [];
  //     final DocumentReference songref =
  //         FirebaseFirestore.instance.collection('songlists').doc(i);
  //     final DocumentSnapshot snapshot = await songref.get();
  //     temp.add(snapshot['songlink'] ?? "");
  //     temp.add(snapshot['thumbnaillink'] ?? "");
  //     temp.add(snapshot['userId'] ?? "");
  //     temp.add(snapshot['songname'] ?? "");
  //     allsongs.add(temp);
  //   }
  //   // for(var i in allsongs){
  //   //   print(i);
  //   // }
  // }

  // void loadusersongs(String userid) async {
  //   List<String> ref_ = [];
  //   final CollectionReference songReflist = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(userid)
  //       .collection('playlist');
  //   final QuerySnapshot snapshot = await songReflist.get();
  //   for (var snaps in snapshot.docs) {
  //     ref_.add(snaps['poollink'] ?? "");
  //   }
  //   getsongsfromlist(ref_);
  // }

  List<List<String>> getSongPlusImageList(List<List<String>> temp) {
    List<List<String>> rt = [];
    for (var i in temp) {
      rt.add([i[0], i[1], i[3]]);
    }
    return rt;
  }

  void updateuserlist() async {
    allUsers.clear();
    final CollectionReference songlistsRef =
        FirebaseFirestore.instance.collection('users');
    final QuerySnapshot snapshot = await songlistsRef.get();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        List<String> userData = [
          data['email'] ?? "",
          data['photoUrl'] ?? "",
          data['userid'] ?? "",
          data['name'] ?? ""
        ];
        allUsers.add(userData);
      }
    }
    setState(() {
      // Update your UI with the new user data
    });
  }

  @override
  void initState() {
    updateuserlist();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return multiple
        ? Scaffold(
            appBar: AppBar(),
            body: SizedBox(
              child: ScrollWrapper(
                builder: (context, properties) => ListView.builder(
                  itemCount: allUsers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 0, 0, 0)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: CircleAvatar(
                                radius: 100,
                                backgroundImage: NetworkImage(
                                  allUsers[index][1],
                                ),
                              ),
                            ),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => specific(
                                            useridd: allUsers[index][2],
                                            uname: allUsers[index][3],
                                            ),
                                      ),
                                    );
                                    setState(() {});
                                    // loadusersongs(allUsers[index][2]);
                                  });
                                },
                                child: Center(
                                    child: Text(
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                        'check out the stuff uploaded by ${allUsers[index][3]}')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                ),
                onPressed: () {
                  multiple = true;
                  setState(() {});
                },
              ),
            ),
            body: SizedBox(
              child: ScrollWrapper(
                builder: (context, properties) => ListView.builder(
                  itemCount: allsongs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 0, 0, 0)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.network(
                              allsongs[index][1].toString(),
                              width: MediaQuery.of(context).size.width *
                                  0.5, // set the width of the image
                              height: 250, // set the height of the image
                              fit: BoxFit
                                  .fill, // adjust how the image is fit within the widget
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              List<List<String>> songPlusImageList =
                                  getSongPlusImageList(allsongs);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AudioPlayerUrl(
                                      urlList: songPlusImageList, index: 0),
                                ),
                              );
                            },
                            child: Text(allsongs[index][3]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
  }
}
