import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/InductionRequestId.dart';
import '../induction_test/welcome_testsatu_screen.dart';
import 'package:hive/hive.dart';

class DetailHistory extends StatefulWidget {
  final String idrequest;
  const DetailHistory({Key? key, required this.idrequest}) : super(key: key);

  @override
  _DetailHistoryState createState() => _DetailHistoryState();
}

class _DetailHistoryState extends State<DetailHistory> {
  late String idrequest;
  late Box box;
  String? username;
  String? visitorid;
  String? emailuser;
  String? compname;
  String? jobposs;
  InductionRequestId? datashow;

  ApiService apiService = ApiService();
  late Future<List<InductionRequestId>> fetchInductionId;

  @override
  void initState() {
    super.initState();
    fetchInductionId = Future.value([]); // Inisialisasi awal FutureBuilder
    _openBox(); // Membuka Hive dan memuat data
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox');
    setState(() {
      username = box.get('username');
      visitorid = box.get('visitorid');
      emailuser = box.get('email');
      compname = box.get('compname');
      jobposs = box.get('jobposs');
      String? token = box.get('token');

      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context, '/chooseaccess');
      } else {
        _loadData(); // Memuat data dari API jika token tersedia
      }
    });
  }

  Future<void> _loadData() async {
    try {
      final String idrequest = widget.idrequest;
      final result = await apiService.fetchInductionrequestId(idrequest);

      if (result.isNotEmpty) {
        setState(() {
          datashow = result.first; // Ambil data pertama
          fetchInductionId = Future.value(result); // Untuk FutureBuilder
        });
      } else {
        setState(() {
          datashow = null; // Kosongkan jika tidak ada data
        });
        print('API mengembalikan data kosong.');
      }
    } catch (e) {
      print('Error saat memuat data: $e');
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
        width: MediaQuery.of(context).size.shortestSide,
          child: Stack(
              children: [
                Positioned.fill(
              child: Container(color: Colors.white),
            ),

                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInductionRequestCard(),
                      SizedBox(height: 16),
                      _buildVisitorProfileCard(),
                    ],
                  ),
                ),
                // Positioned(
                //   bottom: 0,
                //   left: 0,
                //   right: 0,
                //   child: _buildBottomButton(),
                // ),
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
          title: Text(
            'Induction Request',
            style: _textStyle(16, FontWeight.w700),
          ),
          initiallyExpanded: true,
          childrenPadding: EdgeInsets.zero,  // Menghapus padding anak
          children: [
            FutureBuilder<List<InductionRequestId>>(
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
                              _buildDetailRow('Status', data.status, textAlign: TextAlign.left),
                              SizedBox(height: 16),
                              _buildDetailRow('Plant Name', data.plantName, textAlign: TextAlign.left),
                              SizedBox(height: 16),
                              _buildDetailRow('Department Destination', data.department, textAlign: TextAlign.left),
                              SizedBox(height: 16),
                              _buildDetailRow('PIC Name', '', textAlign: TextAlign.left),
                              SizedBox(height: 16),
                              _buildDetailRow('Arrival Date', '', textAlign: TextAlign.left),
                              SizedBox(height: 16),
                              _buildDetailRow('Visit Duration', '', textAlign: TextAlign.left),
                              SizedBox(height: 16),
                              _buildDetailRow('Reason to Visit', '', textAlign: TextAlign.left),
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
      ),
    ),
    );
  }

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
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorProfileCard() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.0),
      ),
      child: ExpansionTile(
        title: Text('Visitor Profile', style: _textStyle(16, FontWeight.w700)),
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
    );
  }

  Widget _buildBottomButton() {
    return GestureDetector(
      // onTap: () {
      //   if (datashow != null) {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => WelcomeTestSatuScreen(
      //           idrequest: datashow!.idrequest,
      //           plantName: datashow!.plantName,
      //         ),
      //       ),
      //     );
      //   } else {
      //     // Berikan pesan error jika data null
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Data belum tersedia')),
      //     );
      //   }
      // },
      // child: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding kiri dan kanan
      //   child: Container(
      //     height: 50,
      //     decoration: BoxDecoration(
      //       color: const Color(0xFF07840B),
      //       borderRadius: BorderRadius.circular(12),
      //     ),
      //
      //     child: const Center(
      //       child: Text(
      //         'Start Induction',
      //         style: TextStyle(color: Colors.white, fontSize: 16),
      //       ),
      //     ),
      //   ),
      // ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding di semua sisi (top, bottom, left, right)
          child: ElevatedButton(
            onPressed: () {
              //Navigator.pushNamed(context, '/request-new-induction');
              if (datashow != null) {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => WelcomeTestSatuScreen(
                //       idrequest: datashow!.idrequest,
                //       plantName: datashow!.plantName,
                //     ),
                //   ),
                // );
              } else {
                // Berikan pesan error jika data null
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data belum tersedia')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07840B),
              padding: const EdgeInsets.symmetric(vertical: 16.0), // Padding vertikal dalam tombol
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Start Induction',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        )

    );
  }

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
}
