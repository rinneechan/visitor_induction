class Profil {
  final int id;
  final String fullName;
  final String companyName;
  final String workEmail;
  final String nohp;
  final String jobPosition;
  final String userType;
  final dynamic nik; // Bisa null, jadi gunakan dynamic atau String? (nullable String)
  final String uuid;

  Profil({
    required this.id,
    required this.fullName,
    required this.companyName,
    required this.workEmail,
    required this.nohp,
    required this.jobPosition,
    required this.userType,
    this.nik, // Gunakan nullable jika bisa null
    required this.uuid,
  });

  factory Profil.fromJson(Map<String, dynamic> json) {
    return Profil(
      id: json["id"] ?? 0,
      fullName: json["full_name"] ?? "",
      companyName: json["company_name"] ?? "",
      workEmail: json["work_email"] ?? "",
      nohp: json["nohp"] ?? "",
      jobPosition: json["job_position"] ?? "",
      userType: json["user_type"] ?? "",
      // Handle null value untuk nik
      nik: json["nik"], // atau gunakan `json["nik"] ?? ""` jika ingin string kosong
      uuid: json["uuid"] ?? "",
    );
  }
}