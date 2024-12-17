import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/labor.dart';
import '../models/labor_skill.dart';
import '../models/project.dart';
import '../confing/ipadders.dart';

class LaborApi {
  static const String baseUrl = ApiConfig.baseUrl;

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',

  };

  static Future<List<Labor>> getLaborList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/labour/'), headers: headers);
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

  static Future<Labor> createLabor(Labor labor) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/labour/create/'),
        headers: headers,
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

  static Future<Labor> updateLabor(Labor labor) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/labour/${labor.id}/update/'),
        headers: headers,
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

  static Future<void> deleteLabor(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/labour/$id/delete/'),
        headers: headers,
      );
      if (response.statusCode != 204) {
        throw Exception('Failed to delete labor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting labor: $e');
    }
  }

  static Future<List<LaborSkill>> getSkills() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/master/skill/'), headers: headers);
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

class ProjectApi {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<List<Project>> getProjectList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/project/'));
      if (response.statusCode == 200) {
        final List<dynamic> projectsJson = json.decode(response.body) as List<dynamic>;
        return projectsJson.map((item) => Project.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load projects: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }

  static Future<Project> createProject(Project project) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/project/create/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(project.toJson()),
      );

      if (response.statusCode == 201) {
        return Project.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create project: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating project: $e');
    }
  }

  static Future<Project> updateProject(int id, Project project) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/project/$id/update/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(project.toJson()),
      );

      if (response.statusCode == 200) {
        return Project.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update project: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating project: $e');
    }
  }

  static Future<void> deleteProject(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/project/$id/delete/'));
      if (response.statusCode != 204) {
        throw Exception('Failed to delete project: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting project: $e');
    }
  }
}
