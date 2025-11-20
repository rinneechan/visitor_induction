// lib/screens/external/page/detaiinfoexternal.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/services/api_service_external.dart';
import 'package:she_vi/models/InductionRequestIdExternal.dart';

class Detaiinfoexternal extends StatefulWidget {
  final String idprogress;
  final String? idrequest; // Parameter yang digunakan untuk API
  final String? compname;
  final String? jobposs;

  const Detaiinfoexternal({
    super.key,
    required this.idprogress,
    this.idrequest,
    this.compname,
    this.jobposs,
  });

  @override
  _DetaiinfoexternalState createState() => _DetaiinfoexternalState();
}

class _DetaiinfoexternalState extends State<Detaiinfoexternal> {
  late Future<InductionRequestIdExternal?> _detailFuture;

  @override
  void initState() {
    super.initState();

    // Debug: Cetak nilai idprogress yang digunakan untuk API
    debugPrint("Detaiinfoexternal: Menerima idprogress = '${widget.idprogress}'");
    debugPrint("Detaiinfoexternal: Menerima idrequest = '${widget.idrequest}'");

    // Gunakan widget.idprogress untuk mengambil data dari API
    _detailFuture = ApiServiceExternal.fetchInductionRequestByIdExternal(
      widget.idprogress,
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "-";
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      debugPrint("Error formatting date: $dateString, Error: $e");
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Info'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF343434),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<InductionRequestIdExternal?>(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              // Debug: Cetak error secara lengkap
              debugPrint("Detaiinfoexternal: Error dari Future = ${snapshot.error}");
              // Jika error adalah instance dari Exception yang kita lempar, tampilkan pesan spesifik
              String errorMessage = "An error occurred.";
              if (snapshot.error is String) {
                 errorMessage = snapshot.error as String;
              } else if (snapshot.error is Exception) {
                 errorMessage = (snapshot.error as Exception).toString();
              }
              return Center(
                child: Text(
                  'Error: $errorMessage',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("No data found"));
            }

            final detail = snapshot.data!;

            return _buildDetailContent(detail);
          },
        ),
      ),
    );
  }

  Widget _buildDetailContent(InductionRequestIdExternal detail) {
    // Ambil item pertama dari data list
    final item = detail.data.isNotEmpty ? detail.data[0] : null;
    final profil = detail.profil;

    if (item == null) {
      return const Center(child: Text("No detail data found"));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// SECTION 1 - INDUCTION REQUEST
                    _buildSectionCard(
                      title: 'Induction Request',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(Icons.check_circle_outline,
                              'Status', item.statusName),
                          _buildInfoRow(Icons.location_on_outlined,
                              'Plant Name', item.plantName),
                          _buildInfoRow(Icons.business,
                              'Department Destination', item.departmentName),
                          _buildInfoRow(Icons.person_outline,
                              'PIC Name', item.picName),
                          _buildInfoRow(Icons.calendar_today_outlined,
                              'Arrival Date', _formatDate(item.arrivalDate)),
                          _buildInfoRow(Icons.access_time_outlined,
                              'Visit Duration', item.passType),
                          _buildInfoRow(Icons.description_outlined,
                              'Reason to Visit', item.reasonToVisit),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// SECTION 2 - VISITOR PROFILE
                    _buildSectionCard(
                      title: 'Visitor Profile',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(Icons.person, 'Full Name',
                              profil?.fullName ?? '-'),
                          _buildInfoRow(Icons.business, 'Company Name',
                              profil?.companyName ?? '-'),
                          _buildInfoRow(Icons.work_outline, 'Job Position',
                              profil?.jobPosition ?? '-'),
                              _buildInfoRow(Icons.email_outlined, 'Work Email',
                                  profil?.workEmail ?? '-'),
                              // Tambahkan baris ini untuk menampilkan nomor HP
                              _buildInfoRow(Icons.phone_outlined, 'Phone Number',
                                  profil?.nohp ?? '-'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: _buildBottomButton(item),
            ),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF343434),
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF343434),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(InductionRequestData item) {
    return ElevatedButton.icon(
      onPressed: () {
        context.push(
          '/external/welcome-test-satu',
          extra: {
            "idrequest": item.id,
            "plantId": item.plantId,
            "plantName": item.plantName,
            "urlakses": widget.idrequest,
          },
        );

        debugPrint("➡ Navigasi ke Welcome Test Satu External");
        debugPrint("ID REQUEST: ${item.id}");
        debugPrint("Plant ID: ${item.plantId}");
        debugPrint("Plant Name: ${item.plantName}");
      },
      icon: const Icon(Icons.play_arrow, size: 18),
      label: const Text(
        'Start Induction',
        style: TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF07840B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size.fromHeight(56),
      ),
    );
  }
}