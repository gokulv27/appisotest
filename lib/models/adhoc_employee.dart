class AdHocEmployee {
  final int id;
  final int labor;
  final int project;
  final String skill;
  final String laborName;
  final String laborDailyWages;
  final String hiredDate;
  final bool isActive;

  AdHocEmployee({
    required this.id,
    required this.labor,
    required this.project,
    required this.skill,
    required this.laborName,
    required this.laborDailyWages,
    required this.hiredDate,
    required this.isActive,
  });

  factory AdHocEmployee.fromJson(Map<String, dynamic> json) {
    return AdHocEmployee(
      id: json['id'],
      labor: json['labor'],
      project: json['project'],
      skill: json['skill'],
      laborName: json['labor_name'],
      laborDailyWages: json['labor_daily_wages'],
      hiredDate: json['hired_date'],
      isActive: json['is_active'],
    );
  }
}
