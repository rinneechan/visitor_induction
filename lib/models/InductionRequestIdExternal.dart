// lib/models/InductionRequestIdExternal.dart
import 'dart:convert';
import 'profil.dart'; // Sesuaikan path jika struktur folder berbeda

class InductionRequestIdExternal {
  final String id;
  final String plantId;
  final String plantName;
  final String departmentName;
  final String picName;
  final String statusName;
  final String arrivalDate;
  final String passType;
  final String reasonToVisit;
  final String fullName;
  final Profil profil;

  InductionRequestIdExternal({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.departmentName,
    required this.picName,
    required this.statusName,
    required this.arrivalDate,
    required this.passType,
    required this.reasonToVisit,
    required this.fullName,
    required this.profil, // Tambahkan ke constructor
  });

  factory InductionRequestIdExternal.fromJson(Map<String, dynamic> json) {
    // 1. Periksa apakah 'data' ada dan merupakan List
    if (json['data'] == null || json['data'] is! List || json['data'].isEmpty) {
      // Jika data tidak ada, kosong, atau bukan list, lempar error
      throw Exception("API response 'data' is missing, not a list, or empty: ${json['data']}");
    }

    // 2. Ambil item pertama dari array 'data'
    Map<String, dynamic> dataItem = json['data'][0];

    // 3. Periksa apakah 'profil' ada dan merupakan Map
    if (json['profil'] == null) {
      // Jika profil tidak ada, lempar error
      throw Exception("API response 'profil' is missing: ${json['profil']}");
    }
    if (json['profil'] is! Map<String, dynamic>) {
       // Jika profil bukan Map, lempar error
       throw Exception("API response 'profil' is not a Map: ${json['profil']}");
    }

    // 4. Ambil data profil dari objek 'profil'
    Map<String, dynamic> profilJson = json['profil'];

    return InductionRequestIdExternal(
      id: dataItem["id"]?.toString() ?? "", // Konversi ke string, default ke ""
      plantId: dataItem["plant_id"]?.toString() ?? "", // Konversi ke string, default ke ""
      plantName: dataItem["plant_name"] ?? "",
      departmentName: dataItem["department_name"] ?? "",
      picName: dataItem["pic_name"] ?? "",
      statusName: dataItem["status_name"] ?? "",
      arrivalDate: dataItem["arrival_date"] ?? "",
      passType: dataItem["pass_type"] ?? "",
      reasonToVisit: dataItem["reason_to_visit"] ?? "",
      fullName: dataItem["full_name"] ?? "",
      // Inisialisasi profil dari data 'profil'
      profil: Profil.fromJson(profilJson),
    );
  }
}