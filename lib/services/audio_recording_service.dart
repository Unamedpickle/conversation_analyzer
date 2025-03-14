import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AudioRecordingService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  String? _filePath;

  Future<void> initRecorder() async {
    //
    if (!_isRecorderInitialized) {
      var permissionStatus = await Permission.microphone.request();
      if (permissionStatus.isGranted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
      // Get the directory to save the recording
      Directory directory = await getApplicationDocumentsDirectory();
      _filePath = '${directory.path}/audio_recording.aac';

      // Initialize the recorder
      await _recorder.openRecorder();
      _isRecorderInitialized = true;
    }
  }

  Future<void> startRecording() async {
    if (!_isRecorderInitialized) {
      await initRecorder();
    }
    await _recorder.startRecorder(toFile: _filePath);
    print("Recording Started");
  }

  Future<String?> stopRecording() async {
    if (!_isRecorderInitialized) return null;
    await _recorder.stopRecorder();
    print("Recording Stopped");
    return _filePath;
  }

  void dispose() {
    _recorder.closeRecorder();
    _isRecorderInitialized = false;
  }
}
