class WorkDay {
  final int laborToProjectId;
  final String date;
  final String workType;

  WorkDay({
    required this.laborToProjectId,
    required this.date,
    required this.workType,
  });

  // Convert a `WorkDay` object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'labor_to_project': laborToProjectId,
      'date': date,
      'work_type': workType,
    };
  }

  // Create a `WorkDay` object from a JSON map
  factory WorkDay.fromJson(Map<String, dynamic> json) {
    return WorkDay(
      laborToProjectId: json['labor_to_project'],
      date: json['date'],
      workType: json['work_type'],
    );
  }
}
