class LaborToProject {
  final int id;
  final int labor;
  final String laborName;
  final String skill;
  final String startDate;
  final String? endDate; // Nullable field
  final int project;
  final bool isDeleted; // Added for soft deletion
  final String? workType; // Added for selected work type

  LaborToProject({
    required this.id,
    required this.labor,
    required this.laborName,
    required this.skill,
    required this.startDate,
    this.endDate,
    required this.project,
    this.isDeleted = false,
    this.workType,
  });

  // Factory method for JSON deserialization
  factory LaborToProject.fromJson(Map<String, dynamic> json) {
    return LaborToProject(
      id: json['id'] as int,
      labor: json['labor'] as int,
      laborName: json['labor_name'] ?? 'Unknown',
      skill: json['skill'] ?? 'Unknown',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'], // This is nullable
      project: json['project'] as int,
    );
  }

  // Method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'labor': labor,
      'labor_name': laborName,
      'skill': skill,
      'start_date': startDate,
      'end_date': endDate,
      'project': project,
      'isDeleted': isDeleted,
      'workType': workType,
    };
  }

  // Copy method to create new instances with modified fields
  LaborToProject copyWith({
    int? id,
    int? labor,
    String? laborName,
    String? skill,
    String? startDate,
    String? endDate,
    int? project,
    bool? isDeleted,
    String? workType,
  }) {
    return LaborToProject(
      id: id ?? this.id,
      labor: labor ?? this.labor,
      laborName: laborName ?? this.laborName,
      skill: skill ?? this.skill,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      project: project ?? this.project,
      isDeleted: isDeleted ?? this.isDeleted,
      workType: workType ?? this.workType,
    );
  }
}
