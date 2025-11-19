// lib/screens/external/page/detail_history_external.dart
import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service_external.dart';
import 'package:she_vi/models/InductionRequestIdExternal.dart'; // Model lama
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class DetailHistoryExternal extends StatefulWidget {
  final String idrequest; // Parameter yang digunakan untuk API
  const DetailHistoryExternal({super.key, required this.idrequest});

  @override
  _DetailHistoryExternalState createState() => _DetailHistoryExternalState();
}

class _DetailHistoryExternalState extends State<DetailHistoryExternal> {
  final ApiServiceExternal _apiService = ApiServiceExternal();
  // Ubah Future type menjadi InductionRequestIdExternal? karena model lama mengharapkan data[0]
  late Future<InductionRequestIdExternal?> _fetchInductionId;

  @override
  void initState() {
    super.initState();
    // Panggil API dengan widget.idrequest dan proses respons agar sesuai model lama
    _fetchInductionId = _apiService.fetchInductionRequestByIdExternal(widget.idrequest);
  }

  String _formatDate(String dateString) {
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
        foregroundColor: const Color(0xFF343434),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: FutureBuilder<InductionRequestIdExternal?>(
                  future: _fetchInductionId,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      debugPrint("DetailHistoryExternal: Error = ${snapshot.error}");
                      return _errorMessage('Gagal memuat data: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return _errorMessage('Data tidak ditemukan');
                    }

                    final item = snapshot.data!; // item sekarang adalah InductionRequestIdExternal (model lama)

                    // Karena model lama mungkin tidak memiliki Profil terpisah,
                    // kita asumsikan field profil ada di objek 'item' itu sendiri
                    // Sesuaikan nama field sesuai dengan model lama InductionRequestIdExternal
                    // Contoh: fullName, companyName, jobPosition
                    // Jika model lama tidak menyertakan email/nohp, maka tidak bisa ditampilkan di sini
                    // Kita gunakan field yang sesuai dengan data[0] dari API sebelumnya

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionCard(
                          title: 'Induction Request',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gunakan field dari model lama (InductionRequestIdExternal)
                              // Sesuaikan nama field dengan model lama Anda
                              _buildInfoRow(Icons.check_circle_outline, 'Status', item.statusName),
                              _buildInfoRow(Icons.location_on_outlined, 'Plant Name', item.plantName),
                              _buildInfoRow(Icons.business, 'Department Destination', item.departmentName),
                              _buildInfoRow(Icons.person_outline, 'PIC Name', item.picName),
                              _buildInfoRow(Icons.calendar_today_outlined, 'Arrival Date', _formatDate(item.arrivalDate)),
                              _buildInfoRow(Icons.access_time_outlined, 'Visit Duration', item.passType),
                              _buildInfoRow(Icons.description_outlined, 'Reason to Visit', item.reasonToVisit),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSectionCard(
                          title: 'Visitor Profile',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gunakan field dari model lama (InductionRequestIdExternal)
                              // Sesuaikan nama field dengan model lama Anda
                              _buildInfoRow(Icons.person, 'Full Name', item.fullName),
                              _buildInfoRow(Icons.business, 'Company Name', item.companyName), // Asumsi field ini ada
                              _buildInfoRow(Icons.work_outline, 'Job Position', item.jobPosition), // Asumsi field ini ada
                              // Jika model lama tidak memiliki field ini, hilangkan
                              // _buildInfoRow(Icons.email_outlined, 'Work Email', item.workEmail),
                              // _buildInfoRow(Icons.phone_outlined, 'Phone Number', item.nohp),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildStartButton(item), // Kirim item ke tombol
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
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

  Widget _errorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 14),
      ),
    );
  }

  Widget _buildStartButton(InductionRequestIdExternal item) { // Terima item model lama
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Gunakan field dari model lama
          context.push('/external/welcome-test-satu', extra: {
            "idrequest": item.id, // Sesuaikan dengan field ID di model lama
            "plantId": item.plantId, // Sesuaikan
            "plantName": item.plantName, // Sesuaikan
          });
        },
        icon: const Icon(Icons.play_arrow, size: 18),
        label: const Text('Start Induction', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF07840B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}