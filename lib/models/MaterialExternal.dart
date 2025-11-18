// lib/models/material_external.dart
class MaterialExternal {
  final int id;
  final int materialId;
  final int plantId;
  final String updatedAt;
  final String materialName;
  final String materialAttachment;
  final String linkData;

  MaterialExternal({
    required this.id,
    required this.materialId,
    required this.plantId,
    required this.updatedAt,
    required this.materialName,
    required this.materialAttachment,
    required this.linkData,
  });

  factory MaterialExternal.fromJson(Map<String, dynamic> json) {
    return MaterialExternal(
      id: json['id'] ?? 0,
      materialId: json['material_id'] ?? 0,
      plantId: json['plant_id'] ?? 0,
      updatedAt: json['updated_at'] ?? '',
      materialName: json['material_name'] ?? '',
      materialAttachment: json['material_attachment'] ?? '',
      linkData: json['linkData'] ?? '',
    );
  }
}
