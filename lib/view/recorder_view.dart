import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AudioRecorderView extends StatefulWidget {
  @override
  _AudioRecorderViewState createState() => _AudioRecorderViewState();
}

class _AudioRecorderViewState extends State<AudioRecorderView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.mic), onPressed: _onRecordPressed),
          LinearProgressIndicator(),
        ],
      ),
    );
  }

  _onRecordPressed() {
    log('Record started');
  }
}
