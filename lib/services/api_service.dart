import 'dart:convert';
import 'package:hive/hive.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:she_vi/models/InductionMaterial.dart';
import 'package:she_vi/models/InductionMaterialById.dart';
import 'package:she_vi/models/InductionMaterialByPlant.dart';
import 'package:she_vi/models/Dept.dart';
import 'package:she_vi/models/Durations.dart';
import 'package:she_vi/models/InductionRequestHistory.dart';
import 'package:she_vi/models/InductionRequestProgress.dart';
import 'package:she_vi/models/InductionRequestId.dart';
import 'package:she_vi/models/QuestionRequestIdPlant.dart';
import 'package:she_vi/models/EmployeeByOu.dart';
import 'package:she_vi/models/plant_model.dart';
import 'package:she_vi/models/plantvisit.dart';
import 'package:she_vi/models/mc_question.dart';
import 'package:she_vi/utils/env_helper.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:flutter/foundation.dart';
//final url = 'https://cemindo-apps.com/api_visitor_induction/loginnik';
//"API_URL": "https://cemindo-apps.com/api_visitor_induction",
// "API_URL": "http://10.10.10.72:3007",

import 'package:dio/dio.dart';

class ApiService {
  int lastResponseStatusCode = 0;
  var box = Hive.box('userBox');
  final Dio _dio = Dio();
  String? _authToken; // Menyimpan token hasil getToken()
  // final String accessToken =
  //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjAxMTIyMDcwMDAyIiwibmFtZSI6IkZyYW4gU2FsYSBNb25kYSIsImVtYWlsIjoiZnJhbi5tb25kYUBjZW1pbmRvLmNvbSIsImlhdCI6MTczMzkxODI0Mn0.vhR98RfS3jGVDvue-vGMlh23owqZD8hGu8UpueJem-0';
  final String accessToken = '';
  final _timeout = const Duration(seconds: 15);

  Future<Map<String, dynamic>?> loginNik(String username) async {
    final String apiUrl = EnvHelper.get('API_URL'); // Ambil dari env.json
    if (apiUrl.isEmpty) {
      print("Error: API_URL tidak ditemukan di env.json!");
      return null;
    }
    final String url = '$apiUrl/loginnik';
    final Map<String, dynamic> data = {'nik': username};

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 30));

      lastResponseStatusCode = response.statusCode;

      if (response.statusCode == 200) {
        // Jika login berhasil
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        // Jika user tidak terdaftar tetapi ada datanya
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') &&
            responseData['data'].isNotEmpty) {
          return responseData['data'][0]; // Mengambil data pertama
        }
      }

      return null; // Jika gagal
    } on SocketException {
      print('Tidak ada koneksi ke server.');
      return null;
    } on TimeoutException {
      print('Permintaan ke server melebihi waktu tunggu.');
      return null;
    } catch (e) {
      print('Kesalahan: $e');
      return null;
    }
  }

  Future<bool> loginNikPass(
      String username, String password, String fcmToken) async {
    final String apiUrl = EnvHelper.get('API_URL'); // Ambil dari env.json
    if (apiUrl.isEmpty) {
      print("Error: API_URL tidak ditemukan di env.json!");
      return false;
    }
    final String url = '$apiUrl/loginPass';

    final Map<String, dynamic> data = {
      'nik': username,
      'password': password,
      'fcmToken': fcmToken,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      //print('Response Status Code: ${response.statusCode}');
      //print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        // Parsing respons dari server
        final responseData = json.decode(response.body);
        print('Response data: ${responseData}');

        if (responseData != null &&
            responseData['status'] == true &&
            responseData['data'] != null &&
            responseData['access_token'] != null) {
          // Ambil data dari respons
          String userid = responseData['data']['id'] ?? '';
          String visitorid =
              responseData['data']['visitor_id']?.toString() ?? '';
          String fullName = responseData['data']['name'] ?? '';
          String email = responseData['data']['email'] ?? '';
          String compname = responseData['data']['company_name'] ?? '';
          String jobposs = responseData['data']['job_position'] ?? '';
          String typeuser = responseData['data']['user_type'] ?? '';
          String area_code = responseData['data']['area_code'] ?? '';
          String name_role = responseData['data']['name_role'] ?? '';

          String fcmtoken = responseData['data']['fcmToken'] ?? '';
          String token = responseData['access_token'] ?? '';

          // Simpan data ke dalam storage lokal
          await box.put('userid', userid);
          await box.put('visitorid', visitorid);
          await box.put('username', fullName);
          await box.put('email', email);
          await box.put('compname', compname);
          await box.put('jobposs', jobposs);
          await box.put('typeuser', typeuser);
          await box.put('area_code', area_code);
          await box.put('name_role', name_role);
          await box.put('fcmtoken', fcmtoken);
          await box.put('token', token);

          return true;
        } else {
          print('Error: Data orr token is missing in the response.');
          return false;
        }
      } else {
        // Menampilkan pesan error dari server jika ada
        final responseBody = json.decode(response.body);
        String errorMessage = responseBody['message'] ??
            'Login failed with status code ${response.statusCode}';
        print('Login Error: $errorMessage');
        return false;
      }
    } catch (e) {
      // Penanganan jika terjadi kesalahan jaringan atau parsing
      print('Terjadi kesalahan: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> generateCode(
      String idEmployee, String nama, String email) async {
    //final url = 'http://10.10.10.72:3001/generateCode';
    final String apiUrl = EnvHelper.get('API_URL'); // Ambil dari env.json
    if (apiUrl.isEmpty) {
      print("Error: API_URL tidak ditemukan di env.json!");
      return null;
    }
    final String url = '$apiUrl/generateCode';

    final Map<String, dynamic> data = {
      'id_employee': idEmployee,
      'nama': nama,
      'email': email,
    };
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Gagal: ${response.body}');
        return null;
      }
    } on SocketException {
      print('Tidak ada koneksi ke server.');
      return null;
    } on TimeoutException {
      print('Permintaan ke server melebihi waktu tunggu.');
      return null;
    } catch (e) {
      print('Kesalahan: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyCode(
      String idEmployee, String code) async {
    //final url = 'https://cemindo-apps.com/api_visitor_induction/verifycode';
    final String apiUrl = EnvHelper.get('API_URL'); // Ambil dari env.json
    if (apiUrl.isEmpty) {
      print("Error: API_URL tidak ditemukan di env.json!");
      return null;
    }
    final String url = '$apiUrl/verifycode';
    final Map<String, dynamic> data = {
      'id_employee': idEmployee,
      'code': code,
    };

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Gagal: ${response.body}');
        return null;
      }
    } on SocketException {
      print('Tidak ada koneksi ke server.');
      return null;
    } on TimeoutException {
      print('Permintaan ke server melebihi waktu tunggu.');
      return null;
    } catch (e) {
      print('Kesalahan: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> register(
      String idEmployee, String password) async {
    final String apiUrl = EnvHelper.get('API_URL'); // Ambil dari env.json
    if (apiUrl.isEmpty) {
      print("Error: API_URL tidak ditemukan di env.json!");
      return null;
    }
    final String url = '$apiUrl/register';
    final Map<String, dynamic> data = {
      'id_employee': idEmployee,
      'password': password,
    };

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Gagal: ${response.body}');
        return null;
      }
    } on SocketException {
      print('Tidak ada koneksi ke server.');
      return null;
    } on TimeoutException {
      print('Permintaan ke server melebihi waktu tunggu.');
      return null;
    } catch (e) {
      print('Kesalahan: $e');
      return null;
    }
  }

//induction material
  Future<List<InductionMaterial>> fetchInductionMaterials() async {
    // final url = 'http://127.0.0.1:3001/materials';
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    if (apiUrl.isEmpty) {
      print("Error: API_URL tidak ditemukan di env.json!");
      throw Exception("API_URL tidak ditemukan di env.json!");
    }
    final String url = '$apiUrl/materials';

    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      final headers = {
        //'access_token': accessToken,
        accessHeaderKey: accessToken,
      };

      // Melakukan HTTP GET
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      print('Response Status body: ${response.body}');
      // Menyimpan status kode respons
      lastResponseStatusCode = response.statusCode;
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Validasi data dan parsing menjadi list
        if (responseData['data'] != null &&
            responseData['data']['materials'] != null) {
          List<dynamic> data = responseData['data']['materials'];
          return data.map((item) => InductionMaterial.fromJson(item)).toList();
        } else {
          throw Exception('No data found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error occurred: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  //induction material By Id
  Future<List<InductionMaterialBy>> materiByIdrequest(String byid) async {
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    if (apiUrl.isEmpty) {
      throw Exception("API_URL tidak ditemukan di env.json!");
    }
    final String url = '$apiUrl/materials/$byid';
    //final url = 'http://10.10.10.72:3001/materials/$byid';
    //final url = 'https://cemindo-apps.com/api_visitor_induction/materials/$byid';
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      final headers = {
        // 'access_token': accessToken,
        accessHeaderKey: accessToken,
      };
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          final data = responseData['data'];
          // Cetak hasil untuk debugging
          //print('respon data: $data');

          return [InductionMaterialBy.fromJson(data)];
        } else {
          throw Exception('No data found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  //induction material By plant

  Future<List<InductionMaterialByPlant>> materiByPlant(String byPlant) async {
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    final String? accessToken = box.get('token');

    // Validasi API URL
    if (apiUrl.isEmpty) {
      throw Exception("API_URL tidak ditemukan di env.json!");
    }

    // Validasi Token
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    final String url = '$apiUrl/materials/materialplant/$byPlant';

    try {
      final headers = {
        accessHeaderKey: accessToken,
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          final data = responseData['data'];
          print('Response data: $data');

          // Jika data adalah list
          if (data is List) {
            return data
                .map((item) => InductionMaterialByPlant.fromJson(item))
                .toList();
          } else {
            // Jika data adalah objek tunggal
            return [InductionMaterialByPlant.fromJson(data)];
          }
        } else {
          throw Exception('No data found in the response');
        }
      } else {
        throw Exception('Failed to load data: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<Dept>> fetchDept(String level) async {
    //final url = 'http://10.10.10.72:3001/plants/get-dep-plant';
    //final url = 'https://cemindo-apps.com/api_visitor_induction/plants/get-dep-plant';
    //final url = '${dotenv.env['API_URL']}/plants/get-dep-plant';
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    if (apiUrl.isEmpty) {
      //print("Error: API_URL tidak ditemukan di env.json!");
      throw Exception("API_URL tidak ditemukan di env.json!");
    }
    final String url = '$apiUrl/plants/get-dep-plant';
    // Mengambil token dari storage
    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        //'access_token': accessToken,
        accessHeaderKey: accessToken,
        'Content-Type': 'application/json',
      };
      // Body JSON untuk request
      final body = json.encode({
        "id": level,
      });
      // Melakukan HTTP POST
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      // Menyimpan status kode respons
      lastResponseStatusCode = response.statusCode;
      if (response.statusCode == 200) {
        // Parsing JSON response
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('fetching Dept: ${responseData['data']}');
        // Validasi dan parsing data
        if (responseData['data'] != null) {
          List<dynamic> data = responseData['data'];
          return data.map((item) => Dept.fromJson(item)).toList();
        } else {
          throw Exception('Invalid data format or no data found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  // Create Induction Request
  Future<bool> createInductionRequest(
    String visitorid,
    String statusid,
    String plantid,
    String departmentname,
    String picname,
    String arrivaldate,
    String durationid,
    String reasontovisit,
    String createdby,
    String updatedby,
  ) async {
    //final url = 'http://10.10.10.72:3001/inductionrequest';
    //final url = 'https://cemindo-apps.com/api_visitor_induction/inductionrequest';
    //final url = '${dotenv.env['API_URL']}/inductionrequest';
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    if (apiUrl.isEmpty) {
      //print("Error: API_URL tidak ditemukan di env.json!");
      throw Exception("API_URL tidak ditemukan di env.json!");
    }
    final String url = '$apiUrl/inductionrequest';
    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }
    try {
      final headers = {
        //'access_token': accessToken,
        accessHeaderKey: accessToken,
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        "visitor_id": visitorid,
        "status_id": statusid,
        "plant_id": plantid,
        "department_name": departmentname,
        "pic_name": picname,
        "arrival_date": arrivaldate,
        "duration_id": durationid,
        "reason_to_visit": reasontovisit,
        "created_by": createdby,
        "updated_by": updatedby,
      });
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Pastikan status bernilai true
        if (responseData['status'] == true) {
          print('Request berhasil: ${responseData['message']}');
          return true;
        } else {
          print('Request gagal: ${responseData['message']}');
          return false;
        }
      } else {
        print('Unexpected response: ${response.body}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<Durations>> fetchDuratuion() async {
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    if (apiUrl.isEmpty) {
      print("Error: API_URL tidak ditemukan di env.json!");
      throw Exception("API_URL tidak ditemukan di env.json!");
    }
    final String url = '$apiUrl/duration';
    //final url = 'http://10.10.10.72:3001/duration';
    //final url = 'https://cemindo-apps.com/api_visitor_induction/duration';

    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        //'access_token': accessToken,
        accessHeaderKey: accessToken,
      };
      // Melakukan HTTP GET
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      // Menyimpan status kode respons
      lastResponseStatusCode = response.statusCode;

      if (response.statusCode == 200) {
        // Parsing JSON response
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Validasi data dan parsing menjadi list
        if (responseData['data'] != null &&
            responseData['data']['durations'] != null) {
          List<dynamic> data = responseData['data']['durations'];
          return data.map((item) => Durations.fromJson(item)).toList();
        } else {
          throw Exception('No data found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<InductionRequestHistory>> fetchInductionrequest(
      String visitor) async {
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    if (apiUrl.isEmpty) {
      //print("Error: API_URL tidak ditemukan di env.json!");
      throw Exception("API_URL tidak ditemukan di env.json!");
    }
    final String url =
        '$apiUrl/inductionrequest/get-inductionrequest-user?id=$visitor';
    //final url = 'http://10.10.10.72:3001/inductionrequest/get-inductionrequest-user?id=$visitor';
    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }
    try {
      final headers = {
        //'access_token': accessToken,
        accessHeaderKey: accessToken,
        'Content-Type': 'application/json',
      };
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          List<dynamic> data = responseData['data'];
          return data
              .map((item) => InductionRequestHistory.fromJson(item))
              .toList();
        } else {
          throw Exception('Invalid data format or no data found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<InductionRequestProgress>> fetchInductionProgressrequest(
      String visitor) async {
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    if (apiUrl.isEmpty) {
      print("Error: API_URL tidak ditemukan di env.json!");
      throw Exception("API_URL tidak ditemukan di env.json!");
    }
    final String url =
        '$apiUrl/inductionrequest/get-inductionrequest-user-Progress';
    //final url = 'http://10.10.10.72:3001/inductionrequest/get-inductionrequest-user-Progress';

    // Mengambil token dari storage
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        //'access_token': accessToken,
        accessHeaderKey: accessToken,
        'Content-Type': 'application/json',
      };

      // Body JSON untuk request
      final body = json.encode({
        "id": visitor,
      });

      // Melakukan HTTP POST
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Parsing JSON response
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          List<dynamic> data = responseData['data'];
          return data
              .map((item) => InductionRequestProgress.fromJson(item))
              .toList();
        } else {
          throw Exception('Invalid data format or no data found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<InductionRequestId>> fetchInductionrequestId(
      String idrequest) async {
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    if (apiUrl.isEmpty) {
      print("Error: API_URL tidak ditemukan di env.json!");
      throw Exception("API_URL tidak ditemukan di env.json!");
    }
    final String url = '$apiUrl/inductionrequest/get-inductionrequest-id';
    //final url = 'http://10.10.10.72:3001/inductionrequest/get-inductionrequest-id';

    // Mengambil token dari storage
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        //'access_token': accessToken,
        accessHeaderKey: accessToken,
        'Content-Type': 'application/json',
      };

      // Body JSON untuk request
      final body = json.encode({
        "id": idrequest,
      });

      // Melakukan HTTP POST
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Parsing JSON response
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          List<dynamic> data = responseData['data'];
          return data.map((item) => InductionRequestId.fromJson(item)).toList();
        } else {
          throw Exception('Invalid data format or no data found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<QuestionRequestIdPlant>> fetchQuestionrequestplant(
      String idplant) async {
    // final String url =
    //     'http://10.10.10.72:3001/question/get-question-plant?id=$idplant';
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    if (apiUrl.isEmpty) {
      print("Error: API_URL tidak ditemukan di env.json!");
      throw Exception("API_URL tidak ditemukan di env.json!");
    }
    //final String url = 'https://cemindo-apps.com/api_visitor_induction/question/get-question-plant?id=$idplant';
    //final url = '${dotenv.env['API_URL']}/question/get-question-plant?id=$idplant';
    final String url = '$apiUrl/question/get-question-plant?id=$idplant';
    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }
    try {
      final headers = {
        //'access_token': accessToken,
        accessHeaderKey: accessToken,
        'Content-Type': 'application/json',
      };
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          List<dynamic> data = responseData['data'];
          return data
              .map((item) => QuestionRequestIdPlant.fromJson(item))
              .toList();
        } else {
          throw Exception('Invalid data format or no data found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<bool> createAnswerQuestion(
      int idrequest, int question_id, int choice_id) async {
    //final url = 'http://10.10.10.72:3001/question/create-answer-question';
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    if (apiUrl.isEmpty) {
      throw Exception("API_URL tidak ditemukan di env.json!");
    }
    //final url = 'https://cemindo-apps.com/api_visitor_induction/question/create-answer-question';

    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }
    final String url = '$apiUrl/question/create-answer-question';
    try {
      final headers = {
        // 'access_token': accessToken,
        accessHeaderKey: accessToken,
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        "induction_id": idrequest,
        "question_id": question_id,
        "choice_id": choice_id,
      });
      // Cetak body sebelum request
      print('Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Pastikan status bernilai true
        if (responseData['status'] == true) {
          print('Request berhasil: ${responseData['message']}');
          return true;
        } else {
          print('Request gagal: ${responseData['message']}');
          return false;
        }
      } else {
        print('Unexpected response: ${response.body}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<void> updateRequestVisitor(int idrequest, int statusId) async {
    // final approvalUrl =
    //     'http://10.10.10.72:3001/inductionrequest/update-inductionrequest-test/$idrequest';
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    if (apiUrl.isEmpty) {
      throw Exception("API_URL tidak ditemukan di env.json!");
    }

    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }
    final Map<String, String> headers = {
      //'access_token': accessToken,
      accessHeaderKey: accessToken,
      'Content-Type': 'application/json',
    };
    final String approvalUrl =
        '$apiUrl/inductionrequest/update-inductionrequest-test/$idrequest';
    final body = json.encode({"status_id": statusId});

    try {
      final response = await http.put(
        Uri.parse(approvalUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Approval request successful: ${response.body}');
      } else {
        print('Failed to approve: ${response.statusCode}');
        throw Exception('Failed to approve induction request');
      }
    } catch (e) {
      print('Error during approval request: $e');
    }
  }

  //Approval email no token
  Future<String> sendApprovalRequest(int idrequest) async {
    // final approvalUrl =
    //     'http://10.10.10.72:3001/requestinduction/update-inductionrequest/$idrequest';
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    if (apiUrl.isEmpty) {
      throw Exception("API_URL tidak ditemukan di env.json!");
    }
    final String approvalUrl =
        '$apiUrl/requestinduction/update-inductionrequest/$idrequest';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final body = json.encode({"status_id": '1'});
    print('Sending approval request: $body');

    try {
      final response = await http.put(
        Uri.parse(approvalUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        print('Approval request successful: ${responseBody['message']}');
        return responseBody['message']; // Return success message
      } else {
        final responseBody = json.decode(response.body);
        print(
            'Failed to approve: ${response.statusCode}, ${responseBody['message']}');
        throw Exception(
            responseBody['message'] ?? 'Failed to approve induction request');
      }
    } catch (e) {
      print('Error during approval request: $e');
      throw Exception('Network error occurred');
    }
  }

  Future<List<InductionRequestHistory>> fetchInductionrequestScan(
      String visitor) async {
    //final url =
    //   'http://10.10.10.72:3001/requestinduction/get-inductionrequest-user-scan?id=$visitor';
    final String apiUrl = EnvHelper.get('API_URL');
    if (apiUrl.isEmpty) {
      throw Exception("API_URL tidak ditemukan di env.json!");
    }
    final String url =
        '$apiUrl/requestinduction/get-inductionrequest-user-scan?id=$visitor';

    try {
      final headers = {
        //'access_token': accessToken,
        'Content-Type': 'application/json',
      };
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          List<dynamic> data = responseData['data'];
          return data
              .map((item) => InductionRequestHistory.fromJson(item))
              .toList();
        } else {
          throw Exception('Invalid data format or no data found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<EmployeeByOu>> employeeByPlant(String ou) async {
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    if (apiUrl.isEmpty) {
      print("Error: API_URL tidak ditemukan di env.json!");
      throw Exception("API_URL tidak ditemukan di env.json!");
    }
    final String url = '$apiUrl/plants/get-user-plant/$ou';

    //final url = 'http://10.10.10.72:3001/plants/get-user-plant/$ou';
    //final url = 'https://cemindo-apps.com/api_visitor_induction/plants/get-user-plant/$ou';
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      final headers = {
        //'access_token': accessToken,
        accessHeaderKey: accessToken,
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        // Parsing respons sebagai Map terlebih dahulu
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['data'] != null) {
          final List<dynamic> listData = jsonResponse['data'];
          // Mapping setiap item JSON ke objek EmployeeByOu
          return listData
              .map(
                  (item) => EmployeeByOu.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('No data found');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to load data: $e');
    }
  }

//wasabi
  Future<void> getToken() async {
    try {
      final String url = 'https://report-id.online/api_swo/auth/get_token';

      final data = {
        'username': 'maLord',
        'password': 'maP@ssw0rd',
      };

      final options = Options(
        headers: {
          'access_token': accessToken,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      final response = await _dio.post(url, data: data, options: options);

      // Ambil token dari response
      _authToken = response.data['token']; // Pastikan struktur JSON benar
      print('Token didapat: $_authToken');
    } catch (e) {
      print('Error saat mengambil token: $e');
    }
  }

  Future<dynamic> openFile(String byid) async {
    if (_authToken == null) {
      print('Token belum tersedia, mengambil token...');
      await getToken();
    }

    try {
      final String url =
          'https://cemindo-apps.com/wasabi-service/public/api/open_file';

      final data = {
        "real_file_name": ["VI_DEV/791893b33340424393496c6b1dc3b66a9215.mp4"]
      };

      final options = Options(
        headers: {
          'access_token': accessToken,
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken', // Menggunakan token dinamis
        },
      );

      final response = await _dio.post(url, data: data, options: options);
      return response.data;
    } catch (e) {
      print('Error saat membuka file: $e');
      return null;
    }
  }

  // ---------------------------
// ✅ Ambil daftar plant untuk dashboard / request induction
// ---------------------------
  Future<List<Plantvisit>> fetchPlants() async {
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    final String? accessToken = box.get('token');

    if (apiUrl.isEmpty) throw Exception("API_URL tidak ditemukan di env.json!");
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    final url = Uri.parse('$apiUrl/plants');
    final headers = {
      accessHeaderKey: accessToken,
      'Content-Type': 'application/json',
    };

    print("🌐 [FETCH PLANTS - DASHBOARD] Request → $url");
    print("📦 Headers: $headers");

    try {
      final response = await http.get(url, headers: headers).timeout(_timeout);

      print("📥 Status: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        final data = decoded['data']?['plants'] ?? decoded['data'] ?? decoded;

        if (data is List) {
          print("🌱 Total plants (dashboard): ${data.length}");
          return data.map((e) => Plantvisit.fromJson(e)).toList();
        } else {
          throw Exception('Invalid data format: expected list of plants');
        }
      } else {
        throw Exception('Failed to load plants: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print("❌ Error in fetchPlants(): $e");
      throw Exception('Failed to load plants: $e');
    }
  }

// ---------------------------
// ✅ Ambil daftar plant untuk CMS
// ---------------------------
  Future<List<Plant>> fetchPlantsCMS() async {
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    final String? accessToken = box.get('token');

    if (apiUrl.isEmpty) throw Exception("API_URL tidak ditemukan di env.json!");
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    final url = Uri.parse('$apiUrl/plants');
    final headers = {
      accessHeaderKey: accessToken,
      'Content-Type': 'application/json',
    };

    print("🌐 [FETCH PLANTS - CMS] Request → $url");
    print("📦 Headers: $headers");

    try {
      final response = await http.get(url, headers: headers).timeout(_timeout);

      print("📥 Status: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        final data = decoded['data']?['plants'] ?? decoded['data'] ?? decoded;

        if (data is List) {
          print("🌱 Total plants (CMS): ${data.length}");
          return data.map((e) => Plant.fromJson(e)).toList();
        } else {
          throw Exception('Invalid data format: expected list of plants');
        }
      } else {
        throw Exception('Failed to load plants: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print("❌ Error in fetchPlantsCMS(): $e");
      throw Exception('Failed to load plants: $e');
    }
  }

  Future<List<MCQuestion>> fetchQuestionsByPlant(int plantId) async {
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    final String? accessToken = box.get('token');

    if (apiUrl.isEmpty) throw Exception("API_URL tidak ditemukan!");
    if (accessToken == null || accessToken.isEmpty)
      throw Exception('Access token invalid');

    final url = Uri.parse('$apiUrl/question/get-question-plant?id=$plantId');
    final headers = {
      accessHeaderKey: accessToken,
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.get(url, headers: headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] ?? decoded;
        final questionsList = data is Map && data.containsKey('questions')
            ? data['questions'] as List<dynamic>
            : data as List<dynamic>;

        return questionsList.map((e) => MCQuestion.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetchQuestionsByPlant: $e');
      return [];
    }
  }
}
