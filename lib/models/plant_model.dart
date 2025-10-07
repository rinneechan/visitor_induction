class Plant {
  final int id;
  final String code; // kode plant
  final String name; // nama plant
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Fallback lama agar kompatibel
  String? get plantCode => code;
  String? get plantName => name;

  Plant({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      code: json['plant_code'] ?? json['code'] ?? '',
      name: json['plant_name'] ?? json['name'] ?? '',
      isActive: json['is_active'] is bool
          ? json['is_active']
          : (json['is_active'] == 1 || json['is_active'] == '1'),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plant_code': code,
      'plant_name': name,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Plant copyWith({
    int? id,
    String? code,
    String? name,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Plant(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => "$name ($code)";
}
