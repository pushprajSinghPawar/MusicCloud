// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'musicplay.dart';

class specific extends StatefulWidget {
  const specific({super.key, required this.useridd, required this.uname});
  final useridd;
  final uname;
  @override
  State<specific> createState() => _specificState();
}

class _specificState extends State<specific> {
  var unmaee = "";
  void getallsongsofuser() async {
    allSongs.clear();
    List<String> ref_ = [];
    final CollectionReference songReflist = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.useridd)
        .collection('playlist');
    final QuerySnapshot snapshot = await songReflist.get();
    for (var snaps in snapshot.docs) {
      ref_.add(snaps['poollink'] ?? "");
    }
    for (String i in ref_) {
      List<String> temp = [];
      final DocumentReference songref =
          FirebaseFirestore.instance.collection('songlists').doc(i);
      final DocumentSnapshot snapshot = await songref.get();
      temp.add(snapshot['songlink'] ?? "");
      temp.add(snapshot['thumbnaillink'] ?? "");
      temp.add(snapshot['userId'] ?? "");
      temp.add(snapshot['songname'] ?? "");
      allSongs.add(temp);

      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getallsongsofuser();
    unmaee = widget.uname;
  }
  List<List<String>> allSongs = [];
  @override
  Widget build(BuildContext context) {
    if (allSongs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('$unmaee playlist'),
        ),
        body:  Text('Nothing being uploaded by $unmaee'),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('$unmaee playlist'),
        ),
        body: ScrollWrapper(
            builder: (context, properties) => ListView.builder(
                itemCount: allSongs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      height: 250,
                      child: Column(
                        children: [
                          Image.network(
                            allSongs[index][1],
                            width: MediaQuery.of(context).size.width *
                                0.5, // set the width of the image
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AudioPlayerUrl(
                                        urlList: allSongs, index: index),
                                  ),
                                );
                              },
                              child: Text('Play  ${allSongs[index][3]}')),
                        ],
                      ),
                    ),
                  );
                })),
      );
    }
  }
}
