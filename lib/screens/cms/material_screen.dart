import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:she_vi/utils/env_helper.dart';
import 'package:she_vi/services/api_service.dart';
import 'package:she_vi/models/material_model.dart';

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
  PlatformFile? pickedFile; // <-- handle web & mobile
  IconData fileIcon = Icons.insert_drive_file;

  final ApiService apiService = ApiService();

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
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      setState(() {
        pickedFile = file;
        if (file.name.endsWith('.mp4')) {
          fileIcon = Icons.movie;
        } else if (file.name.endsWith('.pdf')) {
          fileIcon = Icons.picture_as_pdf;
        } else {
          fileIcon = Icons.slideshow;
        }
      });
    }
  }

  Future<void> _uploadMaterial() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Harap lengkapi semua data dan unggah file!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⏳ Sedang menambahkan material..."),
        backgroundColor: Colors.blueAccent,
        duration: Duration(seconds: 1),
      ),
    );

    try {
      File? fileToUpload;

      if (!kIsWeb && pickedFile?.path != null) {
        fileToUpload = File(pickedFile!.path!);
      }

      final result = await apiService.addMaterialCMS(
        materialname: titleController.text,
        status: "1", // disesuaikan dengan backend boolean/1/0
        isactive: "1",
        folder: "",
        plantId: widget.plantId,
        file: fileToUpload,
        webFileBytes: kIsWeb ? pickedFile?.bytes : null,
        webFileName: kIsWeb ? pickedFile?.name : null,
      );

      // Cek hasil dari API
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Material berhasil ditambahkan!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Kosongkan form setelah berhasil
        titleController.clear();
        descriptionController.clear();
        setState(() {
          pickedFile = null;
          fileIcon = Icons.insert_drive_file;
        });

        // Arahkan kembali ke halaman CMS material list
        Future.delayed(const Duration(milliseconds: 800), () {
          context.go('/cms');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Gagal menambahkan material. Coba lagi."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🚫 Terjadi kesalahan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
      hintStyle: const TextStyle(fontFamily: 'Hanken Grotesk', color: Colors.grey),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedPlant,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF07840B)),
            items: plantList
                .map((p) => DropdownMenuItem<String>(
                      value: p,
                      child: Text(
                        p,
                        style: const TextStyle(
                            fontFamily: 'Hanken Grotesk',
                            color: Color(0xFF07840B),
                            fontWeight: FontWeight.w600),
                      ),
                    ))
                .toList(),
            onChanged: (val) => setState(() => selectedPlant = val),
          ),
        ),
      ),
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
                pickedFile != null
                    ? pickedFile!.name
                    : "Upload PDF, PPT, atau MP4",
                style: const TextStyle(
                    fontFamily: 'Hanken Grotesk', color: Colors.black87),
              ),
            ),
            if (pickedFile != null)
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

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
            _label("Title"),
            _sectionCard(
                child: TextFormField(
                    controller: titleController,
                    decoration: _outlineInputDecoration("Title Name"))),
            _label("Deskripsi Material"),
            _sectionCard(
                child: TextFormField(
                    controller: descriptionController,
                    decoration: _outlineInputDecoration("Masukkan deskripsi singkat"),
                    maxLines: 3)),
            _label("Plant (Dipilih Otomatis)"),
            _sectionCard(child: _styledDropdown()),
            _label("Upload (PDF / PPT / MP4)"),
            _sectionCard(child: _uploadCard()),
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
                onPressed: _uploadMaterial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07840B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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
