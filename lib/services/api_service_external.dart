// lib/services/api_service_external.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:she_vi/models/InductionRequestProgressExternal.dart';
import 'package:she_vi/utils/env_helper.dart';
import 'package:she_vi/models/duration_external_model.dart';
import 'package:she_vi/models/plant_external.dart';
import 'package:she_vi/models/user_plant_external.dart';
import 'package:she_vi/models/InductionRequestIdExternal.dart';
import 'package:she_vi/models/MaterialExternal.dart';
import 'package:she_vi/models/question_request_external.dart';
import 'package:she_vi/models/answer_question_external.dart';

class ApiServiceExternal {
  static const String _apiKey = 'rahasia123';
  final Dio _dio = Dio();

  Future<String?> getTokenExternal() async {
  final box = Hive.box('userBox');
  return box.get('token_external'); // jika memang suatu saat token ada
}


  // ------------------- Plants -------------------
  static Future<List<PlantExternal>> fetchPlantsExternal() async {
    final String apiUrl = EnvHelper.get('API_URL');
    final response = await http.get(
      Uri.parse('$apiUrl/plants-external'),
      headers: {'x-api-key': _apiKey},
    );
    final data = jsonDecode(response.body);
    final List<dynamic> plantsJson = data['data']['plants'];
    return plantsJson.map((e) => PlantExternal.fromJson(e)).toList();
  }

  // ------------------- Employees by Plant -------------------
  static Future<List<UserPlantExternal>> fetchUserByPlantExternal(
      String plantCode) async {
    final String apiUrl = EnvHelper.get('API_URL');
    final response = await http.get(
      Uri.parse('$apiUrl/plants-external/get-user-plant/$plantCode'),
      headers: {'x-api-key': _apiKey},
    );
    final data = jsonDecode(response.body);
    final List<dynamic> employees = data['data'];
    return employees.map((e) => UserPlantExternal.fromJson(e)).toList();
  }

  // ------------------- Durations -------------------
  static Future<List<DurationExternal>> fetchDurationsExternal() async {
    final String apiUrl = EnvHelper.get('API_URL');
    final response = await http.get(
      Uri.parse('$apiUrl/duration-external'),
      headers: {'x-api-key': _apiKey},
    );
    final data = jsonDecode(response.body);
    final List<dynamic> durationsJson = data['data']['durations'];
    return durationsJson.map((e) => DurationExternal.fromJson(e)).toList();
  }

  // ------------------- Submit Induction Request -------------------
  static Future<bool> submitInductionRequestExternal({
    required String fullName,
    required String companyName,
    required String workEmail,
    required String noHp,
    required String jobPosition,
    required String userType,
    required String tokenFirebase,
    required int plantId,
    required String departmentName,
    required String picName,
    required String arrivalDate,
    required int durationId,
    required String reasonToVisit,
    required String createdBy,
    required String updatedBy,
  }) async {
    final String apiUrl = EnvHelper.get('API_URL');
    final url =
        Uri.parse('$apiUrl/inductionrequest-external/add-request-external');

    final headers = {
      'x-api-key': _apiKey,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "full_name": fullName,
      "company_name": companyName,
      "work_email": workEmail,
      "nohp": noHp,
      "job_position": jobPosition,
      "user_type": userType,
      "tokenfirebase": tokenFirebase,
      "plant_id": plantId,
      "department_name": departmentName,
      "pic_name": picName,
      "arrival_date": arrivalDate,
      "duration_id": durationId,
      "reason_to_visit": reasonToVisit,
      "created_by": createdBy,
      "updated_by": updatedBy,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return responseBody['status'] == true;
      } else {
        debugPrint("Submit failed [${response.statusCode}]: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint('Error submit induction request: $e');
      return false;
    }
  }

  // ------------------- Induction Request Progress (EXTERNAL) -------------------
  static Future<List<InductionRequestProgressExternal>> fetchInductionProgressrequestExternal(
      String visitorId) async {
    final String apiUrl = EnvHelper.get('API_URL');

    final url =
        '$apiUrl/inductionrequest-external/get-inductionrequest-user-Progress-exsternal';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'x-api-key': _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "id": visitorId,
      }),
    );

    // print("RESPONSE STATUS: ${response.statusCode}");
    // print("RESPONSE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load data: ${response.statusCode}");
    }

    final data = jsonDecode(response.body);

    // Format mengikuti EXACT seperti Plants
    if (data['data'] == null) {
      throw Exception("No data found");
    }

    // diasumsikan struktur: { "data": [ { ... }, { ... } ] }
    final List<dynamic> jsonList = data['data'];

    return jsonList
        .map((item) => InductionRequestProgressExternal.fromJson(item))
        .toList();
  }

  // ------------------- Get Induction Request by REQUEST ID (EXTERNAL) -------------------
  static Future<InductionRequestIdExternal?> fetchInductionRequestByIdExternal(
      String requestId) async {
    final String apiUrl = EnvHelper.get('API_URL') ?? '';
    final url = '$apiUrl/inductionrequest-external/get-inductionrequest-id-exsternal';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'x-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"id": requestId}),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed: ${response.statusCode}");
      }

      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      // Cek status dan data
      if (jsonData['status'] != true) {
        return null;
      }

      // Parse seluruh response termasuk profil
      return InductionRequestIdExternal.fromJson(jsonData);
    } catch (e) {
      throw Exception("Error fetchInductionRequestByIdExternal: $e");
    }
  }

  // ------------------- Get Material by Plant ID (EXTERNAL) -------------------
  Future<MaterialExternal> materiExternalByPlant(String plantId) async {
    final String apiUrl = EnvHelper.get('API_URL');
    final url = '$apiUrl/materials-external/materialplant-external/$plantId';

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            "x-api-key": "rahasia123",
          },
        ),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['data'] != null) {

        return MaterialExternal.fromJson(response.data['data']);
      }

      throw Exception("Material not found");

    } catch (e) {
      throw Exception("Error materiExternalByPlant: $e");
    }
  }

  Future<List<QuestionRequestExternal>> fetchQuestionrequestplantExternal(String plantId) async {
  final String apiUrl = EnvHelper.get('API_URL');
  final url = "$apiUrl/question-external/get-question-plant?id=$plantId";

  try {
    // ✅ TAMBAHKAN HEADER INI
    final response = await _dio.get(
      url,
      options: Options(
        headers: {
          //'x-api-key': 'rahasia123', // ✅ HARUS ADA — sama seperti di Postman
          "x-api-key": ApiServiceExternal._apiKey,
          'Content-Type': 'application/json',
        },
      ),
    );

    debugPrint('Response fetchQuestionrequestplantExternal: ${response.data}');

    if (response.statusCode == 200 && response.data['status'] == true) {
      final List data = response.data['data'];
      return data.map((json) => QuestionRequestExternal.fromJson(json)).toList();
    } else {
      throw Exception("Gagal memuat soal external");
    }
  } catch (e) {
    debugPrint("❌ Error fetchQuestionrequestplantExternal: $e");
    rethrow;
  }
}

// -------------------- CREATE ANSWER QUESTION EXTERNAL --------------------
// Future<AnswerQuestionExternalResponse?> createAnswerQuestionExternal(
//     int inductionId,
//     int questionId,
//     int choiceId,
// ) async {
//   final String apiUrl = EnvHelper.get('API_URL');
//   final url = "$apiUrl/question-external/create-answer-question";

//   try {
//     final response = await _dio.post(
//       url,
//       options: Options(
//         headers: {
//           "x-api-key": _apiKey,
//           "Content-Type": "application/json",
//         },
//       ),
//       data: {
//         "induction_id": inductionId,
//         "question_id": questionId,
//         "choice_id": choiceId,
//       },
//     );

//     if (response.statusCode == 200 && response.data["status"] == true) {
//       return AnswerQuestionExternalResponse.fromJson(response.data);
//     } else {
//       debugPrint("❌ Create Answer Failed: ${response.data}");
//     }
//   } catch (e) {
//     debugPrint("❌ createAnswerQuestionExternal Exception: $e");
//   }

//   return null;
// }
Future<AnswerQuestionExternalResponse?> createAnswerQuestionExternal(
    int inductionId,
    int questionId,
    int choiceId,
) async {
  final String apiUrl = EnvHelper.get('API_URL');
  final url = "$apiUrl/question-external/create-answer-question";

  try {
    final response = await _dio.post(
      url,
      options: Options(
        headers: {
          "x-api-key": _apiKey,
          "Content-Type": "application/json",
        },
      ),
      data: {
        "induction_id": inductionId,
        "question_id": questionId,
        "choice_id": choiceId,
      },
    );

    // ✅ Tambahkan ini untuk debugging
    debugPrint("DEBUG: Response Status Code: ${response.statusCode}");
    debugPrint("DEBUG: Response Data Type: ${response.data.runtimeType}");
    debugPrint("DEBUG: Response Data: ${response.data}");
    if(response.data is Map<String, dynamic>) {
        debugPrint("DEBUG: Status field: ${response.data['status']} (Type: ${response.data['status']?.runtimeType})");
    }

    if ((response.statusCode == 200 || response.statusCode == 201) && response.data["status"] == true) {
      debugPrint("DEBUG: Inside success condition"); // Tambahkan ini
      return AnswerQuestionExternalResponse.fromJson(response.data);
    } else {
      debugPrint("❌ Create Answer Failed: ${response.data}");
    }
  } catch (e) {
    debugPrint("❌ createAnswerQuestionExternal Exception: $e");
  }

  return null;
}

//  Future<bool> createAnswerQuestionExternal(
//       int inductionId,
//       int questionId,
//       int choiceId,
//   ) async {
//     final String apiUrl = EnvHelper.get('API_URL');
//     final url = "$apiUrl/question-external/create-answer-question";

//     try {
//       final response = await _dio.post(
//         url,
//         options: Options(
//           headers: {
//             "x-api-key": _apiKey, // ✅ Gunakan API key yang benar
//             "Content-Type": "application/json",
//           },
//         ),
//          {
//           "induction_id": inductionId,
//           "question_id": questionId,
//           "choice_id": choiceId,
//         },
//       );

//       // ✅ Periksa status code dan status dari response body
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = response.data;
//         if (responseData is Map<String, dynamic> && responseData['status'] == true) {
//           debugPrint("✅ Create Answer Success: ${responseData['message'] ?? 'Success'}");
//           return true; // ✅ Kembalikan true jika sukses
//         } else {
//           debugPrint("❌ Create Answer Failed (status false): ${responseData}");
//           return false; // ✅ Kembalikan false jika status false
//         }
//       } else {
//         debugPrint("❌ Create Answer Failed (status code): ${response.statusCode}, ${response.data}");
//         return false; // ✅ Kembalikan false jika status code bukan 200/201
//       }
//     } catch (e) {
//       debugPrint("❌ createAnswerQuestionExternal Exception: $e");
//       // ✅ Jangan return null, tapi false untuk menandakan gagal
//       return false;
//     }
//   }

// Future<bool> createAnswerQuestionExternal(
//     int inductionId,
//     int questionId,
//     int choiceId,
// ) async {
//   final String apiUrl = EnvHelper.get('API_URL');
//   final url = "$apiUrl/question-external/create-answer-question";

//   try {
//     final response = await _dio.post(
//       url,
//       options: Options(
//         headers: {
//           "x-api-key": _apiKey, // ✅ Gunakan API key yang benar
//           "Content-Type": "application/json",
//         },
//       ),
//       data: {
//         "induction_id": inductionId,
//         "question_id": questionId,
//         "choice_id": choiceId,
//       },
//     );

//     // ✅ Periksa status code dan status dari response body
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final responseData = response.data;
//       if (responseData is Map<String, dynamic> && responseData['status'] == true) {
//         debugPrint("✅ Create Answer Success: ${responseData['message'] ?? 'Success'}");
//         return true; // ✅ Kembalikan true jika sukses
//       } else {
//         debugPrint("❌ Create Answer Failed (status false): ${responseData}");
//         return false; // ✅ Kembalikan false jika status false
//       }
//     } else {
//       debugPrint("❌ Create Answer Failed (status code): ${response.statusCode}, ${response.data}");
//       return false; // ✅ Kembalikan false jika status code bukan 200/201
//     }
//   } catch (e) {
//     debugPrint("❌ createAnswerQuestionExternal Exception: $e");
//     // ✅ Jangan return null, tapi false untuk menandakan gagal
//     return false;
//   }

 

}