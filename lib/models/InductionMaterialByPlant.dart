class InductionMaterialByPlant {
  final int idMateri;
  final int materialid;
  final int plantid;
  final String namaMateri;
  final String urlMateri;
  final String linkData;

  InductionMaterialByPlant({
    required this.idMateri,
    required this.materialid,
    required this.plantid,
    required this.namaMateri,
    required this.urlMateri,
    required this.linkData,
  });

  // Factory constructor untuk membuat instance dari JSON
  factory InductionMaterialByPlant.fromJson(Map<String, dynamic> json) {
    return InductionMaterialByPlant(
      idMateri: json['id'],
      materialid: json['material_id'],
      plantid: json['plant_id'],
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
