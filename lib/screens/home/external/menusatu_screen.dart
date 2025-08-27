import 'package:flutter/material.dart';
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
  }

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
      ),
    );
  }

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
}
