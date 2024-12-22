class WorkDay {
  final int? id;
  final int? laborToProject;
  final int? adhocEmployee;
  final String date;
  final String workType;

  /// Constructor with named parameters
  /// Includes null safety and required annotations where applicable
  WorkDay({
    this.id,
    required this.laborToProject,
    this.adhocEmployee,
    required this.date,
    required this.workType,
  });

  /// Converts a `WorkDay` object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'labor_to_project': laborToProject,
      'adhoc_employee': adhocEmployee,
      'date': date,
      'work_type': workType,
    };
  }

  /// Factory method to create a `WorkDay` object from JSON
  factory WorkDay.fromJson(Map<String, dynamic> json) {
    return WorkDay(
      id: json['id'] as int?,
      laborToProject: json['labor_to_project'] as int?,
      adhocEmployee: json['adhoc_employee'] as int?,
      date: json['date'] as String,
      workType: json['work_type'] as String,
    );
  }
}
