// lib/screens/external/page/completedscreenexternal.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/services/api_service_external.dart';
import 'package:she_vi/models/InductionRequestIdExternal.dart';
// Tambahkan import ini untuk base64Decode
import 'dart:convert'; 
// ... import lainnya ...

class CompletedScreenExsternal extends StatefulWidget {
  final String idprogress;
  final String? idrequest;

  // const CompletedScreenExsternal({
  //   Key? key, // Tambahkan Key? jika diperlukan
  //   required this.idrequest, // Gunakan idrequest
  // }) : super(key: key);
  const CompletedScreenExsternal({
    super.key,
    required this.idprogress,
    this.idrequest,
    
  });

  @override
  _CompletedScreenState createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreenExsternal> {
  // Ubah nama Future dan tipe
  late Future<InductionRequestIdExternal?> _fetchInductionId;

  // Hapus instance ApiServiceExternal
  // final ApiServiceExternal _apiService = ApiServiceExternal();

  @override
  void initState() {
    super.initState();

    // Gunakan ApiServiceExternal secara langsung, seperti Detaiinfoexternal
    _fetchInductionId = ApiServiceExternal.fetchInductionRequestByIdExternal(
      widget.idprogress, // Gunakan idrequest
    );
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
        // Ganti navigasi back jika perlu
        // context.go('/request-induction'); // Ini untuk internal
        //context.go('/exsternal/history'); // Contoh: kembali ke history external
        context.pop();
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
                          // Ganti FutureBuilder
                          child: FutureBuilder<InductionRequestIdExternal?>(
                            future: _fetchInductionId, // Gunakan Future yang benar
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData ||
                                  snapshot.data == null) { // Periksa null
                                return const Text(
                                    'Data induksi tidak tersedia.');
                              }

                              final detail = snapshot.data!; // Ambil data JSON penuh
                              final induction = detail.data.isNotEmpty ? detail.data[0] : null; // Ambil item dari data[0]
                              final profil = detail.profil; // Ambil profil

                              if (induction == null) {
                                return const Text('Detail induksi tidak ditemukan.');
                              }

                              // Ambil email dari profil
                              final emailFromProfil = profil?.workEmail ?? '—';

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
                                  // Gunakan field dari model baru
                                  Text(
                                    induction.plantName ?? '—', // Gunakan field dari model baru
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 16),
                                  // Gunakan field dari model baru
                                  _buildQRCode(induction.qrCode), // Gunakan field dari model baru
                                  const SizedBox(height: 16),
                                  // Gunakan field dari model baru
                                  Text(' ${induction.fullName}'), // Gunakan field dari model baru
                                  const SizedBox(height: 24),
                                  const Text('Berlaku Hingga:'),
                                  // Gunakan field dari model baru
                                  Text(
                                    _formatValidDate(induction.validUntil), // Gunakan field dari model baru
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
                      // Gunakan email dari profil API
                      FutureBuilder<InductionRequestIdExternal?>(
                        future: _fetchInductionId, // Gunakan Future yang sama
                        builder: (context, emailSnapshot) {
                           if (emailSnapshot.connectionState == ConnectionState.waiting) {
                              return const Text('—'); // Placeholder
                           }
                           if (emailSnapshot.hasError) {
                             return Text('Email Error: ${emailSnapshot.error}');
                           }
                           if (!emailSnapshot.hasData || emailSnapshot.data == null) {
                             return const Text('—');
                           }
                           final emailDetail = emailSnapshot.data!;
                           final emailFromProfil = emailDetail.profil?.workEmail ?? '—';
                           return Text(
                             emailFromProfil, // Ambil dari profil
                             style: const TextStyle(fontSize: 16),
                             textAlign: TextAlign.center,
                           );
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Ganti navigasi back jika perlu
                          // context.go('/employee/request-induction'); // Ini untuk internal
                          //context.go('/exsternal/history'); // Contoh: kembali ke history external
                          context.pop();
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