import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/audio_transmission_service.dart';

class SavedRecordingsScreen extends StatefulWidget {
  const SavedRecordingsScreen({Key? key}) : super(key: key);

  @override
  SavedRecordingsScreenState createState() => SavedRecordingsScreenState();
}

class SavedRecordingsScreenState extends State<SavedRecordingsScreen> {
  List<FileSystemEntity> _audioFiles = [];
  AudioTransmissionService audioTransmissionService =
      AudioTransmissionService();
  @override
  void initState() {
    super.initState();
    _loadAudioFiles();
  }

  Future<void> _loadAudioFiles() async {
    // Get the application documents directory.
    Directory appDocDir = await getApplicationDocumentsDirectory();

    // List all files in the directory.
    List<FileSystemEntity> files = appDocDir.listSync();

    // Filter for audio files with the .wav extension.
    List<FileSystemEntity> audioFiles = files.where((file) {
      return file.path.endsWith('.wav');
    }).toList();

    setState(() {
      _audioFiles = audioFiles;
    });
  }

  // Public method to allow external refresh calls.
  Future<void> refreshRecordings() async {
    await _loadAudioFiles();
  }

  // Stub function for preview. Replace with actual implementation.
  void _previewRecording(FileSystemEntity file) {
    // Example: Navigate to a playback screen or use an audio player package.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Previewing ${file.path.split('/').last}')),
    );
  }

  // Stub function for upload. Replace with actual implementation.
  void _uploadRecording(FileSystemEntity file) {
    // Example: Call an API to upload the file.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Uploading ${file.path.split('/').last}')),
    );
    audioTransmissionService.sendAudioFile(file.path);
  }

  Future<void> _deleteRecording(FileSystemEntity file) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Recording"),
          content: Text(
              "Are you sure you want to delete ${file.path.split('/').last}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      try {
        await file.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${file.path.split('/').last} deleted')),
        );
        _loadAudioFiles();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recordings"),
      ),
      body: _audioFiles.isEmpty
          ? const Center(child: Text("No recordings found"))
          : ListView.builder(
              itemCount: _audioFiles.length,
              itemBuilder: (context, index) {
                String fileName = _audioFiles[index].path.split('/').last;
                return ListTile(
                  title: Text(fileName),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'preview':
                          _previewRecording(_audioFiles[index]);
                          break;
                        case 'upload':
                          _uploadRecording(_audioFiles[index]);
                          break;
                        case 'delete':
                          _deleteRecording(_audioFiles[index]);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'preview',
                        child: Text('Preview'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'upload',
                        child: Text('Upload'),
                        // For the upload option we need to have {header: Content-Type, value: Application/json, body: audio_data: "Raw Bytes"}
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                  // Optional: tap on list tile could also trigger a preview.
                  onTap: () => _previewRecording(_audioFiles[index]),
                );
              },
            ),
    );
  }
}
