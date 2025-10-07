import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/InductionRequestId.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

class CompletedScreen extends StatefulWidget {
  final String idrequest;

  const CompletedScreen({
    Key? key,
    required this.idrequest,
  }) : super(key: key);

  @override
  _CompletedScreenState createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  late Future<List<InductionRequestId>> _fetchInductionId;
  late Box box;
  String? emailuser;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox');
    String? token = box.get('token');

    // Ambil data pengguna
    setState(() {
      emailuser = box.get('email');
    });

    if (token == null || token.isEmpty) {
      context.go('/login');
    } else {
      // Langsung panggil API — biarkan FutureBuilder yang menangani
      _fetchInductionId =
          ApiService().fetchInductionrequestId(widget.idrequest);
    }
  }

  Widget _buildQRCode(String? qrCodeBase64) {
    if (qrCodeBase64 == null || qrCodeBase64.isEmpty) {
      return const Text('Tidak ada QR Code');
    }

    String cleanBase64 = qrCodeBase64;
    if (qrCodeBase64.startsWith('data:image')) {
      final parts = qrCodeBase64.split(',');
      if (parts.length > 1) {
        cleanBase64 = parts[1];
      } else {
        return const Text('Format QR Code tidak valid');
      }
    }

    try {
      final bytes = base64Decode(cleanBase64);
      return Image.memory(
        bytes,
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return Text('QR Code error: ${e.toString().substring(0, 30)}...');
    }
  }

  String _formatValidDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '—';
    }

    // Coba format ISO 8601 (2025-12-31 atau 2025-12-31T00:00:00)
    try {
      return DateFormat('dd MMMM yyyy').format(DateTime.parse(dateString));
    } catch (e) {
      // Jika gagal, coba format umum lain (opsional)
      // Misal: "31/12/2025"
      try {
        final parsed = DateFormat('dd/MM/yyyy').parseLoose(dateString);
        return DateFormat('dd MMMM yyyy').format(parsed);
      } catch (e2) {
        // Jika semua gagal, tampilkan apa adanya
        return dateString;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go('/request-induction');
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              // 🔑 Pusatkan konten
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600, // Batasi lebar maksimal (responsif)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "SELAMAT!",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Anda telah menyelesaikan Tes Induksi",
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
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: FutureBuilder<List<InductionRequestId>>(
                            future: _fetchInductionId,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Text(
                                    'Data induksi tidak tersedia.');
                              }

                              final induction = snapshot.data!.first;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Kartu Akses Pengunjung",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    induction.plant ?? '—',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildQRCode(induction.qr_code),
                                  const SizedBox(height: 16),
                                  Text(' ${induction.fullName}'),
                                  const SizedBox(height: 24),
                                  const Text('Berlaku Hingga:'),
                                  Text(
                                    // DateFormat('dd MMMM yyyy').format(
                                    //     DateTime.parse(induction.valid)),
                                    _formatValidDate(induction.valid),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Kartu akses Anda juga telah dikirimkan ke",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "email Anda:",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        emailuser ?? '—',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/employee/request-induction');
                        },
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Back to Main Menu'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF07840B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
