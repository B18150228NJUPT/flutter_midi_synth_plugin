import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_midi_synth/flutter_midi_synth.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final midiSynth = FlutterMidiSynth();

  String _platformVersion = 'Unknown';
  String _value = 'assets/Piano.sf2';
  var dura = <double>[0.25,0.5,1,1.5,2,3];
  var whiteKeys =<List>[] ;

  @override
  void initState() {
    load(_value);
    super.initState();
    initPlatformState();
  }

  void load(String asset) async {
    print('Loading File...');
    ByteData _byte = await rootBundle.load(asset);
    midiSynth.prepare(sf2: _byte, name: _value.replaceAll('assets/', ''));

    //init whiteKeys
    var whiteIDs = [0, 2, 4, 5, 7, 9, 11];
    for (var i = 1, x = 0; i < 6; i++) {
      var temp = <int>[];
      for (var j = 0; j < 7; j++, x += 16) {
        var keyNum = i * 12 + whiteIDs[j] + 24;
        temp.add(keyNum);
      }
      whiteKeys.add(temp);
    }
  }


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await FlutterMidiSynth.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize:MainAxisSize.max,

            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(onPressed: (){play();}, child: Text('playTrack')),
              ElevatedButton(onPressed: (){click(1, 2, 6);}, child: Text("middle c"))

            ]
        ),
      ),
    );
  }

  void play(){
    var track = <List>[
      [3,3,4],
      [5,3,2],
      [1,3,2],
      [7,2,2],
      [6,2,2],
      [1,3,2],

      [5,3,5],
      [-1,-1,3],
      [1,3,2],
      [2,3,2],

      [3,3,4],
      [6,3,2],
      [5,3,2],
      [3,3,2],
      [2,3,2],
      [1,3,1],

      [3,3,6],
      [5,3,2],
      [6,3,2],
      [6,3,2],

      [6,3,4],
      [5,3,2],
      [7,2,2],
      [7,2,1],
      [6,2,1],
      [7,2,2],
      [1,3,2],

      [2,3,6],
      [3,3,2],
      [5,3,2],

      [3,3,3],
      [5,3,2],
      [3,3,2],
      [2,3,2],
      [2,3,1],
      [2,3,1],
      [1,3,2],
      [6,2,2],

      [1,3,5],
      [-1,-1,3],
      [5,2,3],
    ];
    //0.25,0.5,1,1.5,2,3

    for(var i=0;i<track.length;i++){
      var temp = track[i];
      click(temp[0], temp[1], temp[2]);
    }
  }

  void click(var numKey , var level ,var duration){
    if(numKey==-1){
      sleep(Duration(milliseconds: (dura[duration-1]*500).toInt()));
      return;
    }
    midiSynth.playMidiNote(midi: whiteKeys[level][numKey-1]);
    sleep(Duration(milliseconds: (dura[duration-1]*500).toInt()));
    midiSynth.stopMidiNote(midi: whiteKeys[level][numKey-1]);
  }
}
