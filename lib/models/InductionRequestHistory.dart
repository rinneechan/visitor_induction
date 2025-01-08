class InductionRequestHistory {
  final int id; // Field baru
  final int visitorId;
  final int statusId;
  final int plantId;
  final String departmentName;
  final String picName;
  final String arrivalDate;
  final int durationId;
  final String reasonToVisit;
  final String createdAt;
  final String updatedAt;
  final String createdBy;
  final String updatedBy;
  final String uuid;
  final String fullName; // Field baru
  final String plantName; // Field baru
  final String passType; // Field baru
  final String statusName; // Field baru

  InductionRequestHistory({
    required this.id, // Field baru
    required this.visitorId,
    required this.statusId,
    required this.plantId,
    required this.departmentName,
    required this.picName,
    required this.arrivalDate,
    required this.durationId,
    required this.reasonToVisit,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.uuid,
    required this.fullName, // Field baru
    required this.plantName, // Field baru
    required this.passType, // Field baru
    required this.statusName, // Field baru
  });

  factory InductionRequestHistory.fromJson(Map<String, dynamic> json) {
    return InductionRequestHistory(
      id: json['id'], // Field baru
      visitorId: json['visitor_id'],
      statusId: json['status_id'],
      plantId: json['plant_id'],
      departmentName: json['department_name'],
      picName: json['pic_name'],
      arrivalDate: json['arrival_date'],
      durationId: json['duration_id'],
      reasonToVisit: json['reason_to_visit'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      uuid: json['uuid'],
      fullName: json['full_name'], // Field baru
      plantName: json['plant_name'], // Field baru
      passType: json['pass_type'], // Field baru
      statusName: json['status_name'], // Field baru
    );
  }

  // Getter tambahan untuk properti yang dibutuhkan di widget
  String get idrequest => id.toString();
  String get plant => plantName; // Menggunakan plantName dari API
  String get department => departmentName;
  String get visitDuration => passType; //'$durationId days'; // Contoh format
  String get statusid => statusId.toString(); // Menggunakan statusId dari API
  String get status => statusName; // Menggunakan statusName dari API
}

// class InductionRequestHistory {
//   final int visitorId;
//   final int statusId;
//   final int plantId;
//   final String departmentName;
//   final String picName;
//   final String arrivalDate;
//   final int durationId;
//   final String reasonToVisit;
//   final String createdAt;
//   final String updatedAt;
//   final String createdBy;
//   final String updatedBy;
//   final String uuid;

//   InductionRequestHistory({
//     required this.visitorId,
//     required this.statusId,
//     required this.plantId,
//     required this.departmentName,
//     required this.picName,
//     required this.arrivalDate,
//     required this.durationId,
//     required this.reasonToVisit,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.createdBy,
//     required this.updatedBy,
//     required this.uuid,
//   });

//   factory InductionRequestHistory.fromJson(Map<String, dynamic> json) {
//     return InductionRequestHistory(
//       visitorId: json['visitor_id'],
//       statusId: json['status_id'],
//       plantId: json['plant_id'],
//       departmentName: json['department_name'],
//       picName: json['pic_name'],
//       arrivalDate: json['arrival_date'],
//       durationId: json['duration_id'],
//       reasonToVisit: json['reason_to_visit'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       createdBy: json['created_by'],
//       updatedBy: json['updated_by'],
//       uuid: json['uuid'],
//     );
//   }

//   // Getter tambahan untuk properti yang dibutuhkan di widget
//   String get plant => 'Plant ID: $plantId'; // Contoh format
//   String get department => departmentName;
//   String get visitDuration => '$durationId days'; // Contoh format
//   String get status => _mapStatusToString(statusId);

//   // Helper untuk mengonversi status ID menjadi teks
//   String _mapStatusToString(int statusId) {
//     switch (statusId) {
//       case 0:
//         return 'Pending';
//       case 1:
//         return 'Approved';
//       case 2:
//         return 'Rejected';
//       default:
//         return 'Unknown';
//     }
//   }
// }
