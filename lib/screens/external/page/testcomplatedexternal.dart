// lib/screens/external/page/test_complated_screen_external.dart
import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service_external.dart';
import 'package:she_vi/models/InductionRequestIdExternal.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class TestComplatedScreenExternal extends StatefulWidget {
  final String idrequest;
  final String plantId;
  final String plantName;
  final String urlakses;

  const TestComplatedScreenExternal({
    super.key,
    required this.idrequest,
    required this.plantId,
    required this.plantName,
    required this.urlakses,
  });

  @override
  _TestComplatedScreenExternalState createState() => _TestComplatedScreenExternalState();
}

class _TestComplatedScreenExternalState extends State<TestComplatedScreenExternal> {
  // Ganti ApiService ke instance jika diperlukan, tapi biasanya static method cukup
  // ApiServiceExternal apiService = ApiServiceExternal(); // Tidak perlu jika semua method static

  // ✅ SAMAKAN DENGAN Detaiinfoexternal:
  // Gunakan Future<InductionRequestIdExternal?> dan panggil ApiService secara langsung
  late Future<InductionRequestIdExternal?> _fetchInductionId;

  // Tetap gunakan Future<bool> untuk update status
  late Future<bool> _updateStatusFuture;

  @override
  void initState() {
    super.initState();

    // ✅ LANGSUNG PANGGIL API SEPERTI DETAIINFOEXTERNAL
    _fetchInductionId = ApiServiceExternal.fetchInductionRequestByIdExternal(widget.idrequest);

    // Panggil update status
    _updateStatusFuture = _updateStatus();
  }

  // ❌ HAPUS fungsi _loadData karena tidak digunakan lagi
  // Future<InductionRequestIdExternal?> _loadData() async { ... }

  Future<bool> _updateStatus() async {
    try {
      // Panggil API update external
      final success = await ApiServiceExternal.updateInductionRequestTestExternal(
          widget.idrequest, 3); // Status ID 3

      if (success && mounted) {
        debugPrint("Status updated successfully for idrequest: ${widget.idrequest}");
      } else if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update status.")),
        );
      }
      return success;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update status: $e")),
        );
      }
      return false;
    }
  }

  /// Navigasi balik ke halaman menu utama eksternal
  //void _goToMainMenu() {
    //context.go('/main-menu-ext'); // Atau '/exsternal/history' jika lebih sesuai
  //}
  void _goToMainMenu() {
    // Gabungkan parameter ke dalam path sebagai query string
    String targetPath = '/exsternal/request-induction?idrequest=${Uri.encodeComponent(widget.urlakses)}';
    context.push(targetPath); // atau context.go(targetPath);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goToMainMenu();
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
                              final double cardWidth =
                                  MediaQuery.of(context).size.width - 64;

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
                                          // Ambil plantName dari API atau widget
                                          FutureBuilder<InductionRequestIdExternal?>(
                                           future: _fetchInductionId, // ✅ GUNAKAN FUTURE YANG SAMA
                                           builder: (context, snapshot) {
                                             if (snapshot.connectionState == ConnectionState.waiting) {
                                               return const CircularProgressIndicator();
                                             } else if (snapshot.hasError) {
                                               return Text('Error: ${snapshot.error}');
                                             } else if (!snapshot.hasData || snapshot.data == null) {
                                               return const Text('No data available.');
                                             }

                                             final detail = snapshot.data!;
                                             final item = detail.data.isNotEmpty ? detail.data[0] : null;

                                             if (item == null) {
                                               return const Text('Detail induksi tidak ditemukan.');
                                             }

                                             return Text(
                                               item.plantName ?? widget.plantName,
                                               style: const TextStyle(fontSize: 16),
                                             );
                                           },
                                          ),
                                          const SizedBox(height: 16),
                                          // Ambil QR Code dari API
                                          FutureBuilder<InductionRequestIdExternal?>(
                                           future: _fetchInductionId, // ✅ GUNAKAN FUTURE YANG SAMA
                                           builder: (context, snapshot) {
                                             if (snapshot.connectionState == ConnectionState.waiting) {
                                               return const CircularProgressIndicator();
                                             } else if (snapshot.hasError) {
                                               return Text('Error: ${snapshot.error}');
                                             } else if (!snapshot.hasData || snapshot.data == null) {
                                               return const Text('No data available.');
                                             }

                                             final detail = snapshot.data!;
                                             final item = detail.data.isNotEmpty ? detail.data[0] : null;

                                             if (item == null) {
                                               return const Text('Detail induksi tidak ditemukan.');
                                             }

                                             String? qrCodeBase64 = item.qrCode;
                                             if (qrCodeBase64 != null && qrCodeBase64.startsWith('data:image')) {
                                               qrCodeBase64 = qrCodeBase64.split(',')[1];
                                             }

                                             return qrCodeBase64 != null
                                                 ? _buildQRCode(qrCodeBase64)
                                                 : const Text('QR Code not available');
                                           },
                                          ),
                                          const SizedBox(height: 24),
                                          // Ambil FullName, Arrival Date dari API
                                          FutureBuilder<InductionRequestIdExternal?>(
                                           future: _fetchInductionId, // ✅ GUNAKAN FUTURE YANG SAMA
                                           builder: (context, snapshot) {
                                             if (snapshot.connectionState == ConnectionState.waiting) {
                                               return const CircularProgressIndicator();
                                             } else if (snapshot.hasError) {
                                               return Text('Error: ${snapshot.error}');
                                             } else if (!snapshot.hasData || snapshot.data == null) {
                                               return const Text('No data available.');
                                             }

                                             final detail = snapshot.data!;
                                             final item = detail.data.isNotEmpty ? detail.data[0] : null;
                                             final profil = detail.profil;

                                             if (item == null) {
                                               return const Text('Detail induksi tidak ditemukan.');
                                             }

                                             if (profil == null) {
                                               return const Text('Data profil tidak ditemukan.');
                                             }

                                             return Column(
                                               children: [
                                                 Text(
                                                   profil.fullName,
                                                   style: const TextStyle(
                                                     fontSize: 16,
                                                     fontWeight: FontWeight.w600,
                                                   ),
                                                 ),
                                                 const SizedBox(height: 16),
                                                 const Text(
                                                   'Valid Until:',
                                                   style: TextStyle(fontSize: 14),
                                                 ),
                                                 Text(
                                                   DateFormat('dd MMMM yyyy').format(DateTime.parse(item.arrivalDate)),
                                                   style: const TextStyle(
                                                     fontSize: 15,
                                                     fontWeight: FontWeight.bold,
                                                   ),
                                                 ),
                                               ],
                                             );
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
                                      constraints: BoxConstraints(maxWidth: cardWidth),
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
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      debugPrint("Error decoding QR code: $e");
      return const Text('Invalid QR Code');
    }
  }
}