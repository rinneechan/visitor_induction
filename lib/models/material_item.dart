class MaterialItem {
  final String kode;
  final String title;
  final String description;
  final String uploadedAt;
  final String fileName;

  MaterialItem({
    required this.kode,
    required this.title,
    required this.description,
    required this.uploadedAt,
    required this.fileName,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      kode: json['kode'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      uploadedAt: json['uploadedAt'] ?? '',
      fileName: json['fileName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "kode": kode,
      "title": title,
      "description": description,
      "uploadedAt": uploadedAt,
      "fileName": fileName,
    };
  }
}