import 'dart:convert';
import 'package:http/http.dart' as http;
import '../confing/header.dart';
import '../confing/ipadders.dart';
class ApiService {
  static const String _workDayEndpoint = 'api/project/work-day';

  /// Create a new workday entry
  static Future<Map<String, dynamic>> createWorkDay(
      List<Map<String, dynamic>> workDayData, int projectId,
      {String? token}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_workDayEndpoint/create/'); // Construct the full URL

    try {
      final response = await http.post(
        url,
        headers: ApiHeaders.getHeaders(token: token), // Fetch headers dynamically
        body: jsonEncode({'data': workDayData, 'project_id': projectId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Parse and return JSON response
      } else {
        throw Exception(
            'Failed to create workday: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error occurred while creating workday: $e');
    }
  }
}
