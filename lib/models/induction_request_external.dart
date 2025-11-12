class InductionRequestExternal {
  final String visitorId;
  final String statusId;
  final String plantId;
  final String departmentName;
  final String picName;
  final String arrivalDate;
  final int durationId;
  final String reasonToVisit;
  final String createdBy;
  final String updatedBy;

  InductionRequestExternal({
    required this.visitorId,
    required this.statusId,
    required this.plantId,
    required this.departmentName,
    required this.picName,
    required this.arrivalDate,
    required this.durationId,
    required this.reasonToVisit,
    required this.createdBy,
    required this.updatedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      "visitor_id": "26",
  "status_id": "0",
  "plant_id": "10",
  "department_name": "Batam Plant",
  "pic_name": "Test",
  "arrival_date": "2025-05-24T00:00:00.000",
  "duration_id": "1",
  "reason_to_visit": "Test Visitor Induction",
  "created_by": "01122070002",
  "updated_by": "01122070002",

  "full_name": "Amare Putri Adinda",
  "company_name": "PT Contoh",
  "work_email": "amare@example.com",
  "job_position": "Multimedia Designer"
    };
  }
}
