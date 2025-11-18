class InductionRequestIdExternal {
  final int id;
  final int visitorId;
  final int statusId;
  final int plantId;
  final String departmentName;
  final String picName;
  final String arrivalDate;
  final int durationId;
  final String reasonToVisit;
  final String fullName;
  final String plantName;
  final String passType;
  final String statusName;
  final String validUntil;
  final String qrCode;

  InductionRequestIdExternal({
    required this.id,
    required this.visitorId,
    required this.statusId,
    required this.plantId,
    required this.departmentName,
    required this.picName,
    required this.arrivalDate,
    required this.durationId,
    required this.reasonToVisit,
    required this.fullName,
    required this.plantName,
    required this.passType,
    required this.statusName,
    required this.validUntil,
    required this.qrCode,
  });

  factory InductionRequestIdExternal.fromJson(Map<String, dynamic> json) {
    return InductionRequestIdExternal(
      id: json['id'],
      visitorId: json['visitor_id'],
      statusId: json['status_id'],
      plantId: json['plant_id'],
      departmentName: json['department_name'] ?? '-',
      picName: json['pic_name'] ?? '-',
      arrivalDate: json['arrival_date'] ?? '-',
      durationId: json['duration_id'] ?? 0,
      reasonToVisit: json['reason_to_visit'] ?? '-',
      fullName: json['full_name'] ?? '-',
      plantName: json['plant_name'] ?? '-',
      passType: json['pass_type'] ?? '-',
      statusName: json['status_name'] ?? '-',
      validUntil: json['validuntil'] ?? '-',
      qrCode: json['qr_code'] ?? '',
    );
  }
}
