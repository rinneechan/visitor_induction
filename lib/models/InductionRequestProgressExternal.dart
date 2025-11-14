class InductionRequestProgressExternal {
  final int id;                   // id request
  final int visitorId;
  final String plant;             // plant_name
  final String department;        // department_name
  final String picName;           // pic_name
  final String arrivalDate;       // arrival_date
  final String passType;          // pass_type
  final String reason;            // reason_to_visit
  final String status;            // status_name
  final String createdAt;

  InductionRequestProgressExternal({
    required this.id,
    required this.visitorId,
    required this.plant,
    required this.department,
    required this.picName,
    required this.arrivalDate,
    required this.passType,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory InductionRequestProgressExternal.fromJson(Map<String, dynamic> json) {
    return InductionRequestProgressExternal(
      id: json['id'] ?? 0,
      visitorId: json['visitor_id'] ?? 0,
      plant: json['plant_name'] ?? '',
      department: json['department_name'] ?? '',
      picName: json['pic_name'] ?? '',
      arrivalDate: json['arrival_date'] ?? '',
      passType: json['pass_type'] ?? '',
      reason: json['reason_to_visit'] ?? '',
      status: json['status_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  // kombinasi date + duration
  String get dateRange => "$arrivalDate - $passType";
}
