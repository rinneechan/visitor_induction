class InductionMaterial {
  final int idMateri;
  final String namaMateri;
  final String urlMateri;

  InductionMaterial({
    required this.idMateri,
    required this.namaMateri,
    required this.urlMateri,
  });

  // Factory constructor untuk membuat instance dari JSON
  factory InductionMaterial.fromJson(Map<String, dynamic> json) {
    return InductionMaterial(
      idMateri: json['id'],
      namaMateri: json['material_name'],
      urlMateri: json['material_attachment'],
    );
  }

  // Method untuk mengkonversi instance menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': idMateri,
      'material_name': namaMateri,
    };
  }
}
