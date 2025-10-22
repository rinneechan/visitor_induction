class InductionMaterialBy {
  final int idMateri;
  final String namaMateri;
  final String urlMateri;
  final String linkData;

  InductionMaterialBy({
    required this.idMateri,
    required this.namaMateri,
    required this.urlMateri,
    required this.linkData,
  });

  // Factory constructor untuk membuat instance dari JSON
  factory InductionMaterialBy.fromJson(Map<String, dynamic> json) {
    return InductionMaterialBy(
      idMateri: json['id'],
      namaMateri: json['material_name'],
      urlMateri: json['material_attachment'],
      linkData: json['linkData'],
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
