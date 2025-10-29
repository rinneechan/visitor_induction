class MaterialModel {
  final int? id;
  final String materialname;
  final String status;
  final String isactive;
  final String folder;
  final String plantId;
  final String? fileUrl;

  MaterialModel({
    this.id,
    required this.materialname,
    required this.status,
    required this.isactive,
    required this.folder,
    required this.plantId,
    this.fileUrl,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      materialname: json['materialname'] ?? '',
      status: json['status'] ?? '',
      isactive: json['isactive']?.toString() ?? '',
      folder: json['folder'] ?? '',
      plantId: json['plant_id']?.toString() ?? '',
      fileUrl: json['file_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialname': materialname,
      'status': status,
      'isactive': isactive,
      'folder': folder,
      'plant_id': plantId,
      'file_url': fileUrl,
    };
  }
}
