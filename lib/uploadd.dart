// ignore_for_file: prefer_const_constructors, unused_local_variable, avoid_print, await_only_futures, dead_code, unused_element, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  TextEditingController songName = TextEditingController();
  bool imageselected = false;
  bool songselected = false;
  bool uploaded = false;
  File? filesong, fileimage;
  bool uploadfaliure = false;
  bool uploading = false;

  void selectSong() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      filesong = File(result.files.single.path!);
      setState(() {
        songselected = true;
      });
    }
  }

  void selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      fileimage = File(result.files.single.path!);
      setState(() {
        imageselected = true;
      });
    }
  }

  void saveTodbOfAllSongs(String a, String b, String c) async {
    final CollectionReference songlistsRef =
        FirebaseFirestore.instance.collection('songlists');
    final user = Aoth().getuser();
    final newDocRef = songlistsRef.doc();
    await newDocRef.set({
      'songname': c,
      'songlink': a,
      'thumbnaillink': b,
      'userId': user.uid,
    });
    var did = newDocRef.id;
    var second = newDocRef.firestore.toString();
    saveToUserTable(did);
    // print('Values stored in Firestore');
  }

  void saveToUserTable(String a) async {
    final currentUser = FirebaseAuth.instance.currentUser!;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection("playlist")
        .add({
          'poollink': a,
        });
  }

  void _uploadtocloud() async {
    //File? filesong,fileimage; initialized outside the function
    String? string1;
    String? string2;

    setState(() {
      uploading = true;
    });
    String songname = songName.text.toString();
    String thumbnail = '${songName.text}thumbnail';

    final Reference storageRef =
        FirebaseStorage.instance.ref().child('music/$songname');
    final UploadTask uploadTaskSong = storageRef.putFile(filesong!);
    final Reference storageRefimage =
        FirebaseStorage.instance.ref().child('image/$thumbnail');
    final UploadTask uploadTaskimage = storageRefimage.putFile(fileimage!);
    final TaskSnapshot snapshot1 = await uploadTaskSong;
    final TaskSnapshot snapshot2 = await uploadTaskimage;

    string1 = await storageRef.getDownloadURL();
    string2 = await storageRefimage.getDownloadURL();

    if (snapshot1.state == TaskState.success &&
        snapshot2.state == TaskState.success) {
      setState(() {
        uploaded = true;
        songName.clear();
        uploading = false;
        saveTodbOfAllSongs(string1!, string2!, songname);
      });
    } else {
      setState(() {
        uploadfaliure = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          
          height: MediaQuery.of(context).size.height * 2,
          width: double.infinity,
          child: Column(children: [
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.65,
              child: Image.asset(
                'assets/upimg.png',
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: TextField(
                controller: songName,
                decoration: InputDecoration(
                  hintText: 'Song Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            if (songselected == false)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: selectSong,
                child: Text('Select song'),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {},
                child: Text('Song is selected'),
              ),
            if (imageselected == false)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: selectImage,
                child: Text('Select image'),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {},
                child: Text('Image is selected'),
              ),
            if (imageselected && songselected)
              if (uploaded == false)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: () {
                    _uploadtocloud();
                  },
                  child: SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text('Upload to cloud'),
                        Icon(Icons.cloud_upload)
                      ],
                    ),
                  ),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {},
                  child: SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text('Uploaded to cloud'),
                        Icon(Icons.cloud_done_rounded)
                      ],
                    ),
                  ),
                ),
            if (uploadfaliure == true)
              SizedBox(
                height: 300,
                width: double.infinity,
                child: Text('Song Upload is failed please upload once again'),
              ),
            if (uploading == true)
              LinearProgressIndicator(
                backgroundColor: Colors.redAccent,
                valueColor: AlwaysStoppedAnimation(Colors.green),
                minHeight: 20,
              ),
            if (imageselected && songselected)
              if (uploaded == true)
                ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    onPressed: () {
                      setState(() {
                        uploading = false;
                        imageselected = false;
                        songselected = false;
                        uploaded = false;
                      });
                    },
                    child: Text('New Song Upload')),
          ]),
        ),
      ),
    );
  }
}
