import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class BottomControlPanelView extends StatefulWidget {
  @override
  _BottomControlPanelViewState createState() => _BottomControlPanelViewState();
}

class _BottomControlPanelViewState extends State<BottomControlPanelView> {
  FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  FlutterSoundPlayer _soundPlayer = FlutterSoundPlayer();
  bool _isRecorderInitialized = false;
  bool _isSoundPlayerInitialized = false;
  bool _isRecordReadyToPlay = false;
  String _filePath = 'record1.wav';

  @override
  void initState() {
    //init soundPlayer
    _soundPlayer.openAudioSession().then((_) {
      setState(() {
        _isSoundPlayerInitialized = true;
      });
    });
    //init soundRecorder
    openTheRecorder().then((_) {
      setState(() {
        _isRecorderInitialized = true;
      });
    });
    super.initState();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Microphone permission not granted');
      }
    }
    await _soundRecorder.openAudioSession();
    _isRecorderInitialized = true;
  }

  @override
  void dispose() {
    //dispose soundPlayer
    _soundPlayer.closeAudioSession();
    _soundPlayer = null;

    //dispose soundRecorder
    _soundRecorder.closeAudioSession();
    _soundRecorder = null;
    super.dispose();
  }

  _onPressedRecord() {
    if (_isRecorderInitialized) {
      _soundRecorder
          .startRecorder(
        toFile: _filePath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
      )
          .then((value) {
        setState(() {});
      });
    }
  }

  _onPressedStop() async {
    await _soundRecorder.stopRecorder().then((value) {
      log('On pressed stop: $value');
      setState(() {
        _isRecordReadyToPlay = true;
        _filePath = value;
      });
    });
  }

  _onPressedPlay() {
    assert(_isRecordReadyToPlay &&
        _isSoundPlayerInitialized &&
        _soundRecorder.isStopped &&
        _soundPlayer.isStopped);
    File file = File('$_filePath');
    var size = file.lengthSync();
    log('File length: $size');
    _soundPlayer
        .startPlayer(
            fromURI: _filePath,
            codec: Codec.pcm16WAV,
            sampleRate: 16000,
            numChannels: 1,
            whenFinished: () {
              log('Player finished');
              setState(() {});
            })
        .then((value) {
      log('Method start player finished');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.0,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.mic),
            onPressed: _onPressedRecord,
          ),
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: _onPressedStop,
          ),
          IconButton(
            icon: Icon(Icons.play_arrow_rounded),
            onPressed: _onPressedPlay,
          ),
        ],
      ),
    );
  }
}
