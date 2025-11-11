import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/InductionRequestId.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class TestComplatedScreen extends StatefulWidget {
  final String idrequest;
  final String plantId;
  final String plantName;

  const TestComplatedScreen({
    super.key,
    required this.idrequest,
    required this.plantId,
    required this.plantName,
  });

  @override
  _TestComplatedScreenState createState() => _TestComplatedScreenState();
}

class _TestComplatedScreenState extends State<TestComplatedScreen> {
  ApiService apiService = ApiService();
  late Future<List<InductionRequestId>> fetchInductionId;
  String? plantNameFromApi;
  String? qrCodeBase64;

  @override
  void initState() {
    super.initState();
    fetchInductionId = _loadData();
    _updateStatus();
  }

  Future<List<InductionRequestId>> _loadData() async {
    try {
      final String idRequest = widget.idrequest;
      final result = await apiService.fetchInductionrequestId(idRequest);

      if (result.isNotEmpty) {
        String? fetchedQRCode = result.first.qr_code;
        if (fetchedQRCode != null && fetchedQRCode.startsWith('data:image')) {
          fetchedQRCode = fetchedQRCode.split(',')[1];
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

  Future<void> _updateStatus() async {
    try {
      await apiService.updateRequestVisitor(int.parse(widget.idrequest), 3);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Status updated successfully")),
        );
        setState(() {
          fetchInductionId = _loadData();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update status: $e")),
        );
      }
    }
  }

  /// Navigasi balik ke halaman menu utama
  void _goToMainMenu() {
    context.go('/employee/request-induction');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goToMainMenu(); // Jika user klik tombol back (browser / Android)
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
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
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "You have finished the induction Test",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // === CARD QR CODE + BUTTON ===
                          LayoutBuilder(
                            builder: (context, boxConstraints) {
                              // Gunakan lebar Card untuk menentukan lebar tombol
                              final double cardWidth =
                                  MediaQuery.of(context).size.width -
                                      64; // padding 16 kiri + kanan x2

                              return Column(
                                children: [
                                  Card(
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
                                            plantNameFromApi ??
                                                widget.plantName,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 16),
                                          qrCodeBase64 != null
                                              ? _buildQRCode(qrCodeBase64!)
                                              : const CircularProgressIndicator(),
                                          const SizedBox(height: 24),
                                          FutureBuilder<
                                              List<InductionRequestId>>(
                                            future: fetchInductionId,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator();
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    'Error: ${snapshot.error}');
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return const Text(
                                                    'No data available.');
                                              } else {
                                                final inductionRequest =
                                                    snapshot.data!.first;
                                                return Column(
                                                  children: [
                                                    Text(
                                                      inductionRequest.fullName,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    const Text(
                                                      'Valid Until:',
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    Text(
                                                      DateFormat('dd MMMM yyyy')
                                                          .format(
                                                        DateTime.parse(
                                                            inductionRequest
                                                                .arrivalDate),
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // === BUTTON BACK TO MENU ===
                                  const SizedBox(height: 24),
                                  Align(
                                    alignment: Alignment.center,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: cardWidth, // sama dengan Card
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: _goToMainMenu,
                                        icon: const Icon(Icons.arrow_back),
                                        label: const Text(
                                          "Back to Main Menu",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
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
