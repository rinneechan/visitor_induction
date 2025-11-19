class InductionRequestIdExternall {
  final String id;
  final String plantId;
  final String plantName;
  final String departmentName;
  final String picName;
  final String statusName;
  final String arrivalDate;
  final String passType;
  final String reasonToVisit;
  final String fullName;

  InductionRequestIdExternall({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.departmentName,
    required this.picName,
    required this.statusName,
    required this.arrivalDate,
    required this.passType,
    required this.reasonToVisit,
    required this.fullName,
  });

  factory InductionRequestIdExternall.fromJson(Map<String, dynamic> json) {
    return InductionRequestIdExternall(
      id: json["id"]?.toString() ?? "",
      plantId: json["plant_id"]?.toString() ?? "",
      plantName: json["plant_name"] ?? "",      // ← FIX TERPENTING
      departmentName: json["department_name"] ?? "",
      picName: json["pic_name"] ?? "",
      statusName: json["status_name"] ?? "",
      arrivalDate: json["arrival_date"] ?? "",
      passType: json["pass_type"] ?? "",
      reasonToVisit: json["reason_to_visit"] ?? "",
      fullName: json["full_name"] ?? "",
    );
  }
}
