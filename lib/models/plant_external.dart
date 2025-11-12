class PlantExternal {
  final int id;
  final String plantName;
  final String plantCode;

  PlantExternal({
    required this.id,
    required this.plantName,
    required this.plantCode,
  });

  factory PlantExternal.fromJson(Map<String, dynamic> json) {
    return PlantExternal(
      id: json['id'] ?? 0,
      plantName: json['plant_name'] ?? '',
      plantCode: json['plant_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'plant_name': plantName,
        'plant_code': plantCode,
      };
}
