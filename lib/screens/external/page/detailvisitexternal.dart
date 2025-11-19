// lib/screens/external/page/detail_visit_external.dart (atau path Anda)
import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service_external.dart'; // Ganti import
import 'package:she_vi/models/InductionRequestIdExternal.dart'; // Ganti import
// import 'package:hive/hive.dart'; // Tidak digunakan lagi untuk profil
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class DetailVisitExternal extends StatefulWidget {
  final String idrequest; // Parameter yang digunakan untuk API
  const DetailVisitExternal({super.key, required this.idrequest});

  @override
  _DetailVisitExternalState createState() => _DetailVisitExternalState();
}

class _DetailVisitExternalState extends State<DetailVisitExternal> {
  late Future<InductionRequestIdExternal?> _fetchInductionId; // Ganti Future type

  // Hapus instance ApiServiceExternal
  // final ApiServiceExternal _apiService = ApiServiceExternal();

  @override
  void initState() {
    super.initState();
    // Panggil API external secara langsung, seperti Detaiinfoexternal
    _fetchInductionId = ApiServiceExternal.fetchInductionRequestByIdExternal(widget.idrequest);
  }

  // Tidak perlu _loadUserDataFromHive lagi
  // Future<void> _loadUserDataFromHive() async { ... }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      debugPrint("Error formatting date: $dateString, Error: $e"); // Debug print opsional
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Info'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF343434),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // Kembali ke halaman sebelumnya
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<InductionRequestIdExternal?>(
          future: _fetchInductionId, // Gunakan Future yang diinisialisasi di initState
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _buildError('Gagal memuat  ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return _buildError('Data tidak ditemukan');
            }

            final detail = snapshot.data!;
            // Ambil item dari data[0] dan profil
            final item = detail.data.isNotEmpty ? detail.data[0] : null;
            final profil = detail.profil;

            if (item == null) {
              return _buildError('Detail induksi tidak ditemukan');
            }

            if (profil == null) {
              return _buildError('Data profil tidak ditemukan');
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard(
                        title: 'Induction Request',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gunakan field dari item (InductionRequestData)
                            _buildInfoRow(Icons.person_outline, 'Full Name',
                                item.fullName), // Ambil dari data[0]
                            _buildInfoRow(Icons.check_circle_outline, 'Status',
                                item.statusName), // Ambil dari data[0]
                            _buildInfoRow(Icons.location_on_outlined,
                                'Plant Name', item.plantName), // Ambil dari data[0]
                            _buildInfoRow(Icons.business,
                                'Department Destination', item.departmentName), // Ambil dari data[0]
                            _buildInfoRow(
                                Icons.person, 'PIC Name', item.picName), // Ambil dari data[0]
                            _buildInfoRow(Icons.calendar_today_outlined,
                                'Arrival Date', _formatDate(item.arrivalDate)), // Ambil dari data[0]
                            _buildInfoRow(Icons.access_time_outlined,
                                'Visit Duration', item.passType), // Ambil dari data[0]
                            _buildInfoRow(Icons.description_outlined,
                                'Reason to Visit', item.reasonToVisit), // Ambil dari data[0]
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionCard(
                        title: 'Visitor Profile',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gunakan field dari profil
                            _buildInfoRow(
                                Icons.person, 'Full Name', profil.fullName), // Ambil dari profil
                            _buildInfoRow(Icons.business, 'Company Name',
                                profil.companyName), // Ambil dari profil
                            _buildInfoRow(Icons.work_outline, 'Job Position',
                                profil.jobPosition), // Ambil dari profil
                            // Tambahkan email dan nohp dari profil jika diperlukan
                            _buildInfoRow(Icons.email_outlined, 'Work Email',
                                profil.workEmail), // Ambil dari profil
                            _buildInfoRow(Icons.phone_outlined, 'Phone Number',
                                profil.nohp), // Ambil dari profil
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
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

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      ),
    );
  }
}