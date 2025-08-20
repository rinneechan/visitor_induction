import 'package:flutter/material.dart';
import '../home/custom_drawer.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/EmployeeByOu.dart';
import 'package:she_vi/models/Plant.dart';
import 'package:she_vi/models/Durations.dart' as customDurations;
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ReqInductionySatu extends StatefulWidget {
  @override
  _ReqInductionySatuScreenState createState() =>
      _ReqInductionySatuScreenState();
}

class _ReqInductionySatuScreenState extends State<ReqInductionySatu> {
  bool _isLoading = false;
  bool _isButtonEnabled = false;
  ApiService apiService = ApiService();

  PlantModel? _selectedPlant;
  List<PlantModel> plantlist = [];
  DateTime? _selectedDate;

  // Dept? _selectedDept;
  // List<Dept> deptlist = [];

  EmployeeByOu? _selectedEmplo;
  List<EmployeeByOu> emplolist = [];

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
      final loadVisitFuture = _loadVisit();

      await Future.wait([
        loadPlantsFuture,
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

  Future<void> _loadEmplo(String idplant) async {
    setState(() {
      _isLoading = true; // Tampilkan loading indicator
    });
    try {
      final emplo = await apiService.employeeByPlant(idplant);
      setState(() {
        emplolist = emplo;
        _selectedEmplo = emplo.isNotEmpty ? emplo.first : null;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching Employee: $e');
      setState(() {
        emplolist = [];
        _selectedEmplo = null;
        _isLoading = false;
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
          _selectedEmplo != null &&
          _selectedDate != null &&
          _reasonController.text.isNotEmpty;
    });
  }

  void _updateButtonState() {
    if (_selectedPlant != null) {
      setState(() {
        final String idplant = _selectedPlant!.codeplant;
        //_loadDept(idplant);
        _loadEmplo(idplant);
        _updateNextButtonState();
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

    // Pastikan _selectedPlant dan _selectedEmplo sudah dipilih
    if (_selectedPlant == null || _selectedEmplo == null) {
      _showCreateError('Pilih plant dan departemen terlebih dahulu.');
      return;
    }

    final String statusid = "0";
    final String plant_id = _selectedPlant?.id?.toString() ?? '';
    final String departmentname = _selectedEmplo?.unitname ?? '';
    final String picname = _selectedEmplo?.fullname ?? '';
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
        _isLoading = false;
      });

      // Cek jika berhasil
      if (result) {
        GoRouter.of(context).go('/request-submitted',
            extra: {'username': username ?? 'defaultID'});
      } else {
        _showCreateError('Gagal membuat Induction Request.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
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

  // void _showSuccessMessage(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text(message)),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
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
      drawer: CustomDrawer(username: username ?? "Guest"),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.shortestSide,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
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
                _buildButtons(context),
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
                _buildDropdownEmplo(
                    'PIC Name & Department', emplolist, _selectedEmplo,
                    (value) {
                  setState(() {
                    _selectedEmplo = value;
                  });
                }),
                // _buildDropdownDept('PIC Name & Department', deptlist, _selectedDept, (value) {
                //   setState(() { _selectedDept = value; });
                // }),

                SizedBox(height: 24),
                _buildDateSection(),
                SizedBox(height: 24),
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
                // child:CircularProgressIndicator()
                )
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

  Widget _buildDropdownEmplo(String title, List<EmployeeByOu> items,
      EmployeeByOu? selectedValue, Function(EmployeeByOu?) onChanged) {
    TextEditingController searchController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        items.isEmpty
            ? DropdownButton2<String>(
                isExpanded: true,
                hint: Text('Choose $title'),
                items: [
                  DropdownMenuItem<String>(
                    value: '',
                    child: Text('Choose Department destination'),
                  ),
                ],
                onChanged: null,
                value: '',
                buttonStyleData: ButtonStyleData(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    //borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            : DropdownButton2<EmployeeByOu>(
                isExpanded: true,
                hint: Text('Choose $title'),
                items: items
                    .map((item) => DropdownMenuItem<EmployeeByOu>(
                          value: item,
                          child: Text(item.fullname + ' - ' + item.unitname),
                        ))
                    .toList(),
                // items: items
                //     .take(5) // hanya ambil 5 item pertama
                //     .map((item) => DropdownMenuItem<EmployeeByOu>(
                //   value: item,
                //   child: Text('${item.fullname} - ${item.unitname}'),
                // ))
                //     .toList(),

                onChanged: (value) {
                  onChanged(value);
                  setState(() {
                    _selectedEmplo = value;
                  });
                },
                value: selectedValue,
                buttonStyleData: ButtonStyleData(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                dropdownSearchData: DropdownSearchData(
                  searchController: searchController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {}); // Perbarui tampilan setelah pencarian
                      },
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    final query = searchValue.toLowerCase();
                    final fullname = item.value!.fullname.toLowerCase();
                    final unitname = item.value!.unitname.toLowerCase();
                    return fullname.contains(query) || unitname.contains(query);
                    //return item.value!.fullname.toLowerCase().contains(searchValue.toLowerCase());
                  },
                ),
              ),
      ],
    );
  }

  // Widget _buildDropdownDept(String title, List<Dept> items, Dept? selectedValue, Function(Dept?) onChanged) {
  //   TextEditingController searchController = TextEditingController();
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(title,
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       SizedBox(height: 8),
  //       items.isEmpty? DropdownButton2<String>(
  //         isExpanded: true,
  //         hint: Text('Choose $title'),
  //         items: [
  //           DropdownMenuItem<String>(
  //             value: 'No Select Plant',
  //             child: Text('Choose Department destination'),
  //           ),
  //         ],
  //         onChanged: null,
  //         value: 'No Select Plant',
  //         underline: SizedBox(),
  //         buttonStyleData: ButtonStyleData(
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.grey),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //         ),
  //       )
  //           : DropdownButton2<Dept>(
  //         isExpanded: true,
  //         hint: Text('Choose $title'),
  //         items: items
  //             .map((item) => DropdownMenuItem<Dept>(
  //           value: item,
  //           child: Text(item.namedept),
  //         ))
  //             .toList(),
  //         onChanged: (value) {
  //           onChanged(value);
  //           setState(() {
  //             _selectedDept = value;
  //           });
  //         },
  //         value: selectedValue,
  //         buttonStyleData: ButtonStyleData(
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.grey),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //         ),
  //         dropdownSearchData: DropdownSearchData(
  //           searchController: searchController,
  //           searchInnerWidgetHeight: 50,
  //           searchInnerWidget: Padding(
  //             padding: const EdgeInsets.all(8),
  //             child: TextField(
  //               controller: searchController,
  //               decoration: InputDecoration(
  //                 hintText: 'Search...',
  //                 border: OutlineInputBorder(),
  //               ),
  //               onChanged: (value) {
  //                 setState(() {}); // Perbarui tampilan setelah pencarian
  //               },
  //             ),
  //           ),
  //           searchMatchFn: (item, searchValue) {
  //             return item.value!.namedept.toLowerCase().contains(searchValue.toLowerCase());
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildDropdownDept__(String title, List<Dept> items, Dept? selectedValue,
  //     Function(Dept?) onChanged) {
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             title,
  //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //           ),
  //           SizedBox(height: 8),
  //           items.isEmpty
  //               ? DropdownButtonFormField<String>(
  //             items: [
  //               DropdownMenuItem<String>(
  //                 value: 'No Select Plant',
  //                 child: Text('Select Plant'),
  //               ),
  //             ],
  //             onChanged: null, // Tidak ada interaksi karena Dept kosong
  //             value: 'No Select Plant',
  //             decoration: InputDecoration(
  //               hintText: 'Choose $title',
  //               border: OutlineInputBorder(),
  //             ),
  //           )
  //               : DropdownButtonFormField<Dept>(
  //             items: items.map((item) {
  //               return DropdownMenuItem<Dept>(
  //                 value: item,
  //                 child: Text(item.namedept),
  //               );
  //             }).toList(),
  //             onChanged: (value) {
  //               onChanged(value);
  //               setState(() {
  //                 _selectedDept = value;
  //               });
  //             },
  //             value: selectedValue,
  //             decoration: InputDecoration(
  //               hintText: 'Choose $title',
  //               border: OutlineInputBorder(),
  //             ),
  //           ),
  //         ],
  //       );
  // }

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

  // Widget ____buildButtons(BuildContext context) {
  //   return Positioned(
  //     bottom: 0,
  //     left: 0,
  //     right: 0,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           _buildBackButton(context),
  //           SizedBox(width: 8),
  //           _buildNextButton(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildButtons(BuildContext context) {
    return Positioned(
      bottom: 0, // Posisikan di bawah
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
        color: Colors.white,
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
