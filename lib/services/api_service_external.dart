import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // untuk debugPrint
import 'package:she_vi/utils/env_helper.dart';
import 'package:she_vi/models/duration_external_model.dart';
import 'package:she_vi/models/plant_external.dart';
import 'package:she_vi/models/user_plant_external.dart';
import 'package:she_vi/models/induction_request_external.dart';

class ApiServiceExternal {
  static const String _apiKey = 'rahasia123';

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
  static Future<List<UserPlantExternal>> fetchUserByPlantExternal(String plantCode) async {
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
  required String visitorId,
  required String statusId,
  required String plantId,
  required String departmentName,
  required String picName,
  required String arrivalDate,
  required int durationId,
  required String reasonToVisit,
  required String createdBy,
  required String updatedBy,
}) async {
  final request = InductionRequestExternal(
    visitorId: visitorId,
    statusId: statusId,
    plantId: plantId,
    departmentName: departmentName,
    picName: picName,
    arrivalDate: arrivalDate,
    durationId: durationId,
    reasonToVisit: reasonToVisit,
    createdBy: createdBy,
    updatedBy: updatedBy,
  );

  final String apiUrl = EnvHelper.get('API_URL');
  final url = '$apiUrl/inductionrequest-external/add-request-external';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
      body: jsonEncode(request.toJson()),
    );

    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("BODY RESPONSE: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    debugPrint('Error submit induction request: $e');
    return false;
  }
}
}
