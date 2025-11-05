import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/InductionRequestHistory.dart';
<<<<<<< HEAD
=======
import 'package:hive/hive.dart';
>>>>>>> web-v1.2
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class DetailVisit extends StatefulWidget {
  final String idrequest;
  const DetailVisit({super.key, required this.idrequest});

  @override
  _DetailVisitState createState() => _DetailVisitState();
}

class _DetailVisitState extends State<DetailVisit> {
<<<<<<< HEAD
  late String idrequest;
  String? jobposs;
  String? username;
  String? compname;
  InductionRequestHistory? datashow;

  ApiService apiService = ApiService();
  late Future<List<InductionRequestHistory>> fetchInductionId;
=======
  String? username;
  String? compname;
  String? jobposs;
  late Future<List<InductionRequestHistory>> _fetchInductionId;

  final ApiService _apiService = ApiService();
>>>>>>> web-v1.2

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    fetchInductionId = Future.value([]); // Inisialisasi awal FutureBuilder
    _loadData(); // Membuka Hive dan memuat data
  }

  Future<void> _loadData() async {
    try {
      final String idrequest = widget.idrequest;
      final result = await apiService.fetchInductionrequestScan(idrequest);

      if (result.isNotEmpty) {
        setState(() {
          datashow = result.first;
          fetchInductionId = Future.value(result);

          // Misalnya, jika informasi visitor tersedia di `datashow`
          // username = datashow?.visitorName ?? '-';
          // compname = datashow?.companyName ?? '-';
          // jobposs = datashow?.jobPosition ?? '-';
        });
      } else {
        setState(() {
          datashow = null;
          username = '-';
          compname = '-';
          jobposs = '-';
        });
        print('API mengembalikan data kosong.');
      }
    } catch (e) {
      print('Error saat memuat data: $e');
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString); // Mengonversi string menjadi DateTime
      return DateFormat('d MMMM yyyy', 'id_ID').format(date); // Format tanggal: 18 September 2024
    } catch (e) {
      return dateString; // Jika format tanggal gagal, kembalikan string aslinya
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Detail Info', style: _textStyle(20, FontWeight.w700)),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF343434)),
          //onPressed: () => context.pop(),
          onPressed: () {
            print('Navigating back to previous screen');
            context.pop();
          },
        ),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.shortestSide,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(top: 5,bottom: 80),
                child: Column(
                  children: [
                    _buildInductionRequestCard(),
                    SizedBox(height: 1),
                    // _buildVisitorProfileCard(),
                    // SizedBox(height: 20),

                  ],
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInductionRequestCard() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.5),
      ),
      child: Container(
        child: Theme(
          data: ThemeData(
            // Menonaktifkan garis dividers
            dividerColor: Colors.transparent,
            // Atur warna icon agar tidak terlihat
            iconTheme: IconThemeData(color: Colors.transparent),
          ),
          child: ExpansionTile(

            title: Container(
              height: 52, // Tinggi kontainer
              padding: const EdgeInsets.symmetric(horizontal: 16), // Padding kiri dan kanan
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Justify-content: space-between
                crossAxisAlignment: CrossAxisAlignment.center, // Align-items: center
                children: [
                  Text(
                    'Induction Request',
                    style: _textStyle(16, FontWeight.w700),
                  ),

                ],
              ),
            ),
            initiallyExpanded: true,
            childrenPadding: EdgeInsets.zero,  // Menghapus padding anak

            children: [
              FutureBuilder<List<InductionRequestHistory>>(
                future: fetchInductionId,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final dataList = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: dataList.map((data) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow('Full Name', data.fullName, textAlign: TextAlign.left),
                                SizedBox(height: 16),
                                _buildDetailRow('Status', data.statusname, textAlign: TextAlign.left),
                                SizedBox(height: 16),
                                _buildDetailRow('Plant Name', data.plantName, textAlign: TextAlign.left),
                                SizedBox(height: 16),
                                _buildDetailRow('Department Destination', data.department, textAlign: TextAlign.left),
                                SizedBox(height: 16),
                                _buildDetailRow('PIC Name', data.picName, textAlign: TextAlign.left),
                                SizedBox(height: 16),
                                _buildDetailRow('Arrival Date', formatDate(data.arrivalDate), textAlign: TextAlign.left),
                                SizedBox(height: 16),
                                _buildDetailRow('Visit Duration', data.visitDuration, textAlign: TextAlign.left),
                                SizedBox(height: 16),
                                _buildDetailRow('Reason to Visit', data.reasonToVisit, textAlign: TextAlign.left),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No data found',
                        style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
=======
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
>>>>>>> web-v1.2
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildDetailRow(String title, String value, {TextAlign textAlign = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Sesuaikan posisi column
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start, // memastikan text sejajar ke kiri
            children: [
              Expanded(
                child: Text(
                  '$title:',
                  style: TextStyle(
                    //fontWeight: FontWeight.bold
                    color: Color(0xFF343434), // Menggunakan nilai warna dari CSS
                    fontFamily: 'Hanken Grotesk', // Menggunakan font-family dari CSS
                    fontSize: 14.0, // Ukuran font
                    fontWeight: FontWeight.w400, // Weight font
                    fontStyle: FontStyle.normal, // Style font
                    height: 1.0, // Line height sesuai dengan CSS line-height: normal
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start, // memastikan text sejajar ke kiri
            children: [
              Expanded(
                child: Text(
                  value,
                  // textAlign: textAlign,
                  style: TextStyle(
                    color: Color(0xFF343434),
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 16.0, // Ukuran font 16px
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    height: 1.0,
                  ),
                ),
              ),
            ],
=======
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
>>>>>>> web-v1.2
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildVisitorProfileCard() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.5),
      ),
      child: Container(
        child: Theme(
          data: ThemeData(
            // Menonaktifkan garis dividers
            dividerColor: Colors.transparent,
            // Atur warna icon agar tidak terlihat
            iconTheme: IconThemeData(color: Colors.transparent),
          ),
          child: ExpansionTile(
            //title: Text('Visitor Profile', style: _textStyle(16, FontWeight.w700)),
            title: Container(
              height: 52, // Tinggi kontainer
              padding: const EdgeInsets.symmetric(horizontal: 16), // Padding kiri dan kanan
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Justify-content: space-between
                crossAxisAlignment: CrossAxisAlignment.center, // Align-items: center
                children: [
                  Text(
                    'Visitor Profile',
                    style: _textStyle(16, FontWeight.w700),
                  ),

                ],
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Full Name', username ?? '-'),
                    SizedBox(height: 24),
                    _buildDetailRow('Company Name', compname ?? '-'),
                    SizedBox(height: 24),
                    _buildDetailRow('Job Position', jobposs ?? '-'),
                  ],
                ),
              ),
            ],
          ),
=======
  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 16),
>>>>>>> web-v1.2
        ),
      ),
    );
  }
<<<<<<< HEAD



  TextStyle _textStyle(double size, FontWeight weight) {
    return TextStyle(
      color: const Color(0xFF343434),
      fontFamily: 'Hanken Grotesk',
      fontSize: size,
      fontWeight: weight,
      fontStyle: FontStyle.normal,
      height: 1.0,
    );
  }
=======
>>>>>>> web-v1.2
}
