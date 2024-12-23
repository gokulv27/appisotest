class LaborToProject {
  final int id;
  final int labor;
  final String laborName;
  final String skill;
  final String startDate;
  final String? endDate; // Nullable field for optional end date
  final int project;
  final bool isDeleted; // For soft deletion
  final String? workType; // Optional field for work type
  final String dailyWages; // Corrected naming convention

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
    required this.dailyWages,
  });

  /// Factory constructor for JSON deserialization
  factory LaborToProject.fromJson(Map<String, dynamic> json) {
    return LaborToProject(
      id: json['id'] as int,
      labor: json['labor'] as int,
      laborName: json['labor_name'] ?? 'Unknown',
      skill: json['skill'] ?? 'Unknown',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'], // Nullable field
      project: json['project'] as int,
      isDeleted: json['isDeleted'] ?? false,
      workType: json['workType'],
      dailyWages: json['labor_daily_wages'] ?? '',
    );
  }

  /// Method for JSON serialization
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
      'labor_daily_wages': dailyWages,
    };
  }

  /// Copy method to create new instances with modified fields
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
    String? dailyWages,
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
      dailyWages: dailyWages ?? this.dailyWages,
    );
  }
}
