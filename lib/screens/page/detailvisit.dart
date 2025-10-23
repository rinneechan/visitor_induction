import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/InductionRequestHistory.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class DetailVisit extends StatefulWidget {
  final String idrequest;
  const DetailVisit({super.key, required this.idrequest});

  @override
  _DetailVisitState createState() => _DetailVisitState();
}

class _DetailVisitState extends State<DetailVisit> {
  String? username;
  String? compname;
  String? jobposs;
  late Future<List<InductionRequestHistory>> _fetchInductionId;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUserDataFromHive();
    _fetchInductionId = _apiService.fetchInductionrequestScan(widget.idrequest);
  }

  Future<void> _loadUserDataFromHive() async {
    final box = await Hive.openBox('userBox');
    if (!mounted) return;
    setState(() {
      username = box.get('username') ?? '-';
      compname = box.get('compname') ?? '-';
      jobposs = box.get('jobposs') ?? '-';
    });
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
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => context.pop(),
        // ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<InductionRequestHistory>>(
          future: _fetchInductionId,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _buildError('Gagal memuat data: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildError('Data tidak ditemukan');
            }

            final data = snapshot.data!.first;

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
                            _buildInfoRow(Icons.person_outline, 'Full Name',
                                data.fullName),
                            _buildInfoRow(Icons.check_circle_outline, 'Status',
                                data.statusname),
                            _buildInfoRow(Icons.location_on_outlined,
                                'Plant Name', data.plantName),
                            _buildInfoRow(Icons.business,
                                'Department Destination', data.department),
                            _buildInfoRow(
                                Icons.person, 'PIC Name', data.picName),
                            _buildInfoRow(Icons.calendar_today_outlined,
                                'Arrival Date', _formatDate(data.arrivalDate)),
                            _buildInfoRow(Icons.access_time_outlined,
                                'Visit Duration', data.visitDuration),
                            _buildInfoRow(Icons.description_outlined,
                                'Reason to Visit', data.reasonToVisit),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionCard(
                        title: 'Visitor Profile',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                                Icons.person, 'Full Name', username ?? '-'),
                            _buildInfoRow(Icons.business, 'Company Name',
                                compname ?? '-'),
                            _buildInfoRow(Icons.work_outline, 'Job Position',
                                jobposs ?? '-'),
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
