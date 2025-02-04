import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/InductionRequestId.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class VisitorRequest extends StatefulWidget {
  final String idrequest;
  const VisitorRequest({Key? key, required this.idrequest}) : super(key: key);

  @override
  _VisitorRequestState createState() => _VisitorRequestState();
}

class _VisitorRequestState extends State<VisitorRequest> {
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
        title: Text('SEDIA'),
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

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<InductionRequestId>>(
          future: fetchInductionId, // Future yang mengambil data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Tampilkan loading
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}')); // Tampilkan error jika ada
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data available')); // Jika tidak ada data
            } else {
              // Ambil data pertama dari snapshot
              final InductionRequestId data = snapshot.data!.first;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("[Need Approval] Induction Request - CG Employee",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 16),
                  Text("Dear $username,"),
                  SizedBox(height: 8),
                  Text("Please respond to this Induction Request from CG Employee with the following information:",
                      textAlign: TextAlign.justify),
                  SizedBox(height: 16),

                  // **Tampilkan Data dari API**
                  buildSectionHeader("VISITOR PROFILE"),
                  buildDetailRow("Full Name", ": ${data.fullName ?? "N/A"}"),
                  buildDetailRow("Company Name", ": PT. Cemindo Gemilang Tbk."),
                  buildDetailRow("Job Position", ": ${data.department ?? "N/A"}"),
                  SizedBox(height: 16),

                  buildSectionHeader("INDUCTION REQUEST"),
                  buildDetailRow("Plant Name",  ": ${data.plantName ?? "N/A"}"),
                  buildDetailRow("Department Name", ": ${data.departmentName ?? "N/A"}"),
                  buildDetailRow("PIC Name", ": ${data.picName ?? "N/A"}"),
                  buildDetailRow("Arrival Date", ": ${formatDate(data.arrivalDate ?? "")}"),
                  buildDetailRow("Visit Duration", ": ${data.visitDuration ?? "N/A"}"),
                  buildDetailRow("Reason to Visit", ": ${data.reasonToVisit ?? "N/A"}"),
                  SizedBox(height: 24),

                  buildSectionHeader("Do you approve this request?"),
                  // **Tombol Persetujuan dan Penolakan**
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF9D3838),  // Equivalent to #9D3838 in CSS
                            minimumSize: Size(120, 40),           // Adjust width and height
                            padding: EdgeInsets.all(16),          // Padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),  // Border radius
                            ),
                          ),
                          child: Text(
                            'Decline',
                            style: TextStyle(color: Colors.white),  // Text color
                          ),
                        ),

                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.push('/approved-email?idrequest=${widget.idrequest}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF07840B), // Warna hijau (#07840B)
                            minimumSize: const Size(120, 40), // Lebar dan tinggi tombol
                            padding: EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Border radius 8px
                            ),
                          ),
                          child: const Text(
                            "Approve",
                            style: TextStyle(
                              color: Colors.white, // Warna teks putih
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),




    );
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150, // Atur lebar tetap untuk label
            child: Text(
              "$label",
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis, // Tambahan jika label terlalu panjang
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(value ?? "N/A"),
          ),
        ],
      ),
    );
  }
}



