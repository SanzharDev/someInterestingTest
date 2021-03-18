import 'dart:developer';

import 'package:flutter_sound_trial/generated/stt-service.pbgrpc.dart';
import 'package:grpc/grpc.dart';

class Client {
  sttServiceClient stub;
  ClientChannel channel;
  bool _isStubInitialized = false;

  void _init() {
    try {
      channel = ClientChannel('185.97.114.171',
          port: 8055,
          options:
              const ChannelOptions(credentials: ChannelCredentials.insecure()));
      stub = sttServiceClient(channel,
          options: CallOptions(timeout: Duration(seconds: 15)));
      _isStubInitialized = true;
      log('gRPC Stub initialized');
    } catch (e) {
      log('Can\'t establish gRPC connection. Exception: $e');
    }
  }

  Future<void> sendOngoingRequestChunk(final audioData) async {
    try {
      if (!_isStubInitialized) {
        _init();
      }
      _sendRequest(audioData, false);
    } catch (e) {
      log('Something went wrong during request chunk streaming');
    }
  }

  Future<SpeechRecognitionResponseChunk> sendFinalRequestChunk() async {
    var result = SpeechRecognitionResponseChunk();
    try {
      result = await _sendRequest(List.empty(), true);
    } catch (e) {
      log('Something went wrong when last request chunk were sent');
      log('Result is assigned to a default SpeechRecognitionResponseChunk');
    } finally {
      await channel.shutdown();
      log('Channel closed');
    }
    return result;
  }

  Future<SpeechRecognitionResponseChunk> _sendRequest(
      final audioData, final isLastChunk) async {
    var requestChunk = StreamingRecognitionRequest(
        audioContent: audioData, getResult: isLastChunk);
    Stream<StreamingRecognitionRequest> outgoingRequestStream() async* {
      yield requestChunk;
    }

    log('Request chunk collected');
    Stream<SpeechRecognitionResponseChunk> response =
        stub.streamRecognize(outgoingRequestStream());
    isLastChunk
        ? log('Request send to STT Server')
        : log('Final request chunk sent');
    SpeechRecognitionResponseChunk result = SpeechRecognitionResponseChunk();
    if (isLastChunk) {
      await for (var r in response) {
        result = r;
      }
    }
    return Future.value(result);
  }
}
