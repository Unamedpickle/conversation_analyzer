import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../config/routes.dart';

class AudioTransmissionService {
  Future<String> sendAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final data = base64Encode(bytes);
      final response = await http.post(
        Uri.parse(ApiRoutes.upload_audio),
        body: jsonEncode({
          'audio_data': data,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return 'Success';
      } else {
        throw Exception('Failed to upload audio file');
      }
    } catch (e) {
      throw Exception('Failed to upload audio file: $e');
    }
  }
}
