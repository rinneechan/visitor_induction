import 'dart:convert';
import 'package:hive/hive.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';



import 'package:http/http.dart' as http;
import 'package:she_vi/models/InductionMaterial.dart';
import 'package:she_vi/models/InductionMaterialById.dart';
import 'package:she_vi/models/Plant.dart';
import 'package:she_vi/models/Dept.dart';
import 'package:she_vi/models/Durations.dart';
import 'package:she_vi/models/InductionRequestHistory.dart';
import 'package:she_vi/models/InductionRequestProgress.dart';
import 'package:she_vi/models/InductionRequestId.dart';
import 'package:she_vi/models/QuestionRequestIdPlant.dart';

class ApiService {
  int lastResponseStatusCode = 0;
  var box = Hive.box('userBox');
  //login Nik
  //final url = '${String.fromEnvironment('API_URL')}/loginnik';
  // final url = '${dotenv.env['API_URL']}/loginnik';

  Future<bool> loginNik(String username) async {
    final url = 'https://cemindo-apps.com/api_visitor_induction/loginnik';
    //final url = 'http://10.10.10.72:3001/loginnik';
    final Map<String, dynamic> data = {'nik': username,};
    try {
      final response = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
      ).timeout(const Duration(seconds: 30)); // Tambahkan timeout 10 detik

      lastResponseStatusCode = response.statusCode;
      print('respon: $lastResponseStatusCode');
      if (response.statusCode == 200) {
        // Login berhasil
        return true;
      } else {
        // Login gagal
        return false;
      }
    } on SocketException {
      // Tidak ada koneksi internet atau server tidak dapat dijangkau
      print('Tidak ada koneksi ke server.');
      return false;
    } on TimeoutException {
      // Jika permintaan melebihi waktu tunggu
      print('Permintaan ke server melebihi waktu tunggu.');
      return false;
    } catch (e) {
      // Kesalahan lainnya

      return false;
    }
  }

//login Nik dan Password
  Future<bool> loginNikPass(String username, String password , String fcmToken) async {
    final url = 'https://cemindo-apps.com/api_visitor_induction/loginPass';
    ///final url = '${dotenv.env['API_URL']}/loginPass';
    //final url = 'http://10.10.10.72:3001/loginPass';
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

        if (responseData != null && responseData['status'] == true && responseData['data'] != null && responseData['access_token'] != null) {
          // Ambil data dari respons
          String userid = responseData['data']['id'] ?? '';
          String visitorid = responseData['data']['visitor_id']?.toString() ?? '';
          String fullName = responseData['data']['name'] ?? '';
          String email = responseData['data']['email'] ?? '';
          String compname = responseData['data']['company_name'] ?? '';
          String jobposs = responseData['data']['job_position'] ?? '';
          String typeuser = responseData['data']['user_type'] ?? '';
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

//induction material
  Future<List<InductionMaterial>> fetchInductionMaterials() async {
    final url = 'https://cemindo-apps.com/api_visitor_induction/materials';
    //final url = '${dotenv.env['API_URL']}/materials';
    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }
    try {
      final headers = {
        'Access-Token': accessToken,
      };

      // Melakukan HTTP GET
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      //print('Response Status body: ${response.body}');
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
    //final url = '${dotenv.env['API_URL']}/materials/$byid';
    final url = 'https://cemindo-apps.com/api_visitor_induction/materials/$byid';
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      final headers = {
        'Access-Token': accessToken,
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      // Menampilkan respons di konsol untuk debugging
      //print('Response Status body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          final data = responseData['data'];
          // Cetak hasil untuk debugging
          print('respon data: $data');

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

  Future<List<PlantModel>> fetchPlant() async {

    final url = 'https://cemindo-apps.com/api_visitor_induction/plants';
    //final url = '${dotenv.env['API_URL']}/plants';
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        'Access-Token': accessToken,
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
            responseData['data']['plants'] != null) {
          List<dynamic> data = responseData['data']['plants'];
          return data.map((item) => PlantModel.fromJson(item)).toList();
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

  Future<List<Dept>> fetchDept(String level) async {
    final url = 'https://cemindo-apps.com/api_visitor_induction/plants/get-dep-plant';
    //final url = '${dotenv.env['API_URL']}/plants/get-dep-plant';
    // Mengambil token dari storage
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        'Access-Token': accessToken,
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
  Future<bool> createInductionRequest(String visitorid,String statusid,String plantid,String departmentname,String picname,String arrivaldate,String durationid,String reasontovisit,String createdby,String updatedby,)async {

    final url = 'https://cemindo-apps.com/api_visitor_induction/inductionrequest';
    //final url = '${dotenv.env['API_URL']}/inductionrequest';
    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

            try {
              final headers = {
                'Access-Token': accessToken,
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
    final url = 'https://cemindo-apps.com/api_visitor_induction/duration';
    //final url = '${dotenv.env['API_URL']}/duration';
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        'Access-Token': accessToken,
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



  Future<List<InductionRequestHistory>> fetchInductionrequest(String visitor) async {

    final  url = 'https://cemindo-apps.com/api_visitor_induction/inductionrequest/get-inductionrequest-user?id=$visitor';
    //final  url = '${dotenv.env['API_URL']}/inductionrequest/get-inductionrequest-user?id=$visitor';
    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }
    try {
      final headers = {
        'Access-Token': accessToken,
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

  Future<List<InductionRequestProgress>> fetchInductionProgressrequest(String visitor) async {
    final url ='https://cemindo-apps.com/api_visitor_induction/inductionrequest/get-inductionrequest-user-Progress';
    //final url = '${dotenv.env['API_URL']}/inductionrequest/get-inductionrequest-user-Progress';
    // Mengambil token dari storage
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        'Access-Token': accessToken,
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
      //print('Response progress Status Code: ${response.statusCode}');
      //print('Response progress Body: ${response.body}');
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

  Future<List<InductionRequestId>> fetchInductionrequestId(String idrequest) async {
    final url = 'https://cemindo-apps.com/api_visitor_induction/inductionrequest/get-inductionrequest-id';
    //final url = '${dotenv.env['API_URL']}/inductionrequest/get-inductionrequest-id';

    // Mengambil token dari storage
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        'Access-Token': accessToken,
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

  Future<List<QuestionRequestIdPlant>> fetchQuestionrequestplant(String idplant) async {
    final String url = 'https://cemindo-apps.com/api_visitor_induction/question/get-question-plant?id=$idplant';
    //final url = '${dotenv.env['API_URL']}/question/get-question-plant?id=$idplant';
    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {throw Exception('Access token is missing or invalid');}
    try {
      final headers = {
        'Access-Token': accessToken,
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
          return data.map((item) => QuestionRequestIdPlant.fromJson(item)).toList();
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

  Future<bool> createAnswerQuestion(int idrequest, int question_id, int choice_id)
  async {
    final url = 'https://cemindo-apps.com/api_visitor_induction/question/create-answer-question';
    //final url = '${dotenv.env['API_URL']}/question/create-answer-question';
    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      final headers = {'Access-Token': accessToken,'Content-Type': 'application/json',};

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
    final approvalUrl = 'https://cemindo-apps.com/api_visitor_induction/inductionrequest/update-inductionrequest-test/$idrequest';
    //final approvalUrl = '${dotenv.env['API_URL']}/inductionrequest/update-inductionrequest/$idrequest';
    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }
    final Map<String, String> headers = {
       'Access-Token': accessToken,
      'Content-Type': 'application/json',
    };

    final body = json.encode({"status_id": statusId});
    print('Sending approval request: $body');

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
    final approvalUrl = 'https://cemindo-apps.com/api_visitor_induction/requestinduction/update-inductionrequest/$idrequest';
    //final approvalUrl = 'http://10.10.10.72:3001/requestinduction/update-inductionrequest/$idrequest';
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
        return responseBody['message'];  // Return success message
      } else {
        final responseBody = json.decode(response.body);
        print('Failed to approve: ${response.statusCode}, ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? 'Failed to approve induction request');
      }
    } catch (e) {
      print('Error during approval request: $e');
      throw Exception('Network error occurred');
    }
  }


}
