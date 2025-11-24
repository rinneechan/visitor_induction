// lib/models/user_plant_external.dart

class UserPlantExternal {
  final String name;
  final String unit;
  // Tambahkan property companyEmailId
  final String? companyEmailId;

  UserPlantExternal({
    required this.name,
    required this.unit,
    this.companyEmailId, // Tambahkan ini
  });

  factory UserPlantExternal.fromJson(Map<String, dynamic> json) {
    return UserPlantExternal(
      name: json['full_name'] ?? '',
      unit: json['unit_name'] ?? '',
      // Tambahkan mapping dari JSON ke property Dart
      companyEmailId: json['company_email_id'] as String?, // Gunakan 'as String?' untuk keamanan
    );
  }

  String get fullName => name;
  String get unitName => unit;
  // Getter 'companyEmailId' dihapus karena tidak diperlukan.
  // Anda bisa langsung mengakses property-nya: userPlantExternal.companyEmailId
}