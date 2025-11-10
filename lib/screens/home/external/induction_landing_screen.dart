import 'package:flutter/material.dart';
import 'package:she_vi/utils/env_helper.dart';
import 'package:she_vi/models/InductionMaterial.dart';
import 'package:she_vi/models/induction_request_progress.dart';
import 'package:she_vi/models/document_viewer.dart';
import 'package:she_vi/utils/storage_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InductionLandingScreen extends StatefulWidget {
  const InductionLandingScreen({super.key});

  @override
  State<InductionLandingScreen> createState() => _InductionLandingScreenState();
}

class _InductionLandingScreenState extends State<InductionLandingScreen> {
  late Future<List<InductionRequestProgress>> futureProgress;
  late Future<List<InductionMaterial>> futureMaterials;
  final box = StorageHelper.box;

  @override
  void initState() {
    super.initState();
    final visitorId = box.get('id') ?? '';
    futureProgress = fetchInductionProgressrequest(visitorId);
    futureMaterials = fetchInductionMaterials(visitorId);
  }

  Future<List<InductionRequestProgress>> fetchInductionProgressrequest(
      String visitor) async {
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    final String url =
        '$apiUrl/inductionrequest/get-inductionrequest-user-Progress';

    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      final headers = {
        accessHeaderKey: accessToken,
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        "id": visitor,
      });

      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
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

  Future<List<InductionMaterial>> fetchInductionMaterials(String visitor) async {
    final String apiUrl = EnvHelper.get('API_URL');
    final String accessHeaderKey = EnvHelper.get('API_HEADERS');
    final String url = '$apiUrl/inductionmaterial/get-material-user';

    final String? accessToken = box.get('token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token is missing or invalid');
    }

    try {
      final headers = {
        accessHeaderKey: accessToken,
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        "id": visitor,
      });

      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          List<dynamic> data = responseData['data'];
          return data.map((item) => InductionMaterial.fromJson(item)).toList();
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

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1:
        return const Color(0xFF2196F3); // Blue
      case 2:
        return const Color(0xFFFFA000); // Amber
      case 3:
        return const Color(0xFF4CAF50); // Green
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visitor Induction',
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontWeight: FontWeight.w700,
            color: Color(0xFF343434),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF343434)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ===== ON PROGRESS CARD =====
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/akar_icons_history.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'On Progress',
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<InductionRequestProgress>>(
                      future: futureProgress,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center();
                        } else if (snapshot.hasError) {
                          return const Center(child: Text(''));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text("No data available"));
                        } else {
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final progresson = snapshot.data![index];
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 143, 140, 140),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            progresson.plant,
                                            style: const TextStyle(
                                              fontFamily: 'Hanken Grotesk',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF343434),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            progresson.department,
                                            style: const TextStyle(
                                              fontFamily: 'Hanken Grotesk',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF757575),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                progresson.arrivalDate,
                                                style: const TextStyle(
                                                  fontFamily: 'Hanken Grotesk',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF757575),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              const Text('-'),
                                              const SizedBox(width: 5),
                                              Text(
                                                progresson.visitDuration,
                                                style: const TextStyle(
                                                  fontFamily: 'Hanken Grotesk',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF757575),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          progresson.status,
                                          style: TextStyle(
                                            fontFamily: 'Hanken Grotesk',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _getStatusColor(
                                                progresson.statusId),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // ===== SHE TRAINING MODULE CARD =====
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/Induction_Material.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'SHE Training Module',
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<InductionMaterial>>(
                      future: futureMaterials,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center();
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text("No data available"));
                        } else {
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final material = snapshot.data![index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DocumentViewer(
                                        idmateri:
                                            material.idMateri.toString(),
                                        namaFile: material.namaMateri,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 143, 140, 140),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          material.namaMateri,
                                          style: const TextStyle(
                                            fontFamily: 'Hanken Grotesk',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF343434),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Download',
                                        style: TextStyle(
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF343434),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
