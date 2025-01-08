import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/InductionRequestId.dart';
import 'package:hive/hive.dart';

class SubMissionHistory extends StatefulWidget {
  final String idrequest;
  const SubMissionHistory({Key? key, required this.idrequest})
      : super(key: key);

  @override
  _SubMissionHistoryState createState() => _SubMissionHistoryState();
}

class _SubMissionHistoryState extends State<SubMissionHistory> {
  late Box box;
  String? username;
  String? visitorid;
  String? emailuser;
  String? compname;
  String? jobposs;

  ApiService apiService = ApiService();
  Future<List<InductionRequestId>>? fetchInductionId;
  InductionRequestId? data;

  @override
  void initState() {
    super.initState();
    _openBox();
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
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      final String idrequest = widget.idrequest;
      fetchInductionId = ApiService().fetchInductionrequestId(idrequest);
      final result = await fetchInductionId;

      if (result != null && result.isNotEmpty) {
        setState(() {
          data = result.first;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Info', style: _textStyle(20, FontWeight.w700)),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF343434)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.white),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInductionRequestCard(),
                  const SizedBox(height: 16),
                  _buildVisitorProfileCard(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                //return _buildBottomButton();

                return (data?.statusid == 0)
                    ? _buildBottomButton()
                    : const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInductionRequestCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ExpansionTile(
          title:
              Text('Induction Request', style: _textStyle(16, FontWeight.w700)),
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            FutureBuilder<List<InductionRequestId>>(
              future: fetchInductionId,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: ${snapshot.error}',
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14)),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final dataList = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.only(left: 2.0, bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: dataList.map((data) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Status', data.status),
                            _buildDetailRow('Plant Name', data.plantName),
                            _buildDetailRow(
                                'Department Destination', data.department),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No data found',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF555555))),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorProfileCard() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: ExpansionTile(
        title: Text('Visitor Profile', style: _textStyle(16, FontWeight.w700)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2.0, bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Full Name', username ?? '-'),
                _buildDetailRow('Company Name', compname ?? '-'),
                _buildDetailRow('Job Position', jobposs ?? '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      height: 56, // Sesuai dengan height CSS
      padding:
          const EdgeInsets.symmetric(horizontal: 24), // Padding horizontal 24px
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8), // Border-radius 8px
        color:
            const Color(0xFF07840B), // Warna background sesuai dengan kode HEX
      ),
      child: Center(
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // justify-content: center
          crossAxisAlignment: CrossAxisAlignment.center, // align-items: center
          children: [
            Text(
              'Bottom Button',
              style: const TextStyle(
                color: Colors.white, // Warna teks putih
                fontSize: 16, // Ukuran font 16px
              ),
            ),
            const SizedBox(width: 4), // Gap 4px
            // Tambahkan elemen lain di sini jika diperlukan
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16.0, color: Color(0xFF555555))),
        const SizedBox(height: 8),
        Text(value, style: _textStyle(18, FontWeight.w700)),
        const SizedBox(height: 12),
      ],
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
