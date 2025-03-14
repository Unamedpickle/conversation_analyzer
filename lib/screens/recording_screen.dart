import 'dart:io';
import 'package:conversation_analyzer/services/audio_recording_service.dart';
import 'package:flutter/material.dart';
import '../services/audio_recording_service.dart'; // Ensure this file contains your AudioRecorder class

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({Key? key}) : super(key: key);

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final AudioRecordingService _audioRecorder = AudioRecordingService();
  bool _isRecording = false;
  String _statusMessage = "Tap 'Start Recording' to begin";
  String? _recordedFilePath;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      await _audioRecorder.startRecording();
      setState(() {
        _isRecording = true;
        _statusMessage = "Recording...";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error starting recording: $e";
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      String? filePath = await _audioRecorder.stopRecording();
      setState(() {
        _isRecording = false;
        _statusMessage = "Recording stopped";
        _recordedFilePath = filePath;
      });
      if (filePath != null) {
        // Prompt user to rename the recording
        String? newPath = await _showRenameDialog(filePath);
        if (newPath != null) {
          setState(() {
            _recordedFilePath = newPath;
            _statusMessage = "Recording saved as ${newPath.split('/').last}";
          });
        }
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error stopping recording: $e";
      });
    }
  }

  Future<String?> _showRenameDialog(String originalFilePath) async {
    final TextEditingController controller = TextEditingController(
      text: "audio_record",
    );
    String? renamedPath;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Rename Recording"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Enter a new file name (without extension):"),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: "File Name",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cancel renaming
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  String newName = controller.text.trim();
                  if (newName.isEmpty) {
                    // Do nothing if empty, or you can show an error.
                    return;
                  }
                  File oldFile = File(originalFilePath);
                  // Create new file path in the same directory with .aac extension.
                  String newPath = "${oldFile.parent.path}/$newName.aac";
                  // Check for duplicates
                  if (await File(newPath).exists()) {
                    bool? override = await _showOverrideDialog();
                    if (override != true) {
                      return; // Exit without renaming if user declines.
                    }
                  }
                  // Rename the file
                  try {
                    await oldFile.rename(newPath);
                    renamedPath = newPath;
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Rename failed: $e")),
                    );
                  }
                  Navigator.of(context).pop();
                },
                child: const Text("Save"),
              ),
            ],
          );
        });
      },
    );
    return renamedPath;
  }

  Future<bool?> _showOverrideDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("File Exists"),
          content: const Text(
              "A file with this name already exists. Do you want to override it?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recording Screen"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _statusMessage,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _isRecording
                  ? ElevatedButton(
                      onPressed: _stopRecording,
                      child: const Text("Stop Recording"),
                    )
                  : ElevatedButton(
                      onPressed: _startRecording,
                      child: const Text("Start Recording"),
                    ),
              if (_recordedFilePath != null) ...[
                const SizedBox(height: 20),
                Text(
                  "File saved at:\n$_recordedFilePath",
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
