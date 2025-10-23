import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

class AddMaterialScreen extends StatefulWidget {
  final String plantId;
  const AddMaterialScreen({Key? key, required this.plantId}) : super(key: key);

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedPlant;
  String? uploadedFile;
  IconData fileIcon = Icons.insert_drive_file;

  final List<String> plantList = [
    "Cemindo Bayah Plant",
    "Cemindo Ciwandan Plant",
    "Cemindo Medan Plant",
    "Cemindo Pontianak Plant",
  ];

  @override
  void initState() {
    super.initState();
    selectedPlant = _getPlantNameById(widget.plantId);
  }

  String? _getPlantNameById(String plantId) {
    switch (plantId) {
      case 'bayah':
        return 'Cemindo Bayah Plant';
      case 'ciwandan':
        return 'Cemindo Ciwandan Plant';
      case 'medan':
        return 'Cemindo Medan Plant';
      case 'pontianak':
        return 'Cemindo Pontianak Plant';
      default:
        return null;
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'ppt', 'pptx', 'mp4'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        uploadedFile = result.files.single.name;
        if (uploadedFile!.endsWith('.mp4')) {
          fileIcon = Icons.movie;
        } else if (uploadedFile!.endsWith('.pdf')) {
          fileIcon = Icons.picture_as_pdf;
        } else {
          fileIcon = Icons.slideshow;
        }
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Text(
          "Have you entered the details correctly?",
          style: TextStyle(fontFamily: 'Hanken Grotesk'),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF07840B),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Material added successfully")),
              );
              context.go('/cms/material/${widget.plantId}');
            },
            child: const Text(
              "Yes",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "No",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- UI building helpers (style aligned with CmsQuestionScreen) ----------
  Widget _sectionCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Hanken Grotesk',
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _outlineInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Hanken Grotesk',
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 1.6),
      ),
      fillColor: Colors.white,
      filled: true,
    );
  }

  Widget _styledDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF07840B), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedPlant,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF07840B)),
            items: plantList
                .map(
                  (p) => DropdownMenuItem<String>(
                    value: p,
                    child: Text(
                      p,
                      style: const TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          color: Color(0xFF07840B),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => selectedPlant = val),
          ),
        ),
      ),
    );
  }

  Widget _styledTextField(
    TextEditingController controller, {
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _outlineInputDecoration(hint),
    );
  }

  Widget _uploadCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: pickFile,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Icon(fileIcon, color: const Color(0xFF07840B)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                uploadedFile ?? "Upload PDF, PPT, or MP4",
                style: const TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  color: Colors.black87,
                ),
              ),
            ),
            if (uploadedFile != null) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF07840B),
        elevation: 0,
        title: const Text(
          "Add New Material",
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card (mirroring CMSQuestionScreen style)
            _sectionCard(
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF07840B),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Form Tambah Materi",
                          style: TextStyle(
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Isi form di bawah untuk menambahkan materi baru.",
                          style: TextStyle(fontFamily: 'Hanken Grotesk', color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Title
            _label("Title"),
            _sectionCard(
              child: _styledTextField(titleController, hint: "Title Name"),
            ),

            // Description
            _label("Deskripsi Material"),
            _sectionCard(
              child: _styledTextField(descriptionController,
                  hint: "Masukkan deskripsi singkat", maxLines: 3),
            ),

            // Plant (styled like CMSQuestion)
            _label("Plant (Dipilih Otomatis)"),
            _sectionCard(child: _styledDropdown()),

            // Upload
            _label("Upload (PDF / PPT / MP4)"),
            _sectionCard(child: _uploadCard()),

            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () => context.go('/cms/material/${widget.plantId}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty &&
                      selectedPlant != null &&
                      uploadedFile != null) {
                    _showConfirmationDialog();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Please fill all fields and upload a PDF, PPT, or MP4"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07840B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Add Material",
                  style: TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
