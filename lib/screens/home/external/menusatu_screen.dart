import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'custom_drawer.dart';
import 'package:she_vi/models/InductionMaterial.dart';
import 'package:she_vi/models/SubmissionHistory.dart';
import 'package:she_vi/models/InductionRequestHistory.dart';
import 'package:she_vi/models/InductionRequestProgress.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/screens/home/documentviewer_screen.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';

class MenusatuScreen extends StatefulWidget {
  final String username;
  const MenusatuScreen({Key? key, required this.username}) : super(key: key);
  @override
  _MenusatuScreenState createState() => _MenusatuScreenState();
}

class _MenusatuScreenState extends State<MenusatuScreen> {
  late Box box;
  String? username;
  String? visitorid;
  String? email;

  ApiService apiService = ApiService();
  Future<List<InductionMaterial>>? futureMaterials;
  Future<List<SubmissionHistory>>? futureHistory;
  Future<List<InductionRequestHistory>>? futureHistoryrequest;
  Future<List<InductionRequestProgress>>? fetchInductionProgress;

  List<InductionRequestHistory> requestlist = [];
  List<InductionRequestProgress> requestprogresslist = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox'); // Buka box 'userBox'
    setState(() {
      username = box.get('username');
      visitorid = box.get('visitorid');
      email = box.get('email');
      String? token = box.get('token');

      // Jika token tidak ada, navigasi ke halaman login
      if (token == null || token.isEmpty) {
        context.go('/login');
      } else {
        // Jika token ada, setState untuk memperbarui UI
        setState(() {
          _loadData();
        });
      }
    });
  }

  @override
  void _loadData() {
    setState(() => _isLoading = true);

    final String safeVisitorId = visitorid ?? 'defaultVisitorId';

    // Mulai fetch semua data paralel
    futureMaterials = apiService.fetchInductionMaterials();
    futureHistoryrequest = apiService.fetchInductionrequest(safeVisitorId);
    fetchInductionProgress =
        apiService.fetchInductionProgressrequest(safeVisitorId);

    // Tunggu semua Future selesai
    Future.wait([
      futureMaterials!,
      futureHistoryrequest!,
      fetchInductionProgress!,
    ]).then((_) {
      setState(() => _isLoading = false);
    }).catchError((error) {
      // Jika ada error, tetap matikan loading
      setState(() => _isLoading = false);
      // Optional: tampilkan error ke user/log
      debugPrint('Error loading data: $error');
    });
=======
import 'package:google_fonts/google_fonts.dart';

class RequestInductionFormScreen extends StatefulWidget {
  const RequestInductionFormScreen({super.key});

  @override
  State<RequestInductionFormScreen> createState() => _RequestInductionFormScreenState();
}

class _RequestInductionFormScreenState extends State<RequestInductionFormScreen> {
  int _currentPage = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _picController = TextEditingController();
  final TextEditingController _arrivalDateController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  String? _selectedPlant;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _arrivalDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
>>>>>>> web-v1.2
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    // Fungsi untuk mendapatkan warna berdasarkan status
    Color _getStatusColor(String status) {
      if (status == '0') {
        return Color(0xFFD18410); // Warna untuk On-Review
      } else if (status == '1') {
        return Color(0xFF1357BD); // Warna untuk Induction Test
      } else if (status == '2') {
        return Color(0x07840B); // Warna untuk Induction Test
      } else if (status == '3') {
        return Color(0xFF07840B); // Warna untuk Induction Test
      } else if (status == '4') {
        return Color(0xFF757575); // Warna untuk Induction Test
      }
      return Color(0x00757575); // Warna default (misalnya untuk status lainnya)
    }

    Color _getStatusColorRequest(String status) {
      if (status == '0') {
        return Color(0xFFD18410); // Warna untuk On-Review
      } else if (status == '1') {
        return Color(0xFF1357BD); // Warna untuk Induction Test
      } else if (status == '2') {
        return Color(0xFF757575); // Warna untuk Induction Test
      } else if (status == '3') {
        return Color(0xFF07840B); // Warna untuk Induction Test
      } else if (status == '4') {
        return Color(0xFF757575); // Warna untuk Induction Test
      }
      return Color(0x00757575); // Warna default (misalnya untuk status lainnya)
    }

    return WillPopScope(
      onWillPop: () async {
        context.go('/main-menu', extra: {
          'username': username ?? 'defaultID',
        });
        return false; // Hindari keluar langsung dari aplikasi
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Visitor Induction',
            style: TextStyle(
              color: Color(0xFF343434),
              fontFamily: 'Hanken Grotesk',
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              height: 1.0,
            ),
          ),
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 2,
          actions: [
            IconButton(
              icon:
                  Icon(Icons.refresh, color: Color(0xFF343434)), // Ikon reload
              onPressed: () {
                _loadData(); // Panggil ulang data
              },
            ),
          ],
        ),
        drawer: CustomDrawer(username: username),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadData(); // Panggil fungsi reload data
            },
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.shortestSide,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 230,
                                      child: Text(
                                        'Click the button below to schedule your visitor induction.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF757575),
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.all(
                                        16.0), // Padding di semua sisi (top, bottom, left, right)
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.push('/request-new-induction');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF07840B),
                                        padding: const EdgeInsets.symmetric(
                                            vertical:
                                                16.0), // Padding vertikal dalam tombol
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            'Request New Induction',
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
                                ],
                              ),
                            ),
                          ),
                          // SizedBox(height: 8),
                          Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        child: IconButton(
                                          icon: Image.asset(
                                            'assets/images/akar_icons_history.png',
                                            width: 24.0,
                                            height: 24.0,
                                          ),
                                          onPressed: () {
                                            // context.pop();
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'On Progress',
                                        style: TextStyle(
                                          color: Color(0xFF757575),
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w700,
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: FutureBuilder<
                                        List<InductionRequestProgress>>(
                                      future: fetchInductionProgress,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center();
                                        } else if (snapshot.hasError) {
                                          return Center(child: Text(''));
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return Center(
                                              child: Text("No data available"));
                                        } else {
                                          return ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap:
                                                true, // Membatasi tinggi ListView
                                            itemCount: snapshot.data!.length,
                                            itemBuilder: (context, index) {
                                              final progresson =
                                                  snapshot.data![index];
                                              return InkWell(
                                                onTap: (progresson.statusId ==
                                                            1 ||
                                                        progresson.statusId ==
                                                            3)
                                                    ? () {
                                                        if (progresson
                                                                .statusId ==
                                                            1) {
                                                          context.push(
                                                              '/detail-info?id=${progresson.idrequest}');
                                                        } else if (progresson
                                                                .statusId ==
                                                            3) {
                                                          context.push(
                                                              '/aktif-info?id=${progresson.idrequest}');
                                                        }
                                                      }
                                                    : null,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              143,
                                                              140,
                                                              140),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 8.0),
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: 230,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              progresson.plant,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Hanken Grotesk',
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Color(
                                                                    0xFF343434),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                              progresson
                                                                  .department,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Hanken Grotesk',
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Color(
                                                                    0xFF757575),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start, // Mengatur posisi elemen pada baris
                                                              children: <Widget>[
                                                                Text(
                                                                  progresson
                                                                      .arrivalDate,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Hanken Grotesk',
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Color(
                                                                        0xFF757575),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 5),
                                                                Text(
                                                                  '-',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Hanken Grotesk',
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Color(
                                                                        0xFF757575),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 5),
                                                                Text(
                                                                  progresson
                                                                      .visitDuration,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Hanken Grotesk',
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Color(
                                                                        0xFF757575),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            progresson.status,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Hanken Grotesk',
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: _getStatusColor(
                                                                  progresson
                                                                      .statusid),
                                                            ),
                                                          ),
                                                          SizedBox(height: 5),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        child: IconButton(
                                          icon: Image.asset(
                                            'assets/images/Induction_Material.png',
                                            width: 18.0,
                                            height: 20.0,
                                          ),
                                          onPressed: () {},
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'SHE Training Module',
                                        style: TextStyle(
                                          color: Color(0xFF757575),
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w700,
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  // Membungkus FutureBuilder dengan Expanded atau Flexible
                                  Flexible(
                                    fit: FlexFit
                                        .loose, // Membiarkan FutureBuilder mengatur tingginya sendiri
                                    child:
                                        FutureBuilder<List<InductionMaterial>>(
                                      future: futureMaterials,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              // child: CircularProgressIndicator()
                                              );
                                        } else if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return Center(
                                              child: Text("No data available"));
                                        } else {
                                          return ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap:
                                                true, // Membatasi tinggi ListView
                                            itemCount: snapshot.data!.length,
                                            itemBuilder: (context, index) {
                                              final material =
                                                  snapshot.data![index];
                                              return InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DocumentViewer(
                                                        idmateri: material
                                                            .idMateri
                                                            .toString(),
                                                        namaFile:
                                                            material.namaMateri,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              143,
                                                              140,
                                                              140),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 8.0),
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: 230,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              material
                                                                  .namaMateri,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Hanken Grotesk',
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Color(
                                                                    0xFF343434),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Download',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Hanken Grotesk',
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                              height: 1.0,
                                                              color: Color(
                                                                  0xFF343434),
                                                            ),
                                                          ),
                                                          SizedBox(height: 5),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize
                                    .min, // Memastikan Column tidak mengambil ruang tak terbatas
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        child: IconButton(
                                          icon: Image.asset(
                                            'assets/images/akar_icons_history.png',
                                            width: 24.0,
                                            height: 24.0,
                                          ),
                                          onPressed: () {},
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Submission History',
                                        style: TextStyle(
                                          color: Color(0xFF757575),
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w700,
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  //SizedBox(height: 16),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: FutureBuilder<
                                        List<InductionRequestHistory>>(
                                      future: futureHistoryrequest,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              //child: CircularProgressIndicator()
                                              );
                                        } else if (snapshot.hasError) {
                                          return Center(child: Text(''));
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return Center(
                                              child: Text("No data available"));
                                        } else {
                                          return ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap:
                                                true, // Membatasi tinggi ListView
                                            itemCount: snapshot.data!.length,
                                            itemBuilder: (context, index) {
                                              final history =
                                                  snapshot.data![index];
                                              return InkWell(
                                                onTap: () {
                                                  context.push(
                                                      '/detail-history?id=${history.idrequest}');
                                                  //context.push('/visitor-request?id=${history.idrequest}');
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              143,
                                                              140,
                                                              140),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 8.0),
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: 230,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              history.plant,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Hanken Grotesk',
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Color(
                                                                    0xFF343434),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                              history
                                                                  .department,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Hanken Grotesk',
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Color(
                                                                    0xFF757575),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start, // Mengatur posisi elemen pada baris
                                                              children: <Widget>[
                                                                // Text untuk arrivalDate
                                                                Text(
                                                                  history
                                                                      .arrivalDate,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Hanken Grotesk',
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Color(
                                                                        0xFF757575),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 5),
                                                                Text(
                                                                  '-',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Hanken Grotesk',
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Color(
                                                                        0xFF757575),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 5),
                                                                Text(
                                                                  history
                                                                      .visitDuration,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Hanken Grotesk',
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Color(
                                                                        0xFF757575),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            history.statusname,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Hanken Grotesk',
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: _getStatusColorRequest(
                                                                  history
                                                                      .statusid),
                                                            ),
                                                          ),
                                                          SizedBox(height: 5),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isLoading)
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF07840B)), // Warna hijau
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
=======
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Visitor Induction",
          style: GoogleFonts.hankenGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: _currentPage == 0 ? _buildPage1() : _buildPage2(),
>>>>>>> web-v1.2
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

  // PAGE 1
  Widget _buildPage1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Request Induction Form",
          style: GoogleFonts.hankenGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Fill in the required information",
          style: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 24),

        _buildTextField(_emailController, "Work Email", "Enter your work email"),
        const SizedBox(height: 16),

        _buildTextField(_companyController, "Company Name", "Enter company name"),
        const SizedBox(height: 16),

        _buildTextField(_nameController, "Full Name", "Enter full name"),
        const SizedBox(height: 16),

        _buildTextField(_jobController, "Job Position", "Enter job position"),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07840B), // Hijau
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _currentPage = 1;
                });
              }
            },
            child: Text(
              "Next",
              style: GoogleFonts.hankenGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  // PAGE 2
  Widget _buildPage2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(),
        const SizedBox(height: 16),

        _buildTextField(_picController, "PIC Name & Department", "Enter PIC details"),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: _pickDate,
          child: AbsorbPointer(
            child: _buildTextField(_arrivalDateController, "Arrival Date", "Select date"),
          ),
        ),
        const SizedBox(height: 16),

        _buildTextField(_durationController, "Visit Duration", "Enter duration"),
        const SizedBox(height: 16),

        _buildTextField(_reasonController, "Reason To Visit", "Enter reason"),
        const SizedBox(height: 24),

        Text(
          "By submitting this form, I declare that all provided details are true and correct",
          style: GoogleFonts.hankenGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
                label: Text(
                  "Back",
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  setState(() {
                    _currentPage = 0;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07840B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: handle submit
                  }
                },
                child: Text(
                  "Submit",
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1357BD)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Plant Destination",
          style: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedPlant,
          items: [
            "Cemindo Bayah Plant",
            "Cemindo Ciwandan Plant",
            "Cemindo Medan Plant",
            "Cemindo Pontianak Plant",
          ]
              .map((plant) => DropdownMenuItem(value: plant, child: Text(plant)))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedPlant = val;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),
      ],
    );
  }
>>>>>>> web-v1.2
}
