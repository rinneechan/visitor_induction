class MCQuestion {
  final String kode;
  final String statement;
  final String status;
  final String createdAt;
  bool isSelected;

  MCQuestion({
    required this.kode,
    required this.statement,
    required this.status,
    required this.createdAt,
    this.isSelected = false,
  });

  factory MCQuestion.fromJson(Map<String, dynamic> json) {
    return MCQuestion(
      kode: json['kode'] ?? '',
      statement: json['statement'] ?? '',
      status: json['status'] ?? 'Draft',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "kode": kode,
      "statement": statement,
      "status": status,
      "createdAt": createdAt,
    };
  }
}
