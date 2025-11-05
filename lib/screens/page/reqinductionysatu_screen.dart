// lib/screens/page/reqinductionysatu_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:she_vi/screens/home/custom_drawer.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/EmployeeByOu.dart';
import 'package:she_vi/models/plantvisit.dart';
import 'package:she_vi/models/Durations.dart' as customDurations;
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';

class ReqInductionySatu extends StatefulWidget {
  const ReqInductionySatu({super.key});

  @override
  _ReqInductionySatuScreenState createState() =>
      _ReqInductionySatuScreenState();
}

class _ReqInductionySatuScreenState extends State<ReqInductionySatu> {
  final ApiService apiService = ApiService();

  bool _isLoading = false;
  bool _isButtonEnabled = false;

  // Models
  Plantvisit? _selectedPlant;
  List<Plantvisit> plantlist = [];
  EmployeeByOu? _selectedEmplo;
  List<EmployeeByOu> emplolist = [];
  customDurations.Durations? _selectedDuras;
  List<customDurations.Durations> duraslist = [];

  DateTime? _selectedDate;

  // Form
  final TextEditingController _reasonController = TextEditingController();
  bool _isReasonValid = true;

  // Hive user data
  late Box box;
  String? iduser;
  String? username;
  String? visitorid;
  String? email;

  // Colors
  final Color primaryGreen = const Color(0xFF07840B);
<<<<<<< HEAD
  final Color lightGrey = const Color(0xFFF5F5F5);
=======
>>>>>>> web-v1.2

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox');
    setState(() {
      iduser = box.get('userid')?.toString();
      username = box.get('username')?.toString();
      visitorid = box.get('visitorid')?.toString();
      email = box.get('email')?.toString();
      final String? token = box.get('token')?.toString();

      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context, '/chooseaccess');
      } else {
<<<<<<< HEAD
        // load plants, employees & durations
=======
>>>>>>> web-v1.2
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([_loadPlants(), _loadVisit()]);
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ------------------- LOAD PLANTS -------------------
  Future<void> _loadPlants() async {
    try {
      final List<Plantvisit> plants = await apiService.fetchPlants();
      setState(() {
        plantlist = plants;
<<<<<<< HEAD
        // auto-select first plant if none selected
        if (_selectedPlant == null && plantlist.isNotEmpty) {
          _selectedPlant = plantlist.first;
          _updateButtonState();
          // load employees for first plant
          _loadEmplo(_selectedPlant!.id.toString());
        }
=======
        // ❌ jangan auto-select plant pertama
        // ✅ biarkan user memilih manual
        _selectedPlant = null;
        _updateNextButtonState();
>>>>>>> web-v1.2
      });
    } catch (e) {
      debugPrint('Failed to fetch plants: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat plants: $e')),
        );
      }
    }
  }

  Future<void> _loadEmplo(String idplant) async {
    setState(() => _isLoading = true);
    try {
      final emplo = await apiService.employeeByPlant(idplant);
      setState(() {
        emplolist = emplo;
        _selectedEmplo = emplo.isNotEmpty ? emplo.first : null;
      });
    } catch (e) {
      debugPrint('Error fetching Employee: $e');
      setState(() {
        emplolist = [];
        _selectedEmplo = null;
      });
    } finally {
      setState(() => _isLoading = false);
      _updateNextButtonState();
    }
  }

  Future<void> _loadVisit() async {
    try {
      final duras = await apiService.fetchDuratuion();
      setState(() {
        duraslist = duras;
<<<<<<< HEAD
=======
        _updateNextButtonState();
>>>>>>> web-v1.2
      });
    } catch (e) {
      debugPrint('Error fetching durations: $e');
      setState(() {
        duraslist = [];
      });
    }
  }

  void _updateNextButtonState() {
    setState(() {
      _isButtonEnabled = _selectedPlant != null &&
          _selectedEmplo != null &&
          _selectedDate != null &&
          _selectedDuras != null &&
          _reasonController.text.trim().isNotEmpty;
    });
  }

<<<<<<< HEAD
  void _updateButtonState() {
    if (_selectedPlant != null) {
      final String idplant = _selectedPlant!.id.toString();
      _loadEmplo(idplant);
      _updateNextButtonState();
    } else {
      setState(() => _isButtonEnabled = false);
    }
  }

=======
>>>>>>> web-v1.2
  void _validateReason() {
    setState(() {
      _isReasonValid = _reasonController.text.trim().isNotEmpty;
      _updateNextButtonState();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _updateNextButtonState();
      });
    }
  }

  Future<void> _next() async {
<<<<<<< HEAD
    // validations
=======
>>>>>>> web-v1.2
    if (visitorid == null || visitorid!.isEmpty) {
      _showCreateError('Visitor ID tidak ditemukan.');
      return;
    }
    if (_selectedPlant == null || _selectedEmplo == null) {
      _showCreateError('Pilih plant dan PIC terlebih dahulu.');
      return;
    }
    if (_selectedDate == null) {
      _showCreateError('Pilih tanggal kedatangan.');
      return;
    }
    if (_selectedDuras == null) {
      _showCreateError('Pilih durasi kunjungan.');
      return;
    }
    if (_reasonController.text.trim().isEmpty) {
      _showCreateError('Isikan alasan kunjungan.');
      return;
    }

    setState(() => _isLoading = true);

    final statusid = "0";
    final plantId = _selectedPlant!.id.toString();
    final departmentname = _selectedEmplo!.unitname;
    final picname = _selectedEmplo!.fullname;
    final arrivaldate = _selectedDate!.toIso8601String();
    final durationid = _selectedDuras!.id.toString();
    final reasontovisit = _reasonController.text.trim();
    final createdby = iduser ?? '';
    final updatedby = iduser ?? '';

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

      if (result == true) {
        GoRouter.of(context).go(
          '/request-submitted',
          extra: {'username': username ?? ''},
        );
      } else {
        _showCreateError('Gagal membuat Induction Request.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showConnectionError('Terjadi kesalahan: $e');
    }
  }

  void _showCreateError(String message) {
<<<<<<< HEAD
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
=======
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
>>>>>>> web-v1.2
  }

  void _showConnectionError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
<<<<<<< HEAD
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
=======
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK')),
>>>>>>> web-v1.2
        ],
      ),
    );
  }

<<<<<<< HEAD
  // ------------------ BUILD UI ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
=======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
>>>>>>> web-v1.2
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Visitor Induction',
          style: GoogleFonts.hankenGrotesk(
            color: const Color(0xFF343434),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
<<<<<<< HEAD
=======
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
>>>>>>> web-v1.2
      ),
      drawer: CustomDrawer(username: username ?? 'Guest'),
      body: SafeArea(
        child: Stack(
          children: [
<<<<<<< HEAD
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardHeader(),
                  const SizedBox(height: 12),
                  _buildForm(context),
                ],
              ),
            ),

            // buttons bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Next button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isButtonEnabled ? _next : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isButtonEnabled ? primaryGreen : Colors.grey.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Next',
                          style: GoogleFonts.hankenGrotesk(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black38,
=======
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardHeader(),
                      const SizedBox(height: 16),
                      _buildForm(context),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.black87),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isButtonEnabled ? _next : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isButtonEnabled
                                  ? primaryGreen
                                  : Colors.grey.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Next',
                              style: GoogleFonts.hankenGrotesk(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
>>>>>>> web-v1.2
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
<<<<<<< HEAD
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Induction Form',
            style: GoogleFonts.hankenGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF343434)),
          ),
          const SizedBox(height: 6),
          Text(
            'Fill in the required information.',
            style: GoogleFonts.hankenGrotesk(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
=======
    return Card(
      margin: EdgeInsets.zero, // ✅ hilangkan margin bawaan card
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      color: Colors.white,
      child: Container(
        width: double.infinity, // ✅ biar lebar penuh sejajar dengan form
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Induction Form',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please fill in all required details before proceeding.',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
>>>>>>> web-v1.2
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
<<<<<<< HEAD
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plant dropdown
          Text('Plant Destination', style: _sectionStyle()),
          const SizedBox(height: 8),
          DropdownButtonFormField<Plantvisit>(
            value: _selectedPlant,
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
            items: plantlist.map((p) {
              return DropdownMenuItem<Plantvisit>(
                value: p,
                child: Text(p.plantName ?? p.plantCode ?? ''),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPlant = value;
                _selectedEmplo = null;
                emplolist = [];
                _updateButtonState();
              });
              if (value != null) _loadEmplo(value.id.toString());
            },
          ),

          const SizedBox(height: 16),

          // PIC Name & Department
          Text('PIC Name & Department', style: _sectionStyle()),
          const SizedBox(height: 8),
          DropdownButtonFormField<EmployeeByOu>(
            value: _selectedEmplo,
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
            items: emplolist
                .map((e) => DropdownMenuItem<EmployeeByOu>(
                      value: e,
                      child: Text('${e.fullname} - ${e.unitname}'),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedEmplo = value;
                _updateNextButtonState();
              });
            },
          ),

          const SizedBox(height: 16),

          // Arrival Date
          Text('Arrival Date', style: _sectionStyle()),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Text(
                _selectedDate == null ? 'Choose a date' : _selectedDate!.toLocal().toString().split(' ')[0],
                style: GoogleFonts.hankenGrotesk(color: Colors.black87),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Duration
          Text('Visit Duration', style: _sectionStyle()),
          const SizedBox(height: 8),
          DropdownButtonFormField<customDurations.Durations>(
            value: _selectedDuras,
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
            items: duraslist
                .map((d) => DropdownMenuItem<customDurations.Durations>(
                      value: d,
                      child: Text(d.nameduration),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedDuras = value;
                _updateNextButtonState();
              });
            },
          ),

          const SizedBox(height: 16),

          // Reason
          Text('Reason to Visit', style: _sectionStyle()),
          const SizedBox(height: 8),
          Container(
            height: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _isReasonValid ? Colors.grey.shade300 : Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _reasonController,
              maxLines: null,
              expands: true,
              onChanged: (v) => _validateReason(),
              decoration: InputDecoration.collapsed(hintText: 'Specify reason for visit'),
            ),
          ),
          if (!_isReasonValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Reason is required', style: TextStyle(color: Colors.red.shade700)),
            ),

          const SizedBox(height: 12),

          Text(
            'By submitting this form, I declare that all provided details are true and correct.',
            style: GoogleFonts.hankenGrotesk(fontSize: 13, color: Colors.grey.shade700),
          ),
        ],
=======
    return Card(
      margin: EdgeInsets.zero, // ✅ hilangkan margin default biar sejajar header
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      color: Colors.white,
      child: Container(
        width: double.infinity, // ✅ jaga lebar konsisten
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownSection(
              label: 'Plant Destination',
              child: DropdownButtonFormField<Plantvisit>(
                value: _selectedPlant,
                isExpanded: true,
                decoration: _inputDecoration(),
                items: plantlist.map((p) {
                  return DropdownMenuItem<Plantvisit>(
                    value: p,
                    child: Text(p.plantName ?? p.plantCode ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPlant = value;
                    _selectedEmplo = null;
                    emplolist = [];
                  });
                  if (value != null) _loadEmplo(value.plantCode);
                  _updateNextButtonState();
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownSection(
              label: 'PIC Name & Department',
              child: DropdownButtonFormField<EmployeeByOu>(
                value: _selectedEmplo,
                isExpanded: true,
                decoration: _inputDecoration(),
                items: emplolist
                    .map((e) => DropdownMenuItem<EmployeeByOu>(
                          value: e,
                          child: Text(
                            '${e.fullname} - ${e.unitname}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.hankenGrotesk(fontSize: 14),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedEmplo = value);
                  _updateNextButtonState();
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownSection(
              label: 'Arrival Date',
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Choose a date'
                        : _selectedDate!.toLocal().toString().split(' ')[0],
                    style: GoogleFonts.hankenGrotesk(color: Colors.black87),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownSection(
              label: 'Visit Duration',
              child: DropdownButtonFormField<customDurations.Durations>(
                value: _selectedDuras,
                isExpanded: true,
                decoration: _inputDecoration(),
                items: duraslist.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: Text(d.nameduration),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedDuras = value);
                  _updateNextButtonState();
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownSection(
              label: 'Reason to Visit',
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: _isReasonValid ? Colors.grey.shade300 : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _reasonController,
                  maxLines: null,
                  expands: true,
                  onChanged: (_) => _validateReason(),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Specify reason for visit',
                  ),
                ),
              ),
            ),
            if (!_isReasonValid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Reason is required',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'By submitting this form, I declare that all provided details are true and correct.',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
>>>>>>> web-v1.2
      ),
    );
  }

<<<<<<< HEAD
  TextStyle _sectionStyle() {
    return GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF343434));
=======
  Widget _buildDropdownSection({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _sectionStyle()),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  TextStyle _sectionStyle() {
    return GoogleFonts.hankenGrotesk(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF343434),
    );
>>>>>>> web-v1.2
  }
}
