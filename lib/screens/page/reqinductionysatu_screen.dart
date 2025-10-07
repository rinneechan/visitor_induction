import 'package:flutter/material.dart';
import '../home/custom_drawer.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/EmployeeByOu.dart';
import 'package:she_vi/models/plantvisit.dart'; // pastikan lowercase
import 'package:she_vi/models/Durations.dart' as customDurations;
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ReqInductionySatu extends StatefulWidget {
  const ReqInductionySatu({super.key});

  @override
  _ReqInductionySatuScreenState createState() =>
      _ReqInductionySatuScreenState();
}

class _ReqInductionySatuScreenState extends State<ReqInductionySatu> {
  bool _isLoading = false;
  bool _isButtonEnabled = false;
  ApiService apiService = ApiService();

  Plantvisit? _selectedPlant;
  List<Plantvisit> plantlist = [];
  DateTime? _selectedDate;

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

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox');
    setState(() {
      iduser = box.get('userid');
      username = box.get('username');
      visitorid = box.get('visitorid');
      email = box.get('email');
      String? token = box.get('token');

      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context, '/chooseaccess');
      } else {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Future.wait([_loadPlants(), _loadVisit()]);
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// ------------------- LOAD PLANTS -------------------
Future<void> _loadPlants() async {
  try {
    // Panggil API fetchPlants() yang sudah tersedia
    final List<Plantvisit> plants = await apiService.fetchPlants();

    // Update state
    setState(() {
      plantlist = plants; // List<Plantvisit>
      // Jika belum ada plant terpilih, pilih plant pertama otomatis
      if (_selectedPlant == null && plantlist.isNotEmpty) {
        _selectedPlant = plantlist.first;
        _updateButtonState();
      }
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal memuat plants: $e')),
    );
  }
}


  Future<void> _loadEmplo(String idplant) async {
    setState(() {
      _isLoading = true;
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

  // void _updateNextButtonState() {
  //   setState(() {
  //     _isButtonEnabled = _selectedPlant != null &&
  //         _selectedEmplo != null &&
  //         _selectedDate != null &&
  //         _reasonController.text.isNotEmpty;
  //   });
  // }
  void _updateNextButtonState() {
    setState(() {
      _isButtonEnabled = _selectedPlant != null &&
          _selectedEmplo != null &&
          _selectedDate != null &&
          _selectedDuras != null && // Tambahkan ini!
          _reasonController.text.trim().isNotEmpty;
    });
  }

  void _updateButtonState() {
    if (_selectedPlant != null) {
      setState(() {
        final String idplant = _selectedPlant!.id.toString();
        _loadEmplo(idplant);
        _updateNextButtonState();
      });
    } else {
      setState(() {
        _isButtonEnabled = false;
      });
    }
  }

  void _validateReason() {
    setState(() {
      _isReasonValid = _reasonController.text.isNotEmpty;
      _updateNextButtonState();
    });
  }

  void _next() async {
    if (visitorid == null || visitorid!.isEmpty) {
      _showCreateError('Visitor ID tidak ditemukan.');
      return;
    }
    if (_selectedPlant == null || _selectedEmplo == null) {
      _showCreateError('Pilih plant dan departemen terlebih dahulu.');
      return;
    }

    final statusid = "0";
    final plantId = _selectedPlant!.id.toString();
    final departmentname = _selectedEmplo!.unitname;
    final picname = _selectedEmplo!.fullname;
    final arrivaldate = _selectedDate!.toIso8601String();
    final durationid = _selectedDuras?.id.toString() ?? '';
    final reasontovisit = _reasonController.text;
    final createdby = iduser ?? '';
    final updatedby = iduser ?? '';

    if (arrivaldate.isEmpty || durationid.isEmpty || reasontovisit.isEmpty) {
      _showCreateError('Lengkapi semua kolom yang diperlukan.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await apiService.createInductionRequest(
        visitorid!,
        statusid,
        plantId,
        departmentname,
        picname,
        arrivaldate,
        durationid,
        reasontovisit,
        createdby,
        updatedby,
      );
      setState(() => _isLoading = false);

      if (result) {
        GoRouter.of(context)
            .go('/request-submitted', extra: {'username': username ?? ''});
      } else {
        _showCreateError('Gagal membuat Induction Request.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showConnectionError('Terjadi kesalahan: $e');
    }
  }

  void _showCreateError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showConnectionError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visitor Induction', style: TextStyle(color: Color(0xFF343434))),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      drawer: CustomDrawer(username: username ?? "Guest"),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 80.0),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Request Induction Form',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                    SizedBox(height: 24),
                    _buildDropdownPlant(),
                    SizedBox(height: 24),
                    _buildDropdownEmplo(),
                    SizedBox(height: 24),
                    _buildDateSection(),
                    SizedBox(height: 24),
                    _buildDropdownVisit(),
                    SizedBox(height: 24),
                    _buildReasonField(),
                  ],
                ),
              ),
            ),
            _buildButtons(),
            if (_isLoading)
              Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF07840B)),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownPlant() {
    return DropdownButtonFormField<Plantvisit>(
      decoration: InputDecoration(labelText: 'Plant Destination', border: OutlineInputBorder()),
      value: _selectedPlant,
      items: plantlist
          .map((p) => DropdownMenuItem(value: p, child: Text(p.plantName ?? '')))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedPlant = value;
          _updateButtonState();
        });
      },
    );
  }

  Widget _buildDropdownEmplo() {
    return DropdownButtonFormField<EmployeeByOu>(
      decoration:
          InputDecoration(labelText: 'PIC Name & Department', border: OutlineInputBorder()),
      value: _selectedEmplo,
      items: emplolist
          .map((e) => DropdownMenuItem(value: e, child: Text('${e.fullname} - ${e.unitname}')))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedEmplo = value;
          _updateNextButtonState();
        });
      },
    );
  }

  Widget _buildDropdownVisit() {
    return DropdownButtonFormField<customDurations.Durations>(
      decoration: InputDecoration(labelText: 'Visit Duration', border: OutlineInputBorder()),
      value: _selectedDuras,
      items: duraslist
          .map((d) => DropdownMenuItem(value: d, child: Text(d.nameduration)))
          .toList(),
      onChanged: (value) {
        setState(() => _selectedDuras = value);
      },
    );
  }

<<<<<<< HEAD
=======
  Widget _buildForm(BuildContext context) {
    return SizedBox(
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

  Widget _buildDropdownSection(String title, List<Plant> items,
      Plant? selectedValue, Function(Plant?) onChanged) {
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
            : DropdownButtonFormField<Plant>(
                items: items.map((item) {
                  return DropdownMenuItem<Plant>(
                    value: item,
                    child: Text(item.plantName), // Nama Plant yang ditampilkan
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

  // Widget _buildDropdownEmplo(String title, List<EmployeeByOu> items,
  //     EmployeeByOu? selectedValue, Function(EmployeeByOu?) onChanged) {
  //   TextEditingController searchController = TextEditingController();

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         title,
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       SizedBox(height: 8),
  //       items.isEmpty
  //           ? DropdownButton2<String>(
  //               isExpanded: true,
  //               hint: Text('Choose $title'),
  //               items: [
  //                 DropdownMenuItem<String>(
  //                   value: '',
  //                   child: Text('Choose Department destination'),
  //                 ),
  //               ],
  //               onChanged: null,
  //               value: '',
  //               buttonStyleData: ButtonStyleData(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(color: Colors.grey),
  //                   //borderRadius: BorderRadius.circular(8),
  //                 ),
  //               ),
  //             )
  //           : DropdownButton2<EmployeeByOu>(
  //               isExpanded: true,
  //               hint: Text('Choose $title'),
  //               items: items
  //                   .map((item) => DropdownMenuItem<EmployeeByOu>(
  //                         value: item,
  //                         child: Text('${item.fullname} - ${item.unitname}'),
  //                       ))
  //                   .toList(),
  //               // items: items
  //               //     .take(5) // hanya ambil 5 item pertama
  //               //     .map((item) => DropdownMenuItem<EmployeeByOu>(
  //               //   value: item,
  //               //   child: Text('${item.fullname} - ${item.unitname}'),
  //               // ))
  //               //     .toList(),

  //               onChanged: (value) {
  //                 onChanged(value);
  //                 setState(() {
  //                   _selectedEmplo = value;
  //                 });
  //               },
  //               value: selectedValue,
  //               buttonStyleData: ButtonStyleData(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(color: Colors.grey),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //               ),
  //               dropdownSearchData: DropdownSearchData(
  //                 searchController: searchController,
  //                 searchInnerWidgetHeight: 50,
  //                 searchInnerWidget: Padding(
  //                   padding: const EdgeInsets.all(8),
  //                   child: TextField(
  //                     controller: searchController,
  //                     decoration: InputDecoration(
  //                       hintText: 'Search...',
  //                       border: OutlineInputBorder(),
  //                     ),
  //                     onChanged: (value) {
  //                       setState(() {}); // Perbarui tampilan setelah pencarian
  //                     },
  //                   ),
  //                 ),
  //                 searchMatchFn: (item, searchValue) {
  //                   final query = searchValue.toLowerCase();
  //                   final fullname = item.value!.fullname.toLowerCase();
  //                   final unitname = item.value!.unitname.toLowerCase();
  //                   return fullname.contains(query) || unitname.contains(query);
  //                   //return item.value!.fullname.toLowerCase().contains(searchValue.toLowerCase());
  //                 },
  //               ),
  //             ),
  //     ],
  //   );
  // }

  Widget _buildDropdownEmplo(
    String title,
    List<EmployeeByOu> items,
    EmployeeByOu? selectedValue,
    Function(EmployeeByOu?) onChanged,
  ) {
    final TextEditingController searchController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        if (_isLoading && items.isEmpty)
          Container(
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (items.isEmpty)
          Container(
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                'No PIC available',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          DropdownButton2<EmployeeByOu>(
            isExpanded: true,
            hint: Text('Choose $title'),
            value: selectedValue,
            items: items
                .map((item) => DropdownMenuItem<EmployeeByOu>(
                      value: item,
                      child: Text('${item.fullname} - ${item.unitname}'),
                    ))
                .toList(),
            onChanged: (value) {
              onChanged(value);
              setState(() {
                _selectedEmplo = value;
                _updateNextButtonState();
              });
            },
            // 🔥 INI YANG PENTING: Hilangkan semua garis bawah
            buttonStyleData: ButtonStyleData(
              height: 56,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              // Pastikan tidak ada underline
              elevation: 0,
            ),
            // 🔥 Juga pastikan dropdown-nya tidak punya garis bawah
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              elevation: 4,
              offset: const Offset(0, 4),
            ),
            menuItemStyleData: MenuItemStyleData(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            dropdownSearchData: DropdownSearchData<EmployeeByOu>(
              searchController: searchController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search PIC or department...',
                    hintStyle: TextStyle(fontSize: 14),
                    // 🔥 Hilangkan border bawah di TextField pencarian
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                final query = searchValue.toLowerCase();
                final fullname = item.value!.fullname.toLowerCase();
                final unitname = item.value!.unitname.toLowerCase();
                return fullname.contains(query) || unitname.contains(query);
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

>>>>>>> f6b7740dd86560b384cd317e8b0ac69b5212825c
  Widget _buildDateSection() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
        child: Text(_selectedDate?.toLocal().toString().split(' ')[0] ?? 'Choose Arrival Date'),
      ),
    );
  }

  Widget _buildReasonField() {
    return TextField(
      controller: _reasonController,
      onChanged: (_) => _validateReason(),
      maxLines: 5,
      decoration: InputDecoration(
          labelText: 'Reason to Visit',
          border: OutlineInputBorder(),
          errorText: _isReasonValid ? null : 'Reason is required'),
    );
  }

  Widget _buildButtons() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isButtonEnabled ? _next : null,
                child: Text('Next'),
              ),
            )
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

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
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return Color(0xFFA4A4A4);
              }
              return Color(0xFF07840B);
            },
          ),
          padding: WidgetStateProperty.all<EdgeInsets>(
              EdgeInsets.symmetric(vertical: 16.0)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
        ),
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

  // Widget _buildDropdownVisit(String title, List<dynamic> items,
  //     dynamic selectedValue, Function(dynamic) onChanged) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(title, style: _sectionTextStyle),
  //       SizedBox(height: 8),
  //       items.isEmpty
  //           ? Center(
  //               child: Text('No items available'),
  //             )
  //           : DropdownButtonFormField<dynamic>(
  //               items: items.map((item) {
  //                 return DropdownMenuItem<dynamic>(
  //                   value: item,
  //                   child: Text(item.nameduration),
  //                 );
  //               }).toList(),
  //               onChanged: (value) {
  //                 onChanged(value); // Panggil callback onChanged
  //                 setState(() {
  //                   _selectedDuras = value; // Update _selectedDuras
  //                 });
  //               },
  //               value: selectedValue,
  //               decoration: InputDecoration(
  //                 hintText: 'Choose $title',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //     ],
  //   );
  // }
  Widget _buildDropdownVisit(
      String title,
      List<customDurations.Durations> items,
      customDurations.Durations? selectedValue,
      Function(dynamic) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _sectionTextStyle),
        SizedBox(height: 8),
        items.isEmpty
            ? Container(
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Center(child: Text('No durations available')),
              )
            : DropdownButtonFormField<customDurations.Durations>(
                items: items.map((item) {
                  return DropdownMenuItem<customDurations.Durations>(
                    value: item,
                    child: Text(item.nameduration),
                  );
                }).toList(),
                onChanged: (value) {
                  onChanged(value);
                  setState(() {
                    _selectedDuras = value;
                    _updateNextButtonState(); // <-- Tambahkan ini
                  });
                },
                value: selectedValue,
                decoration: InputDecoration(
                  hintText: 'Choose $title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
      ],
    );
  }
>>>>>>> f6b7740dd86560b384cd317e8b0ac69b5212825c
}
