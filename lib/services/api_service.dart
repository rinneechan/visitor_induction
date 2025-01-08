import 'dart:convert';
import 'package:hive/hive.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'package:http/http.dart' as http;
import 'package:she_vi/models/InductionMaterial.dart';
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
  Future<bool> loginNik(String username) async {
    final url = 'http://10.10.10.72:3001/loginnik';
    //final url = '${dotenv.env['API_URL']}/loginnik';
    final Map<String, dynamic> data = {
      'nik': username,
    };

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 30)); // Tambahkan timeout 10 detik

      lastResponseStatusCode = response.statusCode;

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
      print('Kesalahan tidak terduga: $e');
      return false;
    }
  }

//login Nik dan Password
  Future<bool> loginNikPass(String username, String password) async {
    final url = 'http://10.10.10.72:3001/loginPass';
    //final url = '${dotenv.env['API_URL']}/loginPass';
    final Map<String, dynamic> data = {
      'nik': username,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      // print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        // Parsing respons dari server
        final responseData = json.decode(response.body);

        if (responseData['data'] != null &&
            responseData['access_token'] != null) {
          // Ambil data dari respons
          String userid = responseData['data'][0]['id'] ?? '';
          String visitorid =
              responseData['data'][0]['visitor_id']?.toString() ?? '';
          String fullName = responseData['data'][0]['name'] ?? '';
          String email = responseData['data'][0]['email'] ?? '';
          String compname = responseData['data'][0]['comp_name'] ?? '';
          String jobposs = responseData['data'][0]['job_position'] ?? '';
          String typeuser = responseData['data'][0]['user_type'] ?? '';
          String token = responseData['access_token'] ?? '';

          // Simpan data ke dalam storage lokal
          await box.put('userid', userid);
          await box.put('visitorid', visitorid);
          await box.put('username', fullName);
          await box.put('email', email);
          await box.put('compname', compname);
          await box.put('jobposs', jobposs);
          await box.put('typeuser', typeuser);
          await box.put('token', token);

          return true;
        } else {
          print('Error: Data or token is missing in the response.');
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
    final url = 'http://10.10.10.72:3001/materials';
    //final url = '${dotenv.env['API_URL']}/materials';
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        'access_token': accessToken,
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
        // Parsing JSON response
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
      print('Error occurred: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<PlantModel>> fetchPlant() async {
    final url = 'http://10.10.10.72:3001/plants';
    //final url = '${dotenv.env['API_URL']}/plants';
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        'access_token': accessToken,
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
    final url = 'http://10.10.10.72:3001/plants/get-dep-plant';
    //final url = '${dotenv.env['API_URL']}/plants/get-dep-plant';
    // Mengambil token dari storage
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        'access_token': accessToken,
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
    String updatedby,) async {
            final url = 'http://10.10.10.72:3001/inductionrequest';
            //final url = '${dotenv.env['API_URL']}/inductionrequest';
            final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      final headers = {
        'access_token': accessToken,
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
    final url = 'http://10.10.10.72:3001/duration';
    //final url = '${dotenv.env['API_URL']}/duration';
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        'access_token': accessToken,
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

  // Future<List<Visit>> fetchVisit() async {
  //   final response = await http.get(Uri.parse(
  //       'https://run.mocky.io/v3/624a6e1d-fb7a-4a42-b260-26adb5642782'));
  //
  //   if (response.statusCode == 200) {
  //     // Parsing JSON response ke list kategori
  //     final List<dynamic> data = jsonDecode(response.body)['data'];
  //     return data.map((item) => Visit.fromJson(item)).toList();
  //   } else {
  //     throw Exception('Failed to load Visit');
  //   }
  // }



  // Future<List<InductionRequestHistory>> fetchInductionrequest(
  //     String visitor) async {
  //   final String url =
  //       'http://10.10.10.72:3001/plants/get-inductionrequest-user';

  //   // Mengambil token dari storage
  //   final String? accessToken = box.get('token');

  //   if (accessToken == null || accessToken.isEmpty) {
  //     throw Exception('Access token is missing or invalid');
  //   }

  //   try {
  //     // Header untuk autentikasi
  //     final headers = {
  //       'access_token': accessToken,
  //       'Content-Type': 'application/json',
  //     };

  //     // Body JSON untuk request
  //     final body = json.encode({
  //       "id": visitor,
  //     });

  //     // Melakukan HTTP POST
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: headers,
  //       body: body,
  //     );

  //     // Menyimpan status kode respons
  //     lastResponseStatusCode = response.statusCode;

  //     if (response.statusCode == 200) {
  //       // Parsing JSON response
  //       final Map<String, dynamic> responseData = json.decode(response.body);
  //       print('fetching Dept: ${responseData['data']}');

  //       // Validasi dan parsing data
  //       if (responseData['data'] != null) {
  //         List<dynamic> data = responseData['data'];
  //         return data
  //             .map((item) => InductionRequestHistory.fromJson(item))
  //             .toList();
  //       } else {
  //         throw Exception('Invalid data format or no data found');
  //       }
  //     } else {
  //       throw Exception('Failed to load data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //     throw Exception('Failed to load data: $e');
  //   }
  // }

  Future<List<InductionRequestHistory>> fetchInductionrequest(String visitor) async {
    final url ='http://10.10.10.72:3001/inductionrequest/get-inductionrequest-user';
    //final url = '${dotenv.env['API_URL']}/inductionrequest/get-inductionrequest-user';
    // Mengambil token dari storage
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        'access_token': accessToken,
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
      // print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        // Parsing JSON response
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
      print('Error occurred: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<InductionRequestProgress>> fetchInductionProgressrequest(String visitor) async {
    final url ='http://10.10.10.72:3001/inductionrequest/get-inductionrequest-user-Progress';
    //final url = '${dotenv.env['API_URL']}/inductionrequest/get-inductionrequest-user-Progress';
    // Mengambil token dari storage
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        'access_token': accessToken,
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
    final url = 'http://10.10.10.72:3001/inductionrequest/get-inductionrequest-id';
    //final url = '${dotenv.env['API_URL']}/inductionrequest/get-inductionrequest-id';

    // Mengambil token dari storage
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      // Header untuk autentikasi
      final headers = {
        'access_token': accessToken,
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
    final url = 'http://10.10.10.72:3001/question/get-question-plant';
    final String? accessToken = box.get('token');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      final headers = {
        'access_token': accessToken,
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        "id": idplant,
      });

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
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



}
