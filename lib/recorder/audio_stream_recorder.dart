import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_trial/generated/stt-service.pbgrpc.dart';
import 'package:flutter_sound_trial/grpc/client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioStreamRecorder extends StatefulWidget {
  @override
  _AudioStreamRecorderState createState() => _AudioStreamRecorderState();
}

class _AudioStreamRecorderState extends State<AudioStreamRecorder> {
  FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  StreamSubscription _recordingDataSubscription;
  bool _isRecorderInitialized = false;
  String _filePath = 'flutter_sound_example.pcm';
  // gRPC variables
  Client _client;
  bool _isGrpcClientInitialized = true;
  StreamController<StreamingRecognitionRequest> _streamController;

  @override
  void initState() {
    openTheRecorder().then((value) {
      setState(() {
        _isRecorderInitialized = true;
      });
    });
    _client = Client();
    _isGrpcClientInitialized = true;
    super.initState();
  }

  @override
  void dispose() {
    _soundRecorder.closeAudioSession();
    _isRecorderInitialized = false;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException(
          'Microphone permission is not granted');
    }
    await _soundRecorder.openAudioSession();
    _isRecorderInitialized = true;
  }

  Future<IOSink> createFile() async {
    var appDir = await getApplicationDocumentsDirectory();
    _filePath = '${appDir.path}/flutter_sound_sample.pcm';
    log(_filePath);
    final fileToWrite = File(_filePath);
    if (fileToWrite.existsSync()) {
      await fileToWrite.delete();
    }
    return fileToWrite.openWrite();
  }

  Stream<StreamingRecognitionRequest> streamingRecognitionRequestsStream(
      StreamController<Food> recordingDataController, IOSink sink) {
    _recordingDataSubscription =
        recordingDataController.stream.listen((buffer) {
      if (buffer is FoodData) {
        sink.add(buffer.data);
        log('sending data');
        _streamController.add(StreamingRecognitionRequest(
            audioContent: buffer.data, getResult: false));
      }
    });
    // _streamController = StreamController(
    //   onCancel: stopController,
    // );
    _streamController = StreamController();
    return _streamController.stream;
  }

  void stopController() {
    log('Stopping controller');
    _streamController.add(StreamingRecognitionRequest(
        audioContent: List.empty(), getResult: true));
    _streamController.close();
  }

  Future<void> stopDataSubscription() async {
    if (_recordingDataSubscription != null) {
      await _recordingDataSubscription.cancel();
      _recordingDataSubscription = null;
      log('Recording data subscription stopped');
    }
  }

  Future<void> record() async {
    log('Starting record');
    assert(_isRecorderInitialized &&
        _soundRecorder.isStopped &&
        _isGrpcClientInitialized);
    final sink = await createFile();
    final recordingDataController = StreamController<Food>();
    _client.startStreaming(
        streamingRecognitionRequestsStream(recordingDataController, sink));
    await _soundRecorder.startRecorder(
      toStream: recordingDataController.sink,
      codec: Codec.pcm16,
      sampleRate: 16000,
      numChannels: 1,
    );
    setState(() {});
  }

  Future<void> stopRecorder() async {
    await _soundRecorder.stopRecorder();
    log('Recorder stopped');
    stopController();
    stopDataSubscription();
    setState(() {});
    _client.resultsStream().listen((value) {
      log('result: ${value.alternatives.text}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record to Stream'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: record,
                  //color: Colors.white,
                  //disabledColor: Colors.grey,
                  child: Text('Record'),
                ),
                SizedBox(
                  width: 20,
                ),
                Text(_soundRecorder.isRecording
                    ? 'Recording in progress'
                    : 'Recorder is stopped'),
                SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: stopRecorder,
                  //color: Colors.white,
                  //disabledColor: Colors.grey,
                  child: Text('Stop'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
