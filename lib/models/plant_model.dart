class Plant {
  final int id;
  final String plantCode;
  final String plantName;
  final bool isActive;

  Plant({
    required this.id,
    required this.plantCode,
    required this.plantName,
    required this.isActive,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      plantCode: json['plant_code'],
      plantName: json['plant_name'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plant_code': plantCode,
      'plant_name': plantName,
      'is_active': isActive,
    };
  }
}
