import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/InductionRequestId.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class DetailHistory extends StatefulWidget {
  final String idrequest;
  const DetailHistory({super.key, required this.idrequest});

  @override
  _DetailHistoryState createState() => _DetailHistoryState();
}

class _DetailHistoryState extends State<DetailHistory> {
  late Box box;
  String? username;
  String? compname;
  String? jobposs;
  InductionRequestId? datashow;

  final ApiService _apiService = ApiService();
  late Future<List<InductionRequestId>> _fetchInductionId;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox');
    final token = box.get('token');

    setState(() {
      username = box.get('username');
      compname = box.get('compname');
      jobposs = box.get('jobposs');
    });

    if (token == null || token.isEmpty) {
      context.go('/choose-access');
    } else {
      _fetchInductionId = _apiService.fetchInductionrequestId(widget.idrequest);
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
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            // 🔑 Pusatkan konten
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 600), // Sesuai CompletedScreen
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionCard(
                      title: 'Induction Request',
                      child: FutureBuilder<List<InductionRequestId>>(
                        future: _fetchInductionId,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return _errorMessage(
                                'Gagal memuat data: ${snapshot.error}');
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return _errorMessage('Data tidak ditemukan');
                          }

                          final data = snapshot.data!.first;
                          datashow = data;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(Icons.check_circle_outline,
                                  'Status', data.status),
                              _buildInfoRow(Icons.location_on_outlined,
                                  'Plant Name', data.plantName),
                              _buildInfoRow(Icons.business,
                                  'Department Destination', data.department),
                              _buildInfoRow(Icons.person_outline, 'PIC Name',
                                  data.picName),
                              _buildInfoRow(
                                  Icons.calendar_today_outlined,
                                  'Arrival Date',
                                  _formatDate(data.arrivalDate)),
                              _buildInfoRow(Icons.access_time_outlined,
                                  'Visit Duration', data.visitDuration),
                              _buildInfoRow(Icons.description_outlined,
                                  'Reason to Visit', data.reasonToVisit),
                            ],
                          );
                        },
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
                          _buildInfoRow(
                              Icons.business, 'Company Name', compname ?? '-'),
                          _buildInfoRow(Icons.work_outline, 'Job Position',
                              jobposs ?? '-'),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 24),
                    // _buildStartButton(),
                  ],
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

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (datashow?.idrequest != null) {
            final queryParams = {
              'idrequest': datashow!.idrequest!,
              'plantId': datashow!.plantId.toString(),
              'plantName': datashow!.plantName ?? '',
            };

            final queryString = queryParams.entries
                .map((e) =>
                    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                .join('&');

            context.go('/welcome-test?$queryString');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data tidak lengkap')),
            );
          }
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
