import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/labor.dart';
import '../models/labor_skill.dart';
import '../confing/ipadders.dart'; // Base URL configuration
import '../confing/header.dart'; // Header configuration

class LaborApi {
  static const String baseUrl = ApiConfig.baseUrl; // Base URL usage

  static Future<List<Labor>> getLaborList({String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/labour/'),
        headers: ApiHeaders.getHeaders(token: token),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as List;
        return jsonResponse.map((item) => Labor.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch labors: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching labors: $e');
    }
  }

  static Future<Labor> createLabor(Labor labor, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/labour/create/'),
        headers: ApiHeaders.getHeaders(token: token),
        body: json.encode(labor.toJson()),
      );
      if (response.statusCode == 201) {
        return Labor.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create labor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating labor: $e');
    }
  }

  static Future<Labor> updateLabor(Labor labor, {String? token}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/labour/${labor.id}/update/'),
        headers: ApiHeaders.getHeaders(token: token),
        body: json.encode(labor.toJson()),
      );
      if (response.statusCode == 200) {
        return Labor.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update labor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating labor: $e');
    }
  }

  static Future<void> deleteLabor(int id, {String? token}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/labour/$id/delete/'),
        headers: ApiHeaders.getHeaders(token: token),
      );
      if (response.statusCode != 204) {
        throw Exception('Failed to delete labor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting labor: $e');
    }
  }

  static Future<List<LaborSkill>> getSkills({String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/master/skill/'),
        headers: ApiHeaders.getHeaders(token: token),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> skillsData = jsonResponse['data'] as List<dynamic>;
        return skillsData.map((item) => LaborSkill.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch skills: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching skills: $e');
    }
  }
}
