import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import '../home/custom_drawer.dart';
import 'package:she_vi/services/api_service.dart';

import 'package:she_vi/models/Dept.dart';
import 'package:she_vi/models/Plant.dart';
import 'package:she_vi/models/Durations.dart' as customDurations;
import 'package:hive/hive.dart';
import 'package:she_vi/screens/page/requestpagesatu_screen.dart';

class ReqInductionySatu extends StatefulWidget {
  @override
  _ReqInductionySatuScreenState createState() =>
      _ReqInductionySatuScreenState();
}

class _ReqInductionySatuScreenState extends State<ReqInductionySatu> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  bool _isButtonEnabled = false;
  ApiService apiService = ApiService();
  PlantModel? _selectedPlant;
  List<PlantModel> plantlist = [];
  DateTime? _selectedDate;

  Dept? _selectedDept;
  List<Dept> deptlist = [];

  customDurations.Durations? _selectedDuras;
  List<customDurations.Durations> duraslist = [];

  final TextEditingController _reasonController = TextEditingController();
  bool _isReasonValid = true;
  late Box box;
  String? iduser;
  String? username;
  String? visitorid;
  String? email;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  // Fungsi untuk membuka Hive box
  Future<void> _openBox() async {
    box = await Hive.openBox('userBox');
    setState(() {
      iduser = box.get('userid');
      username = box.get('username');
      visitorid = box.get('visitorid');
      email = box.get('email');
      String? token = box.get('token'); // Ambil token

      // Jika token tidak ada, navigasi ke halaman login
      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context,
            '/chooseaccess'); // Ganti '/login' dengan nama route halaman login
      } else {
        // Jika token ada, setState untuk memperbarui UI
        setState(() {
          _loadData();
          // Perbarui username jika diperlukan
          // username = box.get('username');
        });
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true; // Tampilkan loading indicator
    });

    try {
      final String idplant = "";
      final loadPlantsFuture = _loadPlants();
      final loadDeptFuture =
          _loadDept(idplant); // Jalankan fungsi dan simpan Future
      final loadVisitFuture = _loadVisit();

      await Future.wait([
        loadPlantsFuture,
        loadDeptFuture,
        loadVisitFuture,
      ]);
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false; // Sembunyikan loading indicator
      });
    }
  }

  Future<void> _loadPlants() async {
    try {
      final plants = await apiService.fetchPlant();
      setState(() {
        plantlist = plants;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch plants: $e')),
      );
    }
  }

  Future<void> _loadDept(String idplant) async {
    try {
      final dept =
          await apiService.fetchDept(idplant); // Fetch Dept berdasarkan Plant
      setState(() {
        deptlist = dept; // Tetapkan Dept ke daftar
        _selectedDept =
            dept.isNotEmpty ? dept.first : null; // Tetapkan Dept default
      });
    } catch (e) {
      print('Error fetching Dept: $e');
      setState(() {
        deptlist = []; // Tetapkan daftar kosong jika gagal
        _selectedDept = null; // Reset pilihan Dept
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        //_updateButtonState();
      });
    }
  }

  Future<void> _loadVisit() async {
    try {
      final duras = await apiService.fetchDuratuion();
      setState(() {
        duraslist = duras;
      });
    } catch (e) {
      print('Error fetching Dept: $e');
    }
  }

  void _updateNextButtonState() {
    setState(() {
      _isButtonEnabled = _selectedPlant != null &&
          _selectedDept != null &&
          _selectedDate != null &&
          _reasonController.text.isNotEmpty;
    });
  }

  void _updateButtonState() {
    if (_selectedPlant != null) {
      setState(() {
        final String idplant = _selectedPlant!.codeplant;
        _loadDept(idplant);
        _updateNextButtonState();
        //_isButtonEnabled = true; // Aktifkan tombol
      });
    } else {
      setState(() {
        _isButtonEnabled =
            false; // Nonaktifkan tombol jika tidak ada plant yang dipilih
      });
    }
  }

  void _validateReason() {
    setState(() {
      _isReasonValid = _reasonController.text.isNotEmpty;
      _isButtonEnabled = true;
    });
  }

  void _next() async {
    //Pastikan visitorid tidak null
    final String? visitorid = this.visitorid;
    if (visitorid == null || visitorid.isEmpty) {
      _showCreateError('Visitor ID tidak ditemukan.');
      return;
    }

    // Pastikan _selectedPlant dan _selectedDept sudah dipilih
    if (_selectedPlant == null || _selectedDept == null) {
      _showCreateError('Pilih plant dan departemen terlebih dahulu.');
      return;
    }

    final String statusid = "0"; // status_id diatur ke "0" sebagai string
    final String plant_id = _selectedPlant?.id?.toString() ?? '';
    final String departmentname =
        _selectedDept?.namedept ?? ''; //_selectedDept!.codedept;
    final String picname = 'test';
    final String arrivaldate = _selectedDate?.toIso8601String() ?? '';
    final String durationid = _selectedDuras?.id?.toString() ?? '';
    final String reasontovisit = _reasonController.text;
    final String createdby = iduser ?? '';
    final String updatedby = iduser ?? '';

    // Validasi input tambahan
    if (arrivaldate.isEmpty || durationid.isEmpty || reasontovisit.isEmpty) {
      _showCreateError('Lengkapi semua kolom yang diperlukan.');
      return;
    }

    setState(() {
      _isLoading = true; // Tampilkan indikator loading
    });

    try {
      // Panggil fungsi API
      final result = await apiService.createInductionRequest(
        visitorid,
        statusid,
        plant_id,
        departmentname,
        picname,
        arrivaldate,
        durationid,
        reasontovisit,
        createdby,
        updatedby,
      );

      setState(() {
        _isLoading = false; // Sembunyikan indikator loading
      });

      // Cek jika berhasil
      if (result) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ReqPageSatu()),
        );
      } else {
        _showCreateError('Gagal membuat Induction Request.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Pastikan loading disembunyikan jika error
      });
      _showConnectionError('Terjadi kesalahan: $e');
    }
  }

  void _showCreateError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showConnectionError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      key: _scaffoldKey,
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
      ),
      drawer: CustomDrawer(username: username),
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.shortestSide,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 80.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                      children: [
                        _buildBackground(),
                        SizedBox(height: 0),
                        _buildForm(context),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom:
                    MediaQuery.of(context).viewInsets.bottom > 0 ? 0.0 : 10.0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildButtons(context),
                ),
              ),
              if (_isLoading)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF07840B), // Warna hijau
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      color: Color(0xFFFFFFFF),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, // Card full width
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Request Induction Form'),
                SizedBox(height: 2),
                _buildSubtitle('Fill in the required information.'),
                SizedBox(height: 24),
                _buildDropdownSection(
                    'Plant Destination', plantlist, _selectedPlant, (value) {
                  setState(() {
                    _selectedPlant = value;
                  });
                }),
                SizedBox(height: 24),
                _buildDropdownDept(
                    'PIC Name & Department', deptlist, _selectedDept, (value) {
                  setState(() {
                    _selectedDept = value;
                  });
                }),
                SizedBox(height: 24),
                _buildDateSection(),
                _buildDropdownVisit(
                    'Visit Duration', duraslist, _selectedDuras, (value) {}),
                SizedBox(height: 24),
                Text(
                  'Reason to Visit',
                  style: TextStyle(
                    color: Color(0xFF343434),
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 120,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: _isReasonValid ? Color(0xFFD1D1D1) : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _reasonController,
                    onChanged: (value) {
                      setState(() {
                        _validateReason();
                        // _updateButtonState();
                      });
                    },
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: 'Specify reason for visit',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (!_isReasonValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Reason is required',
                      style: TextStyle(color: Colors.red, fontSize: 12.0),
                    ),
                  ),
                SizedBox(height: 24),
                _buildFootertitle(
                    'By submitting this form, I declare that all provided details are true and correct.'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Color(0xFF343434),
        fontFamily: 'Hanken Grotesk',
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSubtitle(String subtitle) {
    return Text(
      subtitle,
      style: TextStyle(
        color: Color(0xFF757575),
        fontFamily: 'Hanken Grotesk',
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildFootertitle(String subtitle) {
    return Text(
      subtitle,
      style: TextStyle(
        color: Color.fromARGB(255, 95, 95, 95),
        fontFamily: 'Hanken Grotesk',
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildDropdownSection(String title, List<PlantModel> items,
      PlantModel? selectedValue, Function(PlantModel?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        items.isEmpty
            ? Center(
                child:
                    CircularProgressIndicator()) // Loader jika data Plant belum ada
            : DropdownButtonFormField<PlantModel>(
                items: items.map((item) {
                  return DropdownMenuItem<PlantModel>(
                    value: item,
                    child: Text(item.nameplants), // Nama Plant yang ditampilkan
                  );
                }).toList(),
                onChanged: (value) {
                  onChanged(value);
                  setState(() {
                    _selectedPlant = value;
                    _updateButtonState(); // Perbarui Dept sesuai Plant
                  });
                },
                value: selectedValue,
                decoration: InputDecoration(
                  hintText: 'Choose $title',
                  border: OutlineInputBorder(),
                ),
              ),
      ],
    );
  }

  Widget _buildDropdownDept(String title, List<Dept> items, Dept? selectedValue,
      Function(Dept?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        items.isEmpty
            ? DropdownButtonFormField<String>(
                items: [
                  DropdownMenuItem<String>(
                    value: 'No Select Plant',
                    child: Text('Select Plant'),
                  ),
                ],
                onChanged: null, // Tidak ada interaksi karena Dept kosong
                value: 'No Select Plant',
                decoration: InputDecoration(
                  hintText: 'Choose $title',
                  border: OutlineInputBorder(),
                ),
              )
            : DropdownButtonFormField<Dept>(
                items: items.map((item) {
                  return DropdownMenuItem<Dept>(
                    value: item,
                    child: Text(item.namedept),
                  );
                }).toList(),
                onChanged: (value) {
                  onChanged(value);
                  setState(() {
                    _selectedDept = value;
                  });
                },
                value: selectedValue,
                decoration: InputDecoration(
                  hintText: 'Choose $title',
                  border: OutlineInputBorder(),
                ),
              ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Arrival Date', style: _sectionTextStyle),
        SizedBox(height: 8),
        _buildDatePicker(context),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Color(0xFFD1D1D1)),
              color: Colors.white,
            ),
            height: 56.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate == null
                      ? 'Choose a date'
                      : '${_selectedDate!.toLocal()}'.split(' ')[0],
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                ),
                IconButton(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_month),
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBackButton(context),
            SizedBox(width: 8),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildNextButton() {
    return Expanded(
      child: ElevatedButton(
        onPressed: _isButtonEnabled ? _next : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            Text(
              'Next',
              style: TextStyle(
                color: Color(0xFF4F4D4D),
                fontFamily: 'Hanken Grotesk',
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return Color(0xFFA4A4A4);
              }
              return Color(0xFF07840B);
            },
          ),
          padding: MaterialStateProperty.all<EdgeInsets>(
              EdgeInsets.symmetric(vertical: 16.0)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
        ),
      ),
    );
  }

  TextStyle get _sectionTextStyle {
    return TextStyle(
      color: Color(0xFF343434),
      fontFamily: 'Hanken Grotesk',
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
    );
  }

  Widget _buildDropdownVisit(String title, List<dynamic> items,
      dynamic selectedValue, Function(dynamic) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _sectionTextStyle),
        SizedBox(height: 8),
        items.isEmpty
            ? Center(
                child: Text('No items available'),
              )
            : DropdownButtonFormField<dynamic>(
                items: items.map((item) {
                  return DropdownMenuItem<dynamic>(
                    value: item,
                    child: Text(item.nameduration),
                  );
                }).toList(),
                onChanged: (value) {
                  onChanged(value); // Panggil callback onChanged
                  setState(() {
                    _selectedDuras = value; // Update _selectedDuras
                  });
                },
                value: selectedValue,
                decoration: InputDecoration(
                  hintText: 'Choose $title',
                  border: OutlineInputBorder(),
                ),
              ),
      ],
    );
  }
}
