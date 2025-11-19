class Profil {
  final String id;
  final String fullName;
  final String companyName;
  final String workEmail;
  final String nohp;
  final String jobPosition;
  final String userType;
  final String? nik;
  final String uuid;

  Profil({
    required this.id,
    required this.fullName,
    required this.companyName,
    required this.workEmail,
    required this.nohp,
    required this.jobPosition,
    required this.userType,
    this.nik,
    required this.uuid,
  });

  factory Profil.fromJson(Map<String, dynamic> json) {
    return Profil(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      companyName: json['company_name'] ?? '',
      workEmail: json['work_email'] ?? '',
      nohp: json['nohp'] ?? '',
      jobPosition: json['job_position'] ?? '',
      userType: json['user_type'] ?? '',
      nik: json['nik'],
      uuid: json['uuid'] ?? '',
    );
  }
}

class InductionRequestData {
  final String id;
  final String visitorId;
  final String plantId;
  final String plantName;
  final String departmentName;
  final String picName;
  final String statusName;
  final String arrivalDate;
  final String passType;
  final String reasonToVisit;
  final String fullName;
  final String validUntil;
  final String qrCode;

  InductionRequestData({
    required this.id,
    required this.visitorId,
    required this.plantId,
    required this.plantName,
    required this.departmentName,
    required this.picName,
    required this.statusName,
    required this.arrivalDate,
    required this.passType,
    required this.reasonToVisit,
    required this.fullName,
    required this.validUntil,
    required this.qrCode,
  });

  factory InductionRequestData.fromJson(Map<String, dynamic> json) {
    return InductionRequestData(
      id: json['id']?.toString() ?? '',
      visitorId: json['visitor_id']?.toString() ?? '',
      plantId: json['plant_id']?.toString() ?? '',
      plantName: json['plant_name'] ?? '',
      departmentName: json['department_name'] ?? '',
      picName: json['pic_name'] ?? '',
      statusName: json['status_name'] ?? '',
      arrivalDate: json['arrival_date'] ?? '',
      passType: json['pass_type'] ?? '',
      reasonToVisit: json['reason_to_visit'] ?? '',
      fullName: json['full_name'] ?? '',
      validUntil: json['validuntil'] ?? '',
      qrCode: json['qr_code'] ?? '',
    );
  }
}

class InductionRequestIdExternal {
  final bool status;
  final String message;
  final List<InductionRequestData> data;
  final Profil? profil;

  InductionRequestIdExternal({
    required this.status,
    required this.message,
    required this.data,
    this.profil,
  });

  factory InductionRequestIdExternal.fromJson(Map<String, dynamic> json) {
    return InductionRequestIdExternal(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<InductionRequestData>.from(
              (json['data'] as List).map((x) => InductionRequestData.fromJson(x)))
          : [],
      profil: json['profil'] != null ? Profil.fromJson(json['profil']) : null,
    );
  }
}