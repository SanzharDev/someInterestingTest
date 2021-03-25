import 'package:flutter/material.dart';
import 'package:flutter_sound_trial/Recorder/audio_stream_recorder.dart';

void main() {
  runApp(HomeWidget());
}

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AudioStreamRecorder(),
    );
  }
}

/*
Scaffold(
        appBar: AppBar(
          title: Text('Hello'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: Text('Body'),
            ),
            BottomControlPanelView(),
          ],
        ),
      ),
 */
