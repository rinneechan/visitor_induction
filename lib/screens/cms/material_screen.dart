<<<<<<< HEAD
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:she_vi/utils/env_helper.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/material_by_plant_cms.dart';
=======
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
>>>>>>> web-v1.2

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
<<<<<<< HEAD
  PlatformFile? pickedFile;
  IconData fileIcon = Icons.insert_drive_file;

  bool isUploading = false;
  List<MaterialByPlantCMS> _materials = [];

  final ApiService apiService = ApiService();

=======
  String? uploadedFile;
  IconData fileIcon = Icons.insert_drive_file;

>>>>>>> web-v1.2
  final List<String> plantList = [
    "Cemindo Bayah Plant",
    "Cemindo Ciwandan Plant",
    "Cemindo Medan Plant",
    "Cemindo Pontianak Plant",
  ];

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    selectedPlant = _getPlantNameById(widget.plantId);
    _fetchMaterialList();
  }

  String? _getPlantNameById(String plantId) {
=======
    // otomatis pilih plant sesuai plantId
    selectedPlant = _getPlantNameById(widget.plantId);
  }

  String? _getPlantNameById(String plantId) {
    // Contoh mapping, sesuaikan dengan logic ID-Plant
>>>>>>> web-v1.2
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

<<<<<<< HEAD
  Future<void> _fetchMaterialList() async {
    try {
      final materials = await apiService.fetchMaterialsByPlant(widget.plantId);
      setState(() => _materials = materials);
    } catch (e) {
      debugPrint("⚠️ Gagal fetch material list: $e");
    }
  }

=======
>>>>>>> web-v1.2
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'ppt', 'pptx', 'mp4'],
<<<<<<< HEAD
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      setState(() {
        pickedFile = file;
        if (file.name.endsWith('.mp4')) {
          fileIcon = Icons.movie;
        } else if (file.name.endsWith('.pdf')) {
=======
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        uploadedFile = result.files.single.name;
        if (uploadedFile!.endsWith('.mp4')) {
          fileIcon = Icons.movie;
        } else if (uploadedFile!.endsWith('.pdf')) {
>>>>>>> web-v1.2
          fileIcon = Icons.picture_as_pdf;
        } else {
          fileIcon = Icons.slideshow;
        }
      });
    }
  }

<<<<<<< HEAD
  Future<void> _uploadMaterial() async {
    if (isUploading) return;
    if (titleController.text.isEmpty || pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Lengkapi judul dan file terlebih dahulu!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isUploading = true);

    // ====== DUPLICATE CHECK ======
    List<MaterialByPlantCMS> existingMaterials = [];
    try {
      existingMaterials =
          await apiService.fetchMaterialsByPlant(widget.plantId);
    } catch (e) {
      debugPrint('Warning: gagal fetch material list untuk cek duplikat: $e');
    }

    final newTitleNormalized = titleController.text.toLowerCase().trim();
    final alreadyExists = existingMaterials.any((m) {
      final name = (m.materialName ?? '').toLowerCase().trim();
      return name.isNotEmpty && name == newTitleNormalized;
    });

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Material dengan nama ini sudah ada di plant tersebut."),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() => isUploading = false);
      return;
    }
    // ====== END DUPLICATE CHECK ======

    File? fileToUpload;
    if (!kIsWeb && pickedFile?.path != null) {
      fileToUpload = File(pickedFile!.path!);
    }

    try {
      final result = await apiService.addMaterialCMS(
        materialname: titleController.text,
        status: "1",
        isactive: "1",
        folder: "",
        plantId: widget.plantId,
        file: fileToUpload,
        webFileBytes: kIsWeb ? pickedFile?.bytes : null,
        webFileName: kIsWeb ? pickedFile?.name : null,
      );

      bool success = false;
      String? message;

      if (result != null) {
        success = true;
        message = "Material berhasil ditambahkan!";
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message ?? "✅ Berhasil menambahkan material"),
            backgroundColor: Colors.green,
          ),
        );
        await _fetchMaterialList();
        setState(() {
          isUploading = false;
          titleController.clear();
          descriptionController.clear();
          pickedFile = null;
          fileIcon = Icons.insert_drive_file;
        });
        Future.delayed(const Duration(milliseconds: 700), () {
          context.pop('refresh');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message ?? "❌ Gagal menambahkan material"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isUploading = false);
      }
    } catch (e) {
      debugPrint("🚨 Error upload material: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
      setState(() => isUploading = false);
    }
  }

  // ===== UI Components =====

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          text,
          style: const TextStyle(
              fontFamily: 'Hanken Grotesk',
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
      );

  Widget _sectionCard({required Widget child}) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      );

  Widget _uploadCard() => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: pickFile,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)
            ],
          ),
=======
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
              context.go('/cms/material/$widget.plantId');
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
>>>>>>> web-v1.2
          child: Row(
            children: [
              Icon(fileIcon, color: const Color(0xFF07840B)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
<<<<<<< HEAD
                  pickedFile != null
                      ? pickedFile!.name
                      : "Upload PDF, PPT, atau MP4",
                  style: const TextStyle(
                      fontFamily: 'Hanken Grotesk', color: Colors.black87),
                ),
              ),
              if (pickedFile != null)
=======
                  uploadedFile ?? "Upload PDF, PPT, or MP4",
                  style: const TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    color: Colors.black87,
                  ),
                ),
              ),
              if (uploadedFile != null)
>>>>>>> web-v1.2
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
<<<<<<< HEAD
      );
=======
      ),
    );
  }
>>>>>>> web-v1.2

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: Colors.grey.shade100,
=======
>>>>>>> web-v1.2
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
<<<<<<< HEAD
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("Title"),
            _sectionCard(
              child: TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                    hintText: "Title Name", border: OutlineInputBorder()),
              ),
            ),
            _label("Upload (PDF / PPT / MP4)"),
            _sectionCard(child: _uploadCard()),
=======
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
            _buildSectionHeader("Plant", "Chosen plant: ${selectedPlant ?? '-'}"),
            _buildDropdownCard(),
            const SizedBox(height: 20),
            _buildSectionHeader(
                "Upload", "Upload your material (PDF, PPT, or MP4)"),
            _buildUploadCard(),
            const SizedBox(height: 50),
>>>>>>> web-v1.2
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
<<<<<<< HEAD
                onPressed: _uploadMaterial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07840B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
=======
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
>>>>>>> web-v1.2
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
