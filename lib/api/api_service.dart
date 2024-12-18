import 'dart:convert';
import 'package:http/http.dart' as http;
import '../confing/header.dart';
import '../confing/ipadders.dart';


// ApiService: Service class for API calls
class ApiService {
  final String baseUrl = '${ApiConfig.baseUrl}api/account';

  // Login API
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login/');
    try {
      final response = await http.post(
        url,
        headers: ApiHeaders.getHeaders(),
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Returns the response as a Map
      } else {
        throw Exception('Login failed. Please check your credentials.');
      }
    } catch (error) {
      print(error);
      throw Exception('An error occurred: $error');
    }
  }

  // Reset Password API
  Future<Map<String, dynamic>> resetPassword({
    required String password,
    String? token,
    required Map<String, dynamic> payload,
  }) async {
    final url = Uri.parse('$baseUrl/reset-password/');
    try {
      final response = await http.post(
        url,
        headers: ApiHeaders.getHeaders(token: token),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Password reset failed. Try again.');
      }
    } catch (error) {
      throw Exception('An error occurred: $error');
    }
  }

}