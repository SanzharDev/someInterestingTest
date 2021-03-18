import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
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
  String _filePath = 'flutter_sound_example.wav';
  final int _sampleRate = 44000;
  // gRPC variables
  Client _client;
  bool _isGrpcClientInitialized = true;

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
    final fileToWrite = File(_filePath);
    if (fileToWrite.existsSync()) {
      await fileToWrite.delete();
    }
    return fileToWrite.openWrite();
  }

  Future<void> record() async {
    assert(_isRecorderInitialized &&
        _soundRecorder.isStopped &&
        _isGrpcClientInitialized);
    final sink = await createFile();
    final recordingDataController = StreamController<Food>();
    _recordingDataSubscription =
        recordingDataController.stream.listen((buffer) {
      if (buffer is FoodData) {
        sink.add(buffer.data);
      }
    });
    await _soundRecorder.startRecorder(
      toStream: recordingDataController.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: _sampleRate,
    );
    setState(() {});
  }

  Future<void> stopRecorder() async {
    await _soundRecorder.stopRecorder();
    if (_recordingDataSubscription != null) {
      await _recordingDataSubscription.cancel();
      _recordingDataSubscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
