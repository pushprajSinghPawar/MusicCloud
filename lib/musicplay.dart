// ignore_for_file: prefer_const_constructors, avoid_print, unused_import, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_typing_uninitialized_variables
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:audioplayers/audioplayers.dart';

// AudioPlayerUrl({Key? key, required this.urlList, required this.index}) : super(key: key);
//   final List<List<String>> urlList;
//   var index;

class AudioPlayerUrl extends StatefulWidget {
  AudioPlayerUrl({super.key, required this.urlList, required this.index});
  final List<List<String>> urlList;
  final index;
  @override
  _AudioPlayerUrlState createState() => _AudioPlayerUrlState();
}

class _AudioPlayerUrlState extends State<AudioPlayerUrl> {
  AudioPlayer audioPlayer = AudioPlayer();
  PlayerState audioPlayerState = PlayerState.paused;
  int timeProgress = 0;
  int audioDuration = 0;
  late int varindex=0;

  Widget slider() {
    return Container(
      color: Color.fromARGB(255, 183, 197, 204),
      width: 300.0,
      child: Slider.adaptive(
          value: timeProgress.toDouble(),
          max: audioDuration.toDouble(),
          onChanged: (value) {
            seekToSec(value.toInt());
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    varindex = widget.index;
    playMusic();
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        audioPlayerState = state;
      });
    });

    audioPlayer.setSource(UrlSource(widget.urlList[0][
        0])); // Triggers the onDurationChanged listener and sets the max duration string
    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        audioDuration = duration.inSeconds;
      });
    });
    audioPlayer.onPositionChanged.listen((Duration position) async {
      setState(() {
        timeProgress = position.inSeconds;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  playMusic() async {
    // Add the parameter "isLocal: true" if you want to access a local file
    await audioPlayer.play(UrlSource(widget.urlList[varindex][0]));
    setState(() {
      
    });
  }


  pauseMusic() async {
    await audioPlayer.pause();

  }

  void seekToSec(int sec) {
    Duration newPos = Duration(seconds: sec);
    audioPlayer
        .seek(newPos); // Jumps to the given position within the audio file
    setState(() {});
  }

  String getTimeString(int seconds) {
    String minuteString =
        '${(seconds / 60).floor() < 10 ? 0 : ''}${(seconds / 60).floor()}';
    String secondString = '${seconds % 60 < 10 ? 0 : ''}${seconds % 60}';
    return '$minuteString:$secondString'; // Returns a string with the format mm:ss
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            audioPlayer.dispose();
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: const [
            Color.fromARGB(255, 157, 255, 208),
            Color.fromARGB(255, 255, 194, 164)
          ]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    border: Border.all(
                      color: Colors.black,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: LinearGradient(colors: const [
                      Color.fromARGB(255, 169, 181, 248),
                      Colors.blueAccent
                    ]),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 2.0,
                          offset: Offset(2.0, 2.0))
                    ]),
                child: Image.network(
                  widget.urlList[varindex][1],
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: MediaQuery.of(context).size.height * 0.40,
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              iconSize: 30,
                              onPressed: () {
                                if (varindex != 0) {
                                   varindex = varindex - 1;
                                  playMusic();
                                } else {
                                  //show alert message that no more backward traversal can be done.
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                              'List is already at the beginning'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        );
                                      });
                                }
                                setState(() {
                                  
                                });
                              },
                              icon: Icon(Icons.arrow_back_ios_new_sharp)),
                          IconButton(
                              iconSize: 50,
                              onPressed: () {
                                audioPlayerState == PlayerState.playing
                                    ? pauseMusic()
                                    : playMusic();
                              },
                              icon: Icon(audioPlayerState == PlayerState.playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded)),
                          IconButton(
                              iconSize: 30,
                              onPressed: () {
                                if (varindex == widget.urlList.length - 1) {
                                  //show alert message that list is over
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                              'List is at the end'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        );
                                      });
                                } else {
                                  varindex = varindex + 1;
                                  playMusic();
                                }
                                setState(() {
                                  
                                });
                              },
                              icon: Icon(Icons.arrow_forward_ios)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(getTimeString(timeProgress)),
                          SizedBox(width: 20),
                          SizedBox(width: 200, child: slider()),
                          SizedBox(width: 20),
                          Text(getTimeString(audioDuration))
                        ],
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
