import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:she_vi/utils/env_helper.dart';
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

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _arrivalDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Dropdowns
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
    super.dispose();
  }

  // ------------------- API Functions -------------------

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

  // ------------------- Helpers -------------------

  Future<void> _onPlantChanged(PlantExternal? plant) async {
    setState(() {
      _selectedPlant = plant;
      _employeeList = [];
      _selectedEmplo = null;
    });

    if (plant == null) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
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
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1357BD)),
      ),
    );
  }

  Widget _buildDropdownSection({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.hankenGrotesk(
                fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF374151))),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  // ------------------- Build -------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Visitor Induction",
            style: GoogleFonts.hankenGrotesk(
                fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF111827))),
        centerTitle: true,
      ),
      drawer: const CustomDrawer(username: "Guest"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: _currentPage == 0 ? _buildPage1() : _buildPage2(),
          ),
        ),
      ),
    );
  }

  // ------------------- Page 1 -------------------

  Widget _buildPage1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProgress("Step 1 of 2"),
        const SizedBox(height: 16),
        Text("Request Induction Form",
            style: GoogleFonts.hankenGrotesk(
                fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
        const SizedBox(height: 24),
        _buildTextField(_emailController, "Work Email", "Enter your work email",
            validator: (value) {
          if (value == null || value.isEmpty) return "Work Email is required";
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(value)) return "Enter a valid email";
          return null;
        }),
        const SizedBox(height: 16),
        _buildTextField(_companyController, "Company Name", "Enter company name"),
        const SizedBox(height: 16),
        _buildTextField(_nameController, "Full Name", "Enter full name"),
        const SizedBox(height: 16),
        _buildTextField(_jobController, "Job Position", "Enter job position"),
        const SizedBox(height: 16),
        _buildTextField(_phoneController, "Phone Number", "Enter phone number",
            validator: (value) {
          if (value == null || value.isEmpty) return "Phone number is required";
          final phoneRegex = RegExp(r'^[0-9]{10,13}$');
          if (!phoneRegex.hasMatch(value)) return "Enter a valid phone number";
          return null;
        }),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) setState(() => _currentPage = 1);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07840B),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24)),
          child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }

  // ------------------- Page 2 -------------------

  Widget _buildPage2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProgress("Step 2 of 2"),
        const SizedBox(height: 16),
        _buildDropdownSection(
          label: 'Plant Destination',
          child: _isPlantLoading
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<PlantExternal>(
                  value: _selectedPlant,
                  isExpanded: true,
                  decoration: _inputDecoration(),
                  items: _plantList
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.plantName)))
                      .toList(),
                  onChanged: _onPlantChanged,
                  validator: (value) => value == null ? "Plant Destination is required" : null,
                ),
        ),
        const SizedBox(height: 16),
        _buildDropdownSection(
          label: 'PIC Name & Department',
          child: _isEmployeeLoading
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<UserPlantExternal>(
                  value: _selectedEmplo,
                  isExpanded: true,
                  decoration: _inputDecoration(),
                  items: _employeeList
                      .map((e) => DropdownMenuItem(
                          value: e, child: Text('${e.fullName} - ${e.unitName}')))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedEmplo = val),
                  validator: (value) => value == null ? "PIC is required" : null,
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
                      .map((d) => DropdownMenuItem(value: d, child: Text(d.passType)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedDuration = val),
                  validator: (value) => value == null ? "Visit Duration is required" : null,
                ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickDate,
          child: AbsorbPointer(
              child: _buildTextField(_arrivalDateController, "Arrival Date", "Select date")),
        ),
        const SizedBox(height: 16),
        _buildTextField(_reasonController, "Reason To Visit", "Enter reason"),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate() &&
                _selectedPlant != null &&
                _selectedEmplo != null &&
                _selectedDuration != null) {

              bool success = await ApiServiceExternal.submitInductionRequestExternal(
              visitorId: "26", // ambil dari user login
              statusId: "0",
              plantId: _selectedPlant!.id.toString(),
              departmentName: _selectedEmplo!.unitName,
              picName: _selectedEmplo!.fullName,
              arrivalDate: _arrivalDateController.text,
              durationId: _selectedDuration!.id,
              reasonToVisit: _reasonController.text,
              createdBy: "01122070002", // nanti ambil dari session login
              updatedBy: "01122070002",
);

              if (success) {
                GoRouter.of(context).go("/request-submitted?email=${_emailController.text}");
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal submit induction request')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07840B),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24)),
          child: const Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16)),
        )
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint,
      {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.hankenGrotesk(
                fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF374151))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator ?? (value) => value == null || value.isEmpty ? "$label is required" : null,
          decoration: _inputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildProgress(String stepText) {
    return Text(stepText,
        style: GoogleFonts.hankenGrotesk(
            fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF6B7280)));
  }
}
