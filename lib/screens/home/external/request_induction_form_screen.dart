// lib/screens/page/request_induction_form_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:she_vi/models/duration_external_model.dart';
import 'package:she_vi/models/plant_external.dart';
import 'package:she_vi/models/user_plant_external.dart';
import 'package:she_vi/services/api_service_external.dart';
import 'package:she_vi/screens/home/custom_drawer.dart';

class RequestInductionFormScreen extends StatefulWidget {
  const RequestInductionFormScreen({super.key});

  @override
  State<RequestInductionFormScreen> createState() =>
      _RequestInductionFormScreenState();
}

class _RequestInductionFormScreenState
    extends State<RequestInductionFormScreen> {
  int _currentPage = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _arrivalDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  // Controller untuk search PIC
  final TextEditingController _picSearchController = TextEditingController();

  // Search Query untuk PIC
  String _picSearchQuery = '';

  // Dropdown data
  PlantExternal? _selectedPlant;
  List<PlantExternal> _plantList = [];
  bool _isPlantLoading = false;

  UserPlantExternal? _selectedEmplo;
  List<UserPlantExternal> _employeeList = [];
  bool _isEmployeeLoading = false;

  DurationExternal? _selectedDuration;
  List<DurationExternal> _durationList = [];
  bool _isDurationLoading = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPlants();
    _loadDurations();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _emailController.dispose();
    _companyController.dispose();
    _nameController.dispose();
    _jobController.dispose();
    _arrivalDateController.dispose();
    _reasonController.dispose();
    _phoneController.dispose();
    _picSearchController.dispose(); // Tambahkan ini
    super.dispose();
  }

  // ---------------- API HANDLERS ----------------

  Future<void> _loadPlants() async {
    setState(() => _isPlantLoading = true);
    try {
      _plantList = await ApiServiceExternal.fetchPlantsExternal();
    } catch (e) {
      debugPrint('Error load plants: $e');
    } finally {
      setState(() => _isPlantLoading = false);
    }
  }

  Future<void> _loadEmployeesForPlant(String plantCode) async {
    setState(() => _isEmployeeLoading = true);
    try {
      _employeeList =
          await ApiServiceExternal.fetchUserByPlantExternal(plantCode);
      // Reset PIC selection after loading new employees
      setState(() {
        _selectedEmplo = null;
      });
    } catch (e) {
      debugPrint('Error load employees: $e');
    } finally {
      setState(() => _isEmployeeLoading = false);
    }
  }

  Future<void> _loadDurations() async {
    setState(() => _isDurationLoading = true);
    try {
      _durationList = await ApiServiceExternal.fetchDurationsExternal();
    } catch (e) {
      debugPrint('Error load durations: $e');
    } finally {
      setState(() => _isDurationLoading = false);
    }
  }

  // ---------------- HELPERS ----------------

  Future<void> _onPlantChanged(PlantExternal? plant) async {
    setState(() {
      _selectedPlant = plant;
      _employeeList = []; // Kosongkan list PIC lama
      _selectedEmplo = null; // Kosongkan PIC yang dipilih
    });
    if (plant == null) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      _loadEmployeesForPlant(plant.plantCode);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
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
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    );
  }

  // ---------------- MODAL SEARCH PIC ----------------
  void _showPicSelectionModal() {
    // Reset search query setiap kali modal dibuka
    _picSearchController.clear();
    _picSearchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar modal bisa mengikuti ukuran konten
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) { // Gunakan modalSetState untuk internal modal
            // Fungsi untuk memfilter daftar PIC berdasarkan query
            List<UserPlantExternal> filteredList = _employeeList.where((employee) {
              final name = employee.fullName?.toLowerCase() ?? '';
              final unit = employee.unitName?.toLowerCase() ?? '';
              final searchQuery = _picSearchQuery.toLowerCase();
              return name.contains(searchQuery) || unit.contains(searchQuery);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Untuk menghindari overlap dengan keyboard
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _picSearchController,
                      decoration: const InputDecoration(
                        hintText: 'Search PIC Name or Department...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        modalSetState(() { // Gunakan modalSetState untuk memperbarui filter
                          _picSearchQuery = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final employee = filteredList[index];
                        return ListTile(
                          title: Text(employee.fullName ?? ''),
                          subtitle: Text(employee.unitName ?? ''),
                          onTap: () {
                            // PENTING: Panggil setState dari StatefulWidget induk untuk memperbarui UI utama
                            setState(() {
                              _selectedEmplo = employee;
                            });
                            // Setelah setState, tutup modal
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  // ---------------- EMAIL SENDER ----------------
  Future<void> _sendEmail(String recipient) async {
    try {
      final url = Uri.parse("http://10.10.10.72:3007/send-email");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "to": recipient,
          "subject": "Visitor Induction Request",
          "message": "Visitor induction request Anda berhasil dibuat.",
        }),
      );
      debugPrint("Email response: ${response.statusCode} ${response.body}");
    } catch (e) {
      debugPrint("Failed to send email: $e");
    }
  }

  // ---------------- SUBMIT ----------------
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() ||
        _selectedPlant == null ||
        _selectedEmplo == null ||
        _selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua field terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ApiServiceExternal.submitInductionRequestExternal(
      fullName: _nameController.text.trim(),
      companyName: _companyController.text.trim(),
      workEmail: _emailController.text.trim(),
      noHp: _phoneController.text.trim(),
      jobPosition: _jobController.text.trim(),
      userType: "External",
      tokenFirebase: "firebase_token_123",
      plantId: _selectedPlant!.id,
      departmentName: _selectedEmplo!.unitName,
      picName: _selectedEmplo!.fullName,
      arrivalDate: _arrivalDateController.text.trim(),
      durationId: _selectedDuration!.id,
      reasonToVisit: _reasonController.text.trim(),
      createdBy: "01122070002",
      updatedBy: "01122070002",
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text("Success!",
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text("Your visitor induction request has been submitted."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  //await _sendEmail(_emailController.text.trim());
                  if (mounted) context.go('/request-submitted');
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07840B),
                    minimumSize: const Size(double.infinity, 45)),
                child: const Text("OK",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Gagal submit induction request')),
      );
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go('/employee/request-induction');
        return false;
      },
      child: Scaffold(
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
        drawer: const CustomDrawer(username: "Guest"),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildStepIndicator(),
                      const SizedBox(height: 24),
                      _currentPage == 0 ? _buildPage1() : _buildPage2(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- STEP INDICATOR ----------------
  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStep("1", "Visitor Information", _currentPage == 0),
        Container(width: 40, height: 2, color: Colors.grey[300]),
        _buildStep("2", "Request Details", _currentPage == 1), // Perbaikan typo
      ],
    );
  }

  Widget _buildStep(String number, String title, bool active) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor:
              active ? const Color(0xFF07840B) : Colors.grey.shade400,
          child: Text(number,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 6),
        Text(title,
            style: GoogleFonts.hankenGrotesk(
                fontSize: 13,
                color: active ? const Color(0xFF07840B) : Colors.grey)),
      ],
    );
  }

  // ---------------- TEXTFIELD V2 (untuk PHONE ONLY) ----------------
  Widget _buildTextField(
  TextEditingController controller,
  String label,
  String hint, {
  bool isEmail = false,
  bool isPhone = false,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: isPhone ? TextInputType.number : TextInputType.text,
    inputFormatters: isPhone
        ? [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(13),
          ]
        : null,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "$label cannot be empty";
      }

      // EMAIL VALIDATOR
      if (isEmail) {
        final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
        if (!emailRegex.hasMatch(value)) {
          return "Enter a valid email address";
        }
      }

      // PHONE VALIDATOR: 10–13 digit
      if (isPhone) {
        if (value.length < 10 || value.length > 13) {
          return "Phone number must be 10-13 digits";
        }
      }

      return null;
    },
  );
}


  // ---------------- TEXTFIELD LAMA (BERLABEL) ----------------
  Widget _buildLabeledField(
  TextEditingController controller,
  String label,
  String hint, {
  bool isEmail = false,
  bool isPhone = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 6),

      TextFormField(
        controller: controller,
        keyboardType:
            isPhone ? TextInputType.number : TextInputType.text,
        inputFormatters: isPhone
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(13),
              ]
            : null,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label cannot be empty";
          }

          if (isEmail) {
            final emailRegex =
                RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
            if (!emailRegex.hasMatch(value)) {
              return "Enter a valid email address";
            }
          }

          if (isPhone) {
            if (value.length < 10 || value.length > 13) {
              return "Phone number must be 10–13 digits";
            }
          }

          return null;
        },
      ),
    ],
  );
}


  // ---------------- PAGE 1 ----------------
  Widget _buildPage1() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: _boxDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabeledField(
          _emailController,
          "Work Email",
          "Enter your work email",
          isEmail: true,
        ),
        const SizedBox(height: 16),

        _buildLabeledField(
          _companyController,
          "Company Name",
          "Enter company name",
        ),
        const SizedBox(height: 16),

        _buildLabeledField(
          _nameController,
          "Full Name",
          "Enter full name",
        ),
        const SizedBox(height: 16),

        _buildLabeledField(
          _jobController,
          "Job Position",
          "Enter job position",
        ),
        const SizedBox(height: 16),

        _buildLabeledField(
          _phoneController,
          "Phone Number",
          "Enter phone number",
          isPhone: true,
        ),

        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              setState(() => _currentPage = 1);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF07840B),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text("Next",
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}


  // ---------------- PAGE 2 ----------------
  Widget _buildPage2() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownSection(
            label: 'Plant Destination',
            child: _isPlantLoading
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<PlantExternal>(
                    value: _selectedPlant,
                    isExpanded: true,
                    decoration: _inputDecoration(),
                    items: _plantList
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.plantName),
                            ))
                        .toList(),
                    onChanged: _onPlantChanged,
                    validator: (value) => value == null ? "Select plant" : null,
                  ),
          ),
          const SizedBox(height: 16),
          // Ganti DropdownButtonFormField<UserPlantExternal> untuk PIC dengan ini:
          _buildDropdownSection(
            label: 'PIC & Department',
            child: _isEmployeeLoading
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
                    onTap: () => _showPicSelectionModal(), // Panggil fungsi modal
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedEmplo == null
                            ? 'Search PIC Name or Department...' // Ganti placeholder
                            : '${_selectedEmplo!.fullName} - ${_selectedEmplo!.unitName}', // Tampilkan nama dan unit
                        style: GoogleFonts.hankenGrotesk(color: Colors.black87),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          _buildDropdownSection(
            label: 'Visit Duration',
            child: _isDurationLoading
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<DurationExternal>(
                    value: _selectedDuration,
                    isExpanded: true,
                    decoration: _inputDecoration(),
                    items: _durationList
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d.passType),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedDuration = val),
                  ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickDate,
            child: AbsorbPointer(
              child: _buildLabeledField(
                  _arrivalDateController, "Arrival Date", "Select date"),
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdownSection(
  label: 'Reason To Visit',
  child: TextFormField(
    controller: _reasonController,
    maxLines: 3,
    decoration: _inputDecoration().copyWith(
      hintText: "Enter reason",
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return "Reason is required";
      }
      if (value.trim().length < 5) {
        return "Reason must be at least 5 characters";
      }
      return null;
    },
  ),
),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07840B),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Submit", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => setState(() => _currentPage = 0),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text("Back", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  // ---------------- REUSABLE UI ----------------
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildDropdownSection({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}