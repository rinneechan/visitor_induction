class UserPlantExternal {
  final String name;
  final String unit;

  UserPlantExternal({required this.name, required this.unit});

  factory UserPlantExternal.fromJson(Map<String, dynamic> json) {
    return UserPlantExternal(
      name: json['full_name'] ?? '',
      unit: json['unit_name'] ?? '',
    );
  }

  String get fullName => name;
  String get unitName => unit;
}
