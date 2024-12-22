import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/work_day_model.dart';
import '../confing/header.dart';
import '../confing/ipadders.dart';

/// API Service
class ApiService {
  static const String _workDayEndpoint = '/api/labour/workday/create/';

  /// Create WorkDay API Method
  static Future<Map<String, dynamic>> createWorkDay(
      List<WorkDay> workDayList, {String? token}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_workDayEndpoint');

    // Convert list of WorkDay objects to JSON
    final workDayData = workDayList.map((workDay) => workDay.toJson()).toList();

    try {
      print('Final JSON payload: ${jsonEncode(workDayData)}');
      print(workDayData);
      _debugLog(
        url: url,
        headers: ApiHeaders.getHeaders(token: token),
        body: jsonEncode(workDayData),
      );

      final response = await http.post(
        url,
        headers: ApiHeaders.getHeaders(token: token),
        body: jsonEncode(workDayData),
      );

      _debugResponse(response);

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error in createWorkDay: $e');
      throw Exception('Error occurred while creating WorkDay: $e');
    }
  }

  /// Debugging Helper for Request Details
  static void _debugLog({required Uri url, required Map<String, String> headers, required String body}) {


    print('API Request:');
    print('URL: $url');
    print('Headers: $headers');
    print('Body: $body');
  }

  /// Debugging Helper for Response Details
  static void _debugResponse(http.Response response) {
    print('API Response:');
    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');
  }

  /// Handle Error Responses
  static Exception _handleErrorResponse(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      return Exception('Failed with status: ${response.statusCode}.\nDetails: $errorData');
    } catch (_) {
      return Exception('Failed with status: ${response.statusCode}. Response could not be parsed.');
    }
  }
}
