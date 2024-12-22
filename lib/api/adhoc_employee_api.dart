import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/adhoc_employee.dart';
import '../confing/ipadders.dart';

class AdHocEmployeeApi {
  static final String baseUrl = "${ApiConfig.baseUrl}/api/labour/adhoc-employee";

  // Fetch list of AdHocEmployees
  static Future<List<AdHocEmployee>> getAdHocEmployees(int projectId) async {
    final response = await http.get(Uri.parse('$baseUrl/?project=$projectId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => AdHocEmployee.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load AdHocEmployees');
    }
  }

  // Create a new AdHocEmployee
  static Future<AdHocEmployee> createAdHocEmployee(Map<String, dynamic> employeeData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(employeeData),
    );

    if (response.statusCode == 201) {
      return AdHocEmployee.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create AdHocEmployee');
    }
  }
}

