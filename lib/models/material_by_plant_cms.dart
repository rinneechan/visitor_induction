class MaterialByPlantCMS {
  final int? id;
  final String? materialName;
  final String? fileName;
  final String? folder;
  final int? plantId;

  MaterialByPlantCMS({
    this.id,
    this.materialName,
    this.fileName,
    this.folder,
    this.plantId,
  });

  factory MaterialByPlantCMS.fromJson(Map<String, dynamic> json) {
    return MaterialByPlantCMS(
      id: json['id'] ?? json['material_id'],
      materialName: json['materialname'] ?? json['material_name'],
      fileName: json['file_name'] ?? json['filename'],
      folder: json['folder'],
      plantId: json['plant_id'] is String
          ? int.tryParse(json['plant_id'])
          : json['plant_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialname': materialName,
      'file_name': fileName,
      'folder': folder,
      'plant_id': plantId,
    };
  }
}
