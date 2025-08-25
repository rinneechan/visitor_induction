import 'package:flutter/material.dart';

class RequestInductionScreen extends StatefulWidget {
  const RequestInductionScreen({super.key});

  @override
  State<RequestInductionScreen> createState() => _RequestInductionScreenState();
}

class _RequestInductionScreenState extends State<RequestInductionScreen> {
  int _currentPage = 1;

  // Page 1 controllers
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _visitorController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  // Page 2 controllers
  final TextEditingController _picController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedPlant;

  final _formKey = GlobalKey<FormState>();

  final List<String> _plants = [
    "Cemindo Bayah Plant",
    "Cemindo Ciwandan Plant",
    "Cemindo Medan Plant",
    "Cemindo Pontianak Plant",
  ];

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentPage = 2;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Form Submitted Successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildPage1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Page 1 of 2", style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        const Text("Request Induction Form",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text("Fill in the required information.",
            style: TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 20),

        // Company
        TextFormField(
          controller: _companyController,
          decoration: const InputDecoration(
            labelText: "Company Name",
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.isEmpty ? "Company name is required" : null,
        ),
        const SizedBox(height: 16),

        // Visitor Name
        TextFormField(
          controller: _visitorController,
          decoration: const InputDecoration(
            labelText: "Visitor Name",
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.isEmpty ? "Visitor name is required" : null,
        ),
        const SizedBox(height: 16),

        // Purpose of Visit
        TextFormField(
          controller: _purposeController,
          decoration: const InputDecoration(
            labelText: "Purpose of Visit",
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.isEmpty ? "Purpose is required" : null,
        ),
        const Spacer(),

        // Next Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("NEXT"),
          ),
        ),
      ],
    );
  }

  Widget _buildPage2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Page 2 of 2", style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        const Text("Request Induction Form",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text("Fill in the required information.",
            style: TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 20),

        // Plant Destination
        DropdownButtonFormField<String>(
          value: _selectedPlant,
          decoration: const InputDecoration(
            labelText: "Plant Destination",
            border: OutlineInputBorder(),
          ),
          items: _plants.map((plant) {
            return DropdownMenuItem<String>(
              value: plant,
              child: Text(plant),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPlant = value;
            });
          },
          validator: (value) =>
              value == null ? "Please select plant destination" : null,
        ),
        const SizedBox(height: 16),

        // PIC
        TextFormField(
          controller: _picController,
          decoration: const InputDecoration(
            labelText: "PIC (Person in Charge)",
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? "PIC is required" : null,
        ),
        const SizedBox(height: 16),

        // Arrival Date
        InkWell(
          onTap: _pickDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: "Arrival Date",
              border: OutlineInputBorder(),
            ),
            child: Text(
              _selectedDate == null
                  ? "Select a date"
                  : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
              style: TextStyle(
                color: _selectedDate == null ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Phone Number
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: "Phone Number",
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? "Phone number is required" : null,
        ),
        const Spacer(),

        // Back & Submit Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentPage = 1;
                  });
                },
                child: const Text("← Back"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("SUBMIT"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visitor Induction"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: _currentPage == 1 ? _buildPage1() : _buildPage2(),
        ),
      ),
    );
  }
}
