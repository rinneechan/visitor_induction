import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/InductionRequestId.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:intl/intl.dart';


class ComplatedScreen extends StatefulWidget {
  final String idrequest;
  // final String plantId;
  // final String plantName;

  const ComplatedScreen({
    Key? key,
    required this.idrequest,

  }) : super(key: key);

  @override
  _ComplatedScreenState createState() => _ComplatedScreenState();
}

class _ComplatedScreenState extends State<ComplatedScreen> {
  ApiService apiService = ApiService();
  late Future<List<InductionRequestId>> fetchInductionId; // Inisialisasi dengan late
  String? plantNameFromApi;
  String? qrCodeBase64;

  @override
  void initState() {
    super.initState();
    fetchInductionId = _loadData(); // Inisialisasi fetchInductionId
  }

  Future<List<InductionRequestId>> _loadData() async {
    try {
      final String idRequest = widget.idrequest;
      final result = await apiService.fetchInductionrequestId(idRequest);

      if (result.isNotEmpty) {
        // Hapus prefix dari QR Code jika ada
        String? fetchedQRCode = result.first.qr_code;
        if (fetchedQRCode != null && fetchedQRCode.startsWith('data:image')) {
          fetchedQRCode = fetchedQRCode.split(',')[1]; // Hapus "data:image/png;base64,"
        }

        setState(() {
          plantNameFromApi = result.first.plant;
          qrCodeBase64 = fetchedQRCode;
        });
      }

      return result;
    } catch (e) {
      print('Error saat memuat data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigasi menggunakan GoRouter
        context.go('/request-induction');
        return false; // Agar tidak kembali ke halaman sebelumnya
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "CONGRATULATIONS!",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You have finished the induction Test",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          "Visitor Access Pass",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          plantNameFromApi ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        qrCodeBase64 != null
                            ? _buildQRCode(qrCodeBase64!)
                            : const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const SizedBox(height: 24),
                        FutureBuilder<List<InductionRequestId>>(
                          future: fetchInductionId,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text('No data available.');
                            } else {
                              final inductionRequest = snapshot.data!.first;
                              return Column(
                                children: [
                                  Text(' ${inductionRequest.fullName}'),
                                  const SizedBox(height: 24),
                                  const Text('Valid Until:'),
                                  Text(DateFormat('dd MMMM yyyy').format(DateTime.parse(inductionRequest.arrivalDate))),
                                ],
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
        ),
      ),
    );
  }

  Widget _buildQRCode(String qrCode) {
    try {
      return Image.memory(
        base64Decode(qrCode),
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return const Text('Invalid QR Code');
    }
  }
}
