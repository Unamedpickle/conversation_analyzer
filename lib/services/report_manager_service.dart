import 'package:http/http.dart';
import '../config/routes.dart';

class ReportManagerService {
  final String baseUrl = ApiRoutes.get_audio_report;
  Future<String> getReport(String reportId) async {
    try {
      final response = await get(Uri.parse('$baseUrl/$reportId'));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load report');
      }
    } catch (e) {
      throw Exception('Failed to load report: $e');
    }
  }
}
