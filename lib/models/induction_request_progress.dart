// lib/models/induction_request_progress.dart

class InductionRequestProgress {
  final int idrequest;
  final int statusId;
  final String plant;
  final String department;
  final String arrivalDate;
  final String visitDuration;
  final String status;

  InductionRequestProgress({
    required this.idrequest,
    required this.statusId,
    required this.plant,
    required this.department,
    required this.arrivalDate,
    required this.visitDuration,
    required this.status,
  });

  factory InductionRequestProgress.fromJson(Map<String, dynamic> json) {
    return InductionRequestProgress(
      idrequest: json['idrequest'] ?? 0,
      statusId: json['status_id'] ?? 0,
      plant: json['plant'] ?? '',
      department: json['department'] ?? '',
      arrivalDate: json['arrival_date'] ?? '',
      visitDuration: json['visit_duration'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
