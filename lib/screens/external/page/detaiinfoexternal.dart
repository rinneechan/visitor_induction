import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class Detaiinfoexternal extends StatefulWidget {
  // Tambahkan parameter ke konstruktor
  final String idprogress;
  final String? idrequest;
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
  // Hapus variabel lokal untuk data yang diterima dari konstruktor
  // String? idrequest;
  // String? username;
  // String? compname;
  // String? jobposs;

  // Data dummy untuk detail induksi
  late Map<String, String> _dummyInductionData;

  @override
  void initState() {
    super.initState();
    // Gunakan data dari widget
    // setState(() {
    //   idrequest = widget.idrequest;
    //   username = widget.username;
    //   compname = widget.compname;
    //   jobposs = widget.jobposs;
    // });

    // Set data dummy berdasarkan idrequest dari widget
    _dummyInductionData = _getDummyDataForId(widget.idprogress);
  }

  // Fungsi untuk mendapatkan data dummy berdasarkan ID
  Map<String, String> _getDummyDataForId(String id) {
    // Contoh data dummy
    switch (id) {
      case '102':
        return {
          'status': 'Induction Test',
          'plantName': 'Pabrik Hijau Laut',
          'department': 'R&D',
          'picName': 'Ani Lestari',
          'arrivalDate': '2025-11-22',
          'visitDuration': '1 Hari',
          'reasonToVisit': 'Audit Lingkungan',
        };
      case '103':
        return {
          'status': 'Active',
          'plantName': 'Pabrik Biru Langit',
          'department': 'Logistik',
          'picName': 'Sigit Prabowo',
          'arrivalDate': '2025-11-25',
          'visitDuration': '3 Hari',
          'reasonToVisit': 'Pengiriman Barang',
        };
      default:
        return {
          'status': 'Unknown',
          'plantName': 'N/A',
          'department': 'N/A',
          'picName': 'N/A',
          'arrivalDate': 'N/A',
          'visitDuration': 'N/A',
          'reasonToVisit': 'N/A',
        };
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/'); // Atau default ke home jika tidak ada tempat lain
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Bagian konten yang bisa di-scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionCard(
                          title: 'Induction Request',
                          // Ganti FutureBuilder dengan data dummy
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(Icons.check_circle_outline, 'Status', _dummyInductionData['status'] ?? 'N/A'),
                              _buildInfoRow(Icons.location_on_outlined, 'Plant Name', _dummyInductionData['plantName'] ?? 'N/A'),
                              _buildInfoRow(Icons.business, 'Department Destination', _dummyInductionData['department'] ?? 'N/A'),
                              _buildInfoRow(Icons.person_outline, 'PIC Name', _dummyInductionData['picName'] ?? 'N/A'),
                              _buildInfoRow(Icons.calendar_today_outlined, 'Arrival Date', _formatDate(_dummyInductionData['arrivalDate'] ?? 'N/A')),
                              _buildInfoRow(Icons.access_time_outlined, 'Visit Duration', _dummyInductionData['visitDuration'] ?? 'N/A'),
                              _buildInfoRow(Icons.description_outlined, 'Reason to Visit', _dummyInductionData['reasonToVisit'] ?? 'N/A'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSectionCard(
                          title: 'Visitor Profile',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(Icons.person, 'Full Name', widget.idrequest ?? '-'), // Gunakan widget.username
                              _buildInfoRow(Icons.business, 'Company Name', widget.compname ?? '-'), // Gunakan widget.compname
                              _buildInfoRow(Icons.work_outline, 'Job Position', widget.jobposs ?? '-'), // Gunakan widget.jobposs
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Jarak kecil di atas tombol
            const SizedBox(height: 12),
            // Tombol tetap di bawah, lebar selaras
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: _buildBottomButton(),
                ),
              ),
            ),
            const SizedBox(height: 12), // jarak bawah opsional
          ],
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

  Widget _buildBottomButton() {
    // Tombol bisa disesuaikan fungsinya saat backend diaktifkan kembali
    return SizedBox(
      child: ElevatedButton.icon(
        onPressed: () {
          // Fungsi untuk memulai induksi (akan diaktifkan saat backend siap)
          debugPrint('Mulai induksi untuk request ID: ${widget.idprogress}'); // Gunakan widget.idrequest
          // Contoh: context.push('/induction/welcome-test?id=${widget.idrequest}');
        },
        icon: const Icon(Icons.play_arrow, size: 18),
        label: const Text('Start Induction', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF07840B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size.fromHeight(56),
          visualDensity: VisualDensity.standard,
        ),
      ),
    );
  }
}