import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/labor_to_project.dart';
import '../models/labor_skill.dart'; // Adjust the path accordingly
import '../confing/header.dart'; // ApiHeaders class
import '../confing/ipadders.dart'; // ApiConfig class for baseUrl

class LaborToProjectApi {
  static const String _laborToProjectEndpoint = '/api/project/labor-to-project';
  static const String _skillsEndpoint = '/api/master/api/skill/';

  /// Fetch labor-to-project assignments by project ID
  Future<List<LaborToProject>> getLaborForProject(int projectId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_laborToProjectEndpoint?project=$projectId');
    try {
      final response = await http.get(url, headers: ApiHeaders.getHeaders()).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => LaborToProject.fromJson(data)).toList();
      } else {
        throw Exception(
          'Failed to fetch labor for project: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching labor for project: $e');
    }
  }

  /// Fetch available labor skills
  Future<List<LaborSkill>> getSkills() async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_skillsEndpoint');
    try {
      final response = await http.get(url, headers: ApiHeaders.getHeaders()).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => LaborSkill.fromJson(data)).toList();
      } else {
        throw Exception(
          'Failed to fetch skills: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching skills: $e');
    }
  }

  /// Add a labor-to-project assignment
  Future<void> addLaborToProject(Map<String, dynamic> payload) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_laborToProjectEndpoint/create/');
    try {
      final response = await http.post(
        url,
        headers: ApiHeaders.getHeaders(),
        body: jsonEncode(payload),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add labor to project: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding labor to project: $e');
    }
  }

  /// Update a labor-to-project assignment
  Future<void> updateLaborToProject({
    required int id,
    required int laborId,
    required String startDate,
    String? endDate,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_laborToProjectEndpoint/$id/update/');
    try {
      final response = await http.put(
        url,
        headers: ApiHeaders.getHeaders(),
        body: jsonEncode({
          'labor': laborId,
          'start_date': startDate,
          'end_date': endDate,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update labor-to-project: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error updating labor-to-project: $e');
    }
  }

  /// Remove a labor-to-project assignment
  Future<void> removeLaborFromProject(int projectId, int laborId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_laborToProjectEndpoint/$laborId/delete/');
    try {
      final response = await http.delete(url, headers: ApiHeaders.getHeaders()).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 204) {
        throw Exception(
          'Failed to remove labor-to-project: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error removing labor-to-project: $e');
    }
  }
}
