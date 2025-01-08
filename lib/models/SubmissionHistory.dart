class SubmissionHistory {
  final int id;
  final String plant;
  final String department;
  final String arrivalDate; // Format tanggal
  final String visitDuration; // Durasi kunjungan
  final String status;

  SubmissionHistory({
    required this.id,
    required this.plant,
    required this.department,
    required this.arrivalDate,
    required this.visitDuration,
    required this.status,
  });

  // Factory constructor untuk membuat instance dari JSON
  factory SubmissionHistory.fromJson(Map<String, dynamic> json) {
    return SubmissionHistory(
      id: json['id'],
      plant: json['plant'],
      department: json['department'],
      arrivalDate:
          json['arrival_date'], // Pastikan ini sesuai dengan format JSON
      visitDuration:
          json['visit_duration'], // Pastikan ini sesuai dengan format JSON
      status: json['status'], // Pastikan ini sesuai dengan format JSON
    );
  }

  // Method untuk mengkonversi instance menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plant': plant,
      'department': department,
      'arrival_date': arrivalDate,
      'visit_duration': visitDuration,
      'status': status,
    };
  }
}
