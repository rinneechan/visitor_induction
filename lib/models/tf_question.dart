class TFQuestion {
  final String kode;
  final String status; // "Active" atau "Draft"
  final String statement;
  final String createdAt;
  bool isSelected;

  TFQuestion({
    required this.kode,
    required this.status,
    required this.statement,
    required this.createdAt,
    this.isSelected = false,
  });

  factory TFQuestion.fromJson(Map<String, dynamic> json) {
    return TFQuestion(
      kode: json['kode'] ?? '',
      status: json['status'] ?? 'Draft',
      statement: json['statement'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode': kode,
      'status': status,
      'statement': statement,
      'createdAt': createdAt,
    };
  }
}
