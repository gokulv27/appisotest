import 'dart:convert';

class Project {
  final int id;
  final int clientId;
  final String clientName;
  final String projectName;
  final String location;
  final double budget;
  final String landFacing;
  final double landWidth;
  final double landBreadth;
  final int numFloors;
  final double buildArea;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool activeStatus;

  Project({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.projectName,
    required this.location,
    required this.budget,
    required this.landFacing,
    required this.landWidth,
    required this.landBreadth,
    required this.numFloors,
    required this.buildArea,
    required this.createdAt,
    required this.updatedAt,
    required this.activeStatus,
  });

  /// Factory method to parse JSON data
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? 0, // Fallback to 0 if null
      clientId: json['client'] ?? 0,
      clientName: json['client_name'] ?? 'Unknown',
      projectName: json['project_name'] ?? 'Unknown',
      location: json['location'] ?? 'Unknown',
      budget: _parseDouble(json['budget']),
      landFacing: json['land_facing'] ?? 'Unknown',
      landWidth: _parseDouble(json['land_width']),
      landBreadth: _parseDouble(json['land_breadth']),
      numFloors: json['num_floors'] ?? 0,
      buildArea: _parseDouble(json['build_area']),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      activeStatus: _parseBool(json['active_status']),
    );
  }

  /// Method to convert the object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client': clientId,
      'client_name': clientName,
      'project_name': projectName,
      'location': location,
      'budget': budget.toStringAsFixed(2),
      'land_facing': landFacing,
      'land_width': landWidth.toStringAsFixed(2),
      'land_breadth': landBreadth.toStringAsFixed(2),
      'num_floors': numFloors,
      'build_area': buildArea.toStringAsFixed(2),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'active_status': activeStatus,
    };
  }

  /// Helper to safely parse double values
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0; // Fallback for unsupported types
  }

  /// Helper to safely parse boolean values
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}

/// Function to parse a list of Projects from JSON
List<Project> parseProjects(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Project>((json) => Project.fromJson(json)).toList();
}
