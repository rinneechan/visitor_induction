import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

class AddMaterialScreen extends StatefulWidget {
  const AddMaterialScreen({super.key});

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
              context.go('/cms');
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

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInputCard(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: (val) =>
              (val == null || val.isEmpty) ? "$label cannot be empty" : null,
          decoration: InputDecoration(
            hintText: label,
            border: InputBorder.none,
            hintStyle: const TextStyle(
              fontFamily: 'Hanken Grotesk',
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonFormField<String>(
          value: selectedPlant,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Choose Plant",
          ),
          items: plantList
              .map((plant) =>
                  DropdownMenuItem(value: plant, child: Text(plant)))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedPlant = val;
            });
          },
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: pickFile,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
              if (uploadedFile != null)
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildSectionHeader(
                "Material Details", "Fill in the information below"),
            _buildSectionHeader("Title", "Enter the material title"),
            _buildInputCard("Title Name", titleController),
            const SizedBox(height: 12),
            _buildSectionHeader("Deskripsi Material", "Enter a short description"),
            _buildInputCard("Deskripsi Material", descriptionController, maxLines: 2),
            const SizedBox(height: 20),
            _buildSectionHeader("Plant", "Choose the related plant"),
            _buildDropdownCard(),
            const SizedBox(height: 20),
            _buildSectionHeader(
                "Upload", "Upload your material (PDF, PPT, or MP4)"),
            _buildUploadCard(),
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            // Back button
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ElevatedButton(
                onPressed: () => context.go('/cms'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(14),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            // Add Material button
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
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
